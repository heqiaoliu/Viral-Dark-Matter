function this = difffreqmag
%DIFFFREQMAG  Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2005/06/16 08:39:54 $

this = fdadesignpanel.difffreqmag;

% Set the defaults for the differentiator freqmag frame
set(this, 'freqUnits', 'normalized', ...
    'FrequencyVector', '[0 .5 .55 1]', ...
    'MagnitudeVector', '[0 1 0 0]', ...
    'WeightVector',    '[1 1]');

% [EOF]
