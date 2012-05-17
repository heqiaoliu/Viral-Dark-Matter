function tf = isgif(filename)
%ISGIF Returns true for a GIF file.
%   TF = ISGIF(FILENAME)

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:12:32 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 3, 'uint8');
    fclose(fid);
    tf = isequal(sig, [71; 73; 70]);
end
