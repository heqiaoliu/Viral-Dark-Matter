function [success, msg] = setupFDesign(this, varargin)
%SETUPFDESIGN   Setup the contained FDesign.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/10/16 06:38:44 $

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

% Evaluate the specifications
try
    specs = getSpecs(this, source);

    if strncmpi(specs.FrequencyUnits, 'normalized', 10)
        normalizefreq(hd);
    else
        normalizefreq(hd, false, specs.InputSampleRate);
    end

    switch spec
        case 'fst,fp,ast,ap'
            setspecs(hd, specs.Fstop, specs.Fpass, specs.Astop, ...
                specs.Apass, specs.MagnitudeUnits);
        case 'n,f3db'
            setspecs(hd, specs.Order, specs.F3dB);
        case 'n,f3db,ap'
            setspecs(hd, specs.Order, specs.F3dB, specs.Apass, specs.MagnitudeUnits);
        case 'n,f3db,ast'
            setspecs(hd, specs.Order, specs.F3dB, specs.Astop, specs.MagnitudeUnits);
        case 'n,f3db,ast,ap'
            setspecs(hd, specs.Order, specs.F3dB, specs.Astop, ...
                specs.Apass, specs.MagnitudeUnits);
        case 'n,f3db,fp'
            setspecs(hd, specs.Order, specs.F3dB, specs.Fpass);
        case 'n,fc'
            setspecs(hd, specs.Order, specs.F6dB);
        case 'n,fc,ast,ap'
            setspecs(hd, specs.Order, specs.F6dB, specs.Astop, ...
                specs.Apass, specs.MagnitudeUnits);
        case 'n,fp,ap'
            setspecs(hd, specs.Order, specs.Fpass, specs.Apass, specs.MagnitudeUnits);
        case 'n,fp,ast,ap'
            setspecs(hd, specs.Order, specs.Fpass, specs.Astop, ...
                specs.Apass, specs.MagnitudeUnits);
        case 'n,fst,ast'
            setspecs(hd, specs.Order, specs.Fstop, specs.Astop, specs.MagnitudeUnits);
        case 'n,fst,ast,ap'
            setspecs(hd, specs.Order, specs.Fstop, specs.Astop, ...
                specs.Apass, specs.MagnitudeUnits);
        case 'n,fst,f3db'
            setspecs(hd, specs.Order, specs.Fstop, specs.F3dB);
        case 'n,fst,fp'
            setspecs(hd, specs.Order, specs.Fstop, specs.Fpass);
        case 'n,fst,fp,ap'
            setspecs(hd, specs.Order, specs.Fstop, specs.Fpass, ...
                specs.Apass, specs.MagnitudeUnits);
        case 'n,fst,fp,ast'
            setspecs(hd, specs.Order, specs.Fstop, specs.Fpass, ...
                specs.Astop, specs.MagnitudeUnits);
        otherwise
            disp(sprintf('Finish %s', spec));
    end
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end


% [EOF]
