function [success, msg] =  setupFDesign(this, varargin)
%SETUPFDESIGN   Setup the contained FDesign.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/05/31 23:24:24 $

success = true;
msg     = '';

hd = get(this, 'FDesign');

if isempty(hd),
    return;
end

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

spec  = getSpecification(this, source);
set(hd, 'Specification', spec);

setupFDesignTypes(this);

try
    specs = getSpecs(this, source);

    if strncmpi(specs.FrequencyUnits, 'normalized', 10)
        normalizefreq(hd);
    else
        normalizefreq(hd, false, specs.InputSampleRate);
    end

    switch spec
        case 'tw,ast'
            setspecs(hd, specs.Band{:}, specs.TransitionWidth, ...
                specs.Astop, specs.MagnitudeUnits);
        case 'n,tw'
            setspecs(hd, specs.Band{:}, specs.Order, specs.TransitionWidth);
        case 'n'
            setspecs(hd, specs.Band{:}, specs.Order);
        case 'n,ast'
            setspecs(hd, specs.Band{:}, specs.Order, specs.Astop, specs.MagnitudeUnits);
        otherwise
            disp(sprintf('Finish %s', spec));
    end
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end

% [EOF]
