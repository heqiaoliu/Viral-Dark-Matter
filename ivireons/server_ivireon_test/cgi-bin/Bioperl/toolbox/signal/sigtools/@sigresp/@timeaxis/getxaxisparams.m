function hPrm = getxaxisparams(hObj)
%GETXAXISPARAMS

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:30:02 $

hPrm = get(hObj, 'Parameters');

hPrm = find(hPrm, ...
    'tag', 'freqmode', '-or', ...
    'tag', 'plottype');

% [EOF]
