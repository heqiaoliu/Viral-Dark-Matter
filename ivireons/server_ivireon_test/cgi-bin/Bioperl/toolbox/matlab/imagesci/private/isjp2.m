function tf = isjp2(filename)
%ISJP2  Returns true for a JPEG2000 file or code stream.
%    TF = ISJP2(FILENAME) returns true if FILENAME refers to a JPEG-
%    2000 file or code stream.

%    Copyright 2008 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2008/05/14 22:02:50 $


% Page 535 of "JPEG 2000 Image Compression Fundamentals, Standards, and 
% Practice" identified the first 4 bytes of a JPEG 2000 code stream as 
% consisting of the markers
%
% SOC "start of code stream" FF4F ==> [255 79]
% SIZ "image and file size"  FF51 ==> [255 81]
%
% For a JP2 file, a four-byte preamble (0x000C == [0 0 0 12]) and a
% signature box must come first.  The box type is 'jP  ' == 0x6A502020 ==
% [106 80 32 32].  This is followed by the contents of the box, 0x0D0A870A
% == [13 10 135 10].
%
% This makes a signature of 12 bytes,
%
% [0 0 0 12 106 80 32 32 13 10 135 10].

% Magic values.
jp2sig = [0 0 0 12 106 80 32 32 13 10 135 10]';
jpcsig = [255 79 255 81]';

% Open the file.
fid = fopen(filename, 'r');
if (fid < 0)
    tf = false;
    return;
end

% Read the first 12 bytes.
[filesig, count] = fread(fid, 12, 'uint8');
fclose(fid);

if (count ~= 12)
    tf = false;
    return;
end

% Is it a codestream wrapped in a box?
if (isequal(jp2sig, filesig))
    tf = true;
    return
end

% Is it just a code stream?
if (isequal(jpcsig, filesig(1:4)))
    tf = true;
    return
end


% If we're here, then it's probably not a JPEG 2000 file or codestream.
tf = false;
