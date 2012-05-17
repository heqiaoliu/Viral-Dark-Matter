function [success, msg] = setupFDesign(this, varargin)
%SETUPFDESIGN   Setup the contained FDesign.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/10/16 06:38:49 $

success = true;
msg     = '';

hd = get(this, 'FDesign');

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

spec = getSpecification(this, source);

% In the Simulink operating mode the saved specs could require a Filter
% Design Toolbox license that may not be available (read-only mode)
setSpecsSafely(this, hd, spec);

% Evaluate the specifications.  If any of the evaluations fail, leave early
% and only update the Specification.
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
        case 'n,f3db'
            setspecs(hd, specs.Order, specs.F3dB);
        case 'n,f3db,ap'
            setspecs(hd, specs.Order, specs.F3dB, specs.Apass, specs.MagnitudeUnits);
        case 'n,f3db,ap,ast'
            setspecs(hd, specs.Order, specs.F3dB, specs.Apass, ...
                specs.Astop, specs.MagnitudeUnits);
        case 'n,f3db,ast'
            setspecs(hd, specs.Order, specs.F3dB, specs.Astop, specs.MagnitudeUnits);
        case 'n,f3db,fst'
            setspecs(hd, specs.Order, specs.F3dB, specs.Fstop);
        case 'n,fc'
            setspecs(hd, specs.Order, specs.F6dB);
        case 'n,fc,ap,ast'
            setspecs(hd, specs.Order, specs.F6dB, specs.Apass, ...
                specs.Astop, specs.MagnitudeUnits);
        case 'n,fp,ap'
            setspecs(hd, specs.Order, specs.Fpass, specs.Apass, specs.MagnitudeUnits);
        case 'n,fp,ap,ast'
            setspecs(hd, specs.Order, specs.Fpass, specs.Apass, ...
                specs.Astop, specs.MagnitudeUnits);
        case 'n,fp,f3db'
            setspecs(hd, specs.Order, specs.Fpass, specs.F3dB);
        case 'n,fp,fst'
            setspecs(hd, specs.Order, specs.Fpass, specs.Fstop);
        case 'n,fp,fst,ap'
            setspecs(hd, specs.Order, specs.Fpass, specs.Fstop, ...
                specs.Apass, specs.MagnitudeUnits);
        case 'n,fp,fst,ast'
            setspecs(hd, specs.Order, specs.Fpass, specs.Fstop, ...
                specs.Astop, specs.MagnitudeUnits);
        case 'n,fst,ap,ast'
            setspecs(hd, specs.Order, specs.Fstop, specs.Apass, ...
                specs.Astop, specs.MagnitudeUnits);
        case 'n,fst,ast'
            setspecs(hd, specs.Order, specs.Fstop, specs.Astop, specs.MagnitudeUnits);
        otherwise
            disp(sprintf('Finish %s', spec));
    end
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end

% [EOF]
