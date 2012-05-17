function tf = ishdf(filename)
%ISHDF Returns true for an HDF file.
%   TF = ISHDF(FILENAME)

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:12:33 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 4, 'uint8');
    fclose(fid);
    tf = isequal(sig, [14; 3; 19; 1]);
end
