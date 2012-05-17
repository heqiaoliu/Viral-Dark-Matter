function this = freqmagripple
%FREQMAGRIPPLE Constructor for this object.
%
%   Outputs:
%       this - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2005/06/16 08:40:14 $

this = fdadesignpanel.freqmagripple;

set(this, 'FrequencyVector', '[0 .4 .5 1]', ...
    'MagnitudeVector', '[1 1 0 0]', ...
    'RippleVector', '[.2 .1]', ...
    'FreqUnits', 'normalized');

% [EOF]
