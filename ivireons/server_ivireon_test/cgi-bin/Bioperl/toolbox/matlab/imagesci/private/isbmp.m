function tf = isbmp(filename)
%ISBMP Returns true for a BMP file.
%   TF = ISBMP(FILENAME)

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:12:29 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 2, 'uint8');
    fclose(fid);
    tf = isequal(sig, double('BM')');
end

