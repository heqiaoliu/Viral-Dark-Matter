function tf = isico(filename)
%ISICO Returns true for an ICO file.
%   TF = ISICO(FILENAME)

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:12:34 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 2, 'uint16');
    fclose(fid);
    tf = isequal(sig, [0; 1]);
end
