function this = difffreqmagc
%DIFFFREQMAGC   Construct a DIFFFREQMAGC object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/10/18 21:09:52 $

this = fdadesignpanel.difffreqmagc;

set(this, ...
    'FreqUnits',       'Normalized', ...
    'FrequencyVector', '[0 .4 .5 1]', ...
    'MagnitudeVector', '[0 1 0 0]', ...
    'WeightVector',    '[1 1]');

% [EOF]
