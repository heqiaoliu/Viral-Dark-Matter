function hPrm = freqaxis_getxaxisparams(hObj)
%FREQAXIS_GETXAXISPARAMS Differentiates freq. axis from time axis.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:29:04 $

hPrm = get(hObj, 'Parameters');

hPrm = find(hPrm, 'tag', getfreqrangetag(hObj),'-or', ...
    'tag', getnffttag(hObj), '-or', ...
    'tag', 'freqmode', '-or', ...
    'tag', 'freqscale');

% [EOF]
