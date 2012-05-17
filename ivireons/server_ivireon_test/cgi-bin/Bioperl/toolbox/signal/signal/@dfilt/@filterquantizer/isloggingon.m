function b = isloggingon(this)
%ISLOGGINGON   True if the filter logging is on.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/18 14:24:15 $

f = fipref;
b =  strcmpi(f.LoggingMode, 'on') && ...
        any(strmatch(f.DataTypeOverride , {'ForceOff','ScaledDoubles'}));


% [EOF]
