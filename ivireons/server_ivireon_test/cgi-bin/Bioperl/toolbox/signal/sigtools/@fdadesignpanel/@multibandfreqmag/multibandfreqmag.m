function this = multibandfreqmag
%MULTIBANDFREQMAG  Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2005/06/16 08:41:33 $

this = fdadesignpanel.multibandfreqmag;

% Set the defaults for the Multiband freqmag frame
set(this, 'freqUnits', 'normalized', ...
    'WeightVector',    '[1 1 1 1 1]', ...
    'FrequencyVector', '[0 .28 .3 .48 .5 .69 .7 .8 .81 1]', ...
    'MagnitudeVector', '[0 0 1 1 0 0 1 1 0 0]');

% [EOF]
