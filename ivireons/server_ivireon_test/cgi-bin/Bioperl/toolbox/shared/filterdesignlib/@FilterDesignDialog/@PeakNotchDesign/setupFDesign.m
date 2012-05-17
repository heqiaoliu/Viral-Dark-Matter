function [success, msg] = setupFDesign(this, varargin)
%SETUPFDESIGN Setup the FDesign

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/05/31 23:24:41 $

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

    switch lower(getSpecification(this, source))
        case 'n,f0,q'
            setspecs(hd, specs.Order, specs.F0, specs.Q);
        case 'n,f0,q,ap'
            setspecs(hd, specs.Order, specs.F0, specs.Q, specs.Apass);
        case 'n,f0,q,ast'
            setspecs(hd, specs.Order, specs.F0, specs.Q, specs.Astop);
        case 'n,f0,q,ap,ast'
            setspecs(hd, specs.Order, specs.F0, specs.Q, specs.Apass, specs.Astop);
        case 'n,f0,bw'
            setspecs(hd, specs.Order, specs.F0, specs.BW);
        case 'n,f0,bw,ap'
            setspecs(hd, specs.Order, specs.F0, specs.BW, specs.Apass);
        case 'n,f0,bw,ast'
            setspecs(hd, specs.Order, specs.F0, specs.BW, specs.Astop);
        case 'n,f0,bw,ap,ast'
            setspecs(hd, specs.Order, specs.F0, specs.BW, specs.Apass, specs.Astop);
        otherwise
            disp(sprintf('Finish %s', spec));
    end
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end

% [EOF]
