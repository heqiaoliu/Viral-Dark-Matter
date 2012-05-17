function this = hilbfreqmag
%HILBFREQMAG  Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2005/06/16 08:40:32 $

this = fdadesignpanel.hilbfreqmag;

% Set the defaults for the Hilbert Transformer FreqMag frame
set(this, 'freqUnits', 'normalized', ...
    'FrequencyVector', '[0.05 0.95]', ...
    'MagnitudeVector', '[1 1]', ...
    'WeightVector',    '[1]');

% [EOF]
