function [success, msg] = setupFDesign(this, varargin)
%SETUPFDESIGN Set the upFDesign

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/02/13 15:13:30 $

success = true;
msg     = '';

hd = get(this, 'FDesign');

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

spec = getSpecification(this, source);
set(hd, 'Specification', spec);

% Evaluate the specifications.  If any of the evaluations fail, leave early
% and only update the Specification.
try
    specs = getSpecs(this, source);

    if strncmpi(source.FrequencyUnits, 'normalized', 10)
        normalizefreq(hd);
    else
        normalizefreq(hd, false, specs.InputSampleRate);
    end
    
    % Set up the fdesign for the current specification.
    switch lower(spec)
        case 'f0,bw,bwp,gref,g0,gbw,gp'
            setspecs(hd, specs.F0, specs.BW, specs.BWpass, specs.Gref, ...
                specs.G0, specs.GBW, specs.Gpass);
        case 'f0,bw,bwst,gref,g0,gbw,gst'
            setspecs(hd, specs.F0, specs.BW, specs.BWstop, specs.Gref, ...
                specs.G0, specs.GBW, specs.Gstop);
        case 'f0,bw,bwp,gref,g0,gbw,gp,gst'
            setspecs(hd, specs.F0, specs.BW, specs.BWpass, specs.Gref, ...
                specs.G0, specs.GBW, specs.Gpass, specs.Gstop);
        case 'n,f0,bw,gref,g0,gbw'
            setspecs(hd, specs.Order, specs.F0, specs.BW, specs.Gref, ...
                specs.G0, specs.GBW);
        case 'n,f0,bw,gref,g0,gbw,gp'
            setspecs(hd, specs.Order, specs.F0, specs.BW, specs.Gref, ...
                specs.G0, specs.GBW, specs.Gpass);
        case 'n,f0,bw,gref,g0,gbw,gst'
            setspecs(hd, specs.Order, specs.F0, specs.BW, specs.Gref, ...
                specs.G0, specs.GBW, specs.Gstop);
        case 'n,f0,bw,gref,g0,gbw,gp,gst'
            setspecs(hd, specs.Order, specs.F0, specs.BW, specs.Gref, ...
                specs.G0, specs.GBW, specs.Gpass, specs.Gstop);
        case 'n,f0,qa,gref,g0'
            setspecs(hd, specs.Order, specs.F0, specs.Qa, specs.Gref, ...
                specs.G0);    
        case 'n,f0,fc,qa,g0'
            setspecs(hd, specs.Order, specs.F0, specs.Fc, specs.Qa, ...
                specs.G0);  
        case 'n,f0,fc,s,g0'
            setspecs(hd, specs.Order, specs.F0, specs.Fc, specs.S, ...
                specs.G0);                                    
        case 'n,flow,fhigh,gref,g0,gbw'
            setspecs(hd, specs.Order, specs.Flow, specs.Fhigh, specs.Gref, ...
                specs.G0, specs.GBW);
        case 'n,flow,fhigh,gref,g0,gbw,gp'
            setspecs(hd, specs.Order, specs.Flow, specs.Fhigh, specs.Gref, ...
                specs.G0, specs.GBW, specs.Gpass);
        case 'n,flow,fhigh,gref,g0,gbw,gst'
            setspecs(hd, specs.Order, specs.Flow, specs.Fhigh, specs.Gref, ...
                specs.G0, specs.GBW, specs.Gstop);
        case 'n,flow,fhigh,gref,g0,gbw,gp,gst'
            setspecs(hd, specs.Order, specs.Flow, specs.Fhigh, specs.Gref, ...
                specs.G0, specs.GBW, specs.Gpass, specs.Gstop);
        otherwise
            disp(sprintf('Finish %s', spec));
    end
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end

% [EOF]
