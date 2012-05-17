function tf = ispng(filename)
%ISPNG Returns true for a PNG file.
%   TF = ISPNG(FILENAME)

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:12:38 $

fid = fopen(filename, 'r', 'ieee-be');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 8, 'uint8')';
    fclose(fid);
    tf = isequal(sig, [137 80 78 71 13 10 26 10]);
end
