function frewind(fid)
%FREWIND Rewind file.
%   FREWIND(FID) sets the file position indicator to the beginning of
%   the file associated with file identifier FID.
%
%   WARNING: Rewinding an FID associated with a tape device may not work.
%            In such cases, no error message is generated.
%
%   See also FOPEN, FPRINTF, FREAD, FSCANF, FSEEK, FTELL, FWRITE.

%   Martin Knapp-Cordes, 1-30-92, 7-13-92, 11-2-92
%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 5.10.4.4 $  $Date: 2006/06/20 20:11:34 $

error(nargchk(1, 1, nargin, 'struct'));

status = fseek(fid, 0, -1);
if (status == -1)
    error ('MATLAB:frewind:Failed', 'Rewind failed.')
end
