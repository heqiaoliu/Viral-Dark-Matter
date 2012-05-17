function [success, msg] = setupFDesign(this, varargin)
%SETUPFDESIGN   Setup the contained FDesign.

%   Author(s): J. Schickler
%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/04/11 20:36:39 $

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

    if strncmpi(specs.FrequencyUnits, 'normalized', 10)
        normalizefreq(hd);
    else
        normalizefreq(hd, false, specs.InputSampleRate);
    end

    switch spec
        case 'fp1,fst1,fst2,fp2,ap1,ast,ap2'
            setspecs(hd, specs.Fpass1, specs.Fstop1, specs.Fstop2, specs.Fpass2, ...
                specs.Apass1, specs.Astop, specs.Apass2, specs.MagnitudeUnits);
        case 'n,f3db1,f3db2'
            setspecs(hd, specs.Order, specs.F3dB1, specs.F3dB2);
        case 'n,f3db1,f3db2,ap'
            setspecs(hd, specs.Order, specs.F3dB1, specs.F3dB2, ...
                specs.Apass, specs.MagnitudeUnits);
        case 'n,f3db1,f3db2,ap,ast'
            setspecs(hd, specs.Order, specs.F3dB1, specs.F3dB2, ...
                specs.Apass,specs.Astop, specs.MagnitudeUnits);
        case 'n,f3db1,f3db2,ast'
            setspecs(hd, specs.Order, specs.F3dB1, specs.F3dB2, ...
                specs.Astop, specs.MagnitudeUnits);
        case 'n,f3db1,f3db2,bwp'
            setspecs(hd, specs.Order, specs.F3dB1, specs.F3dB2, specs.BWpass);
        case 'n,f3db1,f3db2,bwst'
            setspecs(hd, specs.Order, specs.F3dB1, specs.F3dB2, specs.BWstop);
        case 'n,fc1,fc2'
            setspecs(hd, specs.Order, specs.F6dB1, specs.F6dB2);
        case 'n,fc1,fc2,ap1,ast,ap2'
            setspecs(hd, specs.Order, specs.F6dB1, specs.F6dB2, specs.Apass1, ...
                specs.Astop, specs.Apass2);
        case 'n,fp1,fp2,ap'
            setspecs(hd, specs.Order, specs.Fpass1, specs.Fpass2, ...
                specs.Apass, specs.MagnitudeUnits);
        case 'n,fp1,fp2,ap,ast'
            setspecs(hd, specs.Order, specs.Fpass1, specs.Fpass2, ...
                specs.Apass, specs.Astop, specs.MagnitudeUnits);
        case 'n,fp1,fst1,fst2,fp2'
            setspecs(hd, specs.Order, specs.Fpass1, specs.Fstop1, ...
                specs.Fstop2, specs.Fpass2);
        case 'n,fp1,fst1,fst2,fp2,ap'
            setspecs(hd, specs.Order, specs.Fpass1, specs.Fstop1, specs.Fstop2, ...
                specs.Fpass2,specs.Apass, specs.MagnitudeUnits);
        case 'n,fst1,fst2,ast'
            setspecs(hd, specs.Order, specs.Fstop1, specs.Fstop2, ...
                specs.Astop, specs.MagnitudeUnits);
        otherwise
            disp(sprintf('Finish %s', spec));
    end
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end


% [EOF]
