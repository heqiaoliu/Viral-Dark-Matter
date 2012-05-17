function restore(hPrm)
%RESTORE Restore the default value

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:38:29 $

setvalue(hPrm, get(hPrm, 'DefaultValue'));

% [EOF]
