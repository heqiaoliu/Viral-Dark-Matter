function [success, msg] = setupFDesign(this, varargin)
%SETUPFDESIGN   Set the upFDesign.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/10/16 06:38:40 $

success = true;
msg     = false;

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

% Evaluate the specifications
try
    specs = getSpecs(this, source);

    if strncmpi(source.FrequencyUnits, 'normalized', 10)
        normalizefreq(hd);
    else
        normalizefreq(hd, false, specs.InputSampleRate);
    end

    switch spec
        case 'fp,fst,ap,ast'
            setspecs(hd, specs.Fpass, specs.Fstop, specs.Apass, ...
                specs.Astop, specs.MagnitudeUnits);
        case 'n'
            setspecs(hd, specs.Order);
        case 'n,fp,fst'
            setspecs(hd, specs.Order, specs.Fpass, specs.Fstop);
        case 'ap'
            setspecs(hd, specs.Apass, specs.MagnitudeUnits);
        otherwise
            disp(sprintf('Finish %s', spec));
    end
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end

% [EOF]
