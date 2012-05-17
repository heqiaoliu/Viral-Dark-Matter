function tf = iscur(filename)
%ISCUR Returns true for a CUR file.
%   TF = ISCUR(FILENAME)
%
%   See also WK1READ.
  
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:12:30 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 2, 'uint16');
    tf = isequal(sig, [0; 2]);
    
    % Might be a WK1 file.
    if (tf)
        fseek(fid, 0, 'bof');
        sig = fread(fid, 6, 'uchar');
        tf = ~isequal(sig, [0 0 2 0 6 4]');  % WK1 BOF identifier.
    end
    
    fclose(fid);
end
