function hPrm = getxaxisparams(hObj)
%GETXAXISPARAMS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/09/12 15:25:11 $

hPrm = get(hObj, 'Parameters');

hPrm = find(hPrm, 'tag', 'uselength','-or', ...
    'tag', 'impzlength', '-or', ...
    'tag', 'timemode', '-or', ...
    'tag', 'plottype');

% [EOF]
