function hPrm = getxaxisparams(hObj)
%GETXAXISPARAMS

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/13 00:20:32 $

hPrm = get(hObj, 'Parameters');

hPrm = find(hPrm, 'tag', 'unitcirclewnofreqvec','-or', ...
    'tag', 'nfftfornlm', '-or', ...
    'tag', 'freqmode', '-or', ...
    'tag', 'frequnits', '-or', ...
    'tag', 'montecarlo', '-or', ...
    'tag', 'freqscale');

% [EOF]
