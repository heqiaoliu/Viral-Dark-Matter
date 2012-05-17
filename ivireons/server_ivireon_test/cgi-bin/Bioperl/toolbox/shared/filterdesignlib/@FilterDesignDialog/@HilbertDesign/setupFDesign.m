function [success, msg] = setupFDesign(this, varargin)
%SETUPFDESIGN   Set the upFDesign.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/10/16 06:38:46 $

success = true;
msg     = '';

hd = get(this, 'FDesign');

spec = getSpecification(this, varargin{:});

% In the Simulink operating mode the saved specs could require a Filter
% Design Toolbox license that may not be available (read-only mode)
setSpecsSafely(this, hd, spec);

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

try
    specs = getSpecs(this, source);

    if strncmpi(specs.FrequencyUnits, 'normalized', 10)
        normalizefreq(hd);
    else
        normalizefreq(hd, false, specs.InputSampleRate);
    end

    switch lower(spec)
        case 'n,tw'
            setspecs(hd, specs.Order, specs.TransitionWidth);
        case 'tw,ap'
            setspecs(hd, specs.TransitionWidth, specs.Apass, specs.MagnitudeUnits);
    end
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end
% [EOF]
