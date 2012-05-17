function this = arbmagfreqmag
%ARBMAGFREQMAG  Constructor for this object.
%
%   Inputs:
%       FreqVec   - Frequency Vector
%       MagVec    - Magnitude Vector
%       WeightVec - Weight Vector
%       Fs        - Sampling Frequency
%       FreqUnits - Frequency Units ('Hz', 'kHz', etc.)
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2005/06/16 08:39:28 $

this = fdadesignpanel.arbmagfreqmag;

% Set the defaults for the differentiator freqmag frame
set(this, 'freqUnits', 'normalized', ...
    'FrequencyVector', '[0:.05:.55 .6 1]', ...
	'MagnitudeVector', '[1./sinc(0:.05:.55) 0 0]', ...
    'WeightVector',    '[100*ones(1,6) 10]');

% [EOF]
