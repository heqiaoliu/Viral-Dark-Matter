function [success, msg] = setupFDesign(this, varargin)
%SETUPFDESIGN Set the upFDesign

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/05/31 23:24:39 $

success = true;
msg     = '';

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

specs = getSpecs(this, source);

hfdesign = get(this, 'FDesign');

try
    if strncmpi(source.FrequencyUnits, 'normalized', 10)
        normalizefreq(hfdesign);
    else
        normalizefreq(hfdesign, false, specs.InputSampleRate);
    end

    set(hfdesign, 'FilterOrder', specs.Order, ...
        'BandsPerOctave', specs.BandsPerOctave);

    % If the specified center frequency is "significantly" close to a valid
    % frequency, use that frequency.
    vFreqs = validfrequencies(hfdesign);

    % Round the valid frequencies to 5 significant figures
    m = 10.^ceil(4-log10(vFreqs));
    rvFreqs = round(vFreqs.*m)./m;

    indx = find(abs(rvFreqs - specs.F0) < .01);

    if ~isempty(indx)
        specs.F0 = vFreqs(indx);
    end

    set(hfdesign, 'F0', specs.F0);
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end

% [EOF]
