function [success, msg] = setupFDesign(this, varargin)
%SETUPFDESIGN   Setup the contained FDesign.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/31 23:24:28 $

success = true;
msg     = '';

hd = get(this, 'FDesign');

spec = getSpecification(this, varargin{:});

set(hd, 'Specification', spec);

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

% Evaluate the specifications.  If any of the evaluations fail, leave early
% and only update the Specification.
try
    specs = getSpecs(this, source);

    if strncmpi(specs.FrequencyUnits, 'normalized', 10)
        normalizefreq(hd);
    else
        normalizefreq(hd, false, specs.InputSampleRate);
    end

    M = specs.DifferentialDelay;
    N = specs.NumberOfSections;

    switch spec
        case 'fp,fst,ap,ast'
            setspecs(hd, M, N, specs.Fpass, specs.Fstop, specs.Apass, ...
                specs.Astop, specs.MagnitudeUnits);
        case 'n,fc,ap,ast'
            setspecs(hd, M, N, specs.Order, specs.F6dB, specs.Apass, ...
                specs.Astop, specs.MagnitudeUnits);
        case 'n,fp,ap,ast'
            setspecs(hd, M, N, specs.Order, specs.Fpass, specs.Apass, ...
                specs.Astop, specs.MagnitudeUnits);
        case 'n,fp,fst'
            setspecs(hd, M, N, specs.Order, specs.Fpass, specs.Fstop);
        case 'n,fst,ap,ast'
            setspecs(hd, M, N, specs.Order, specs.Fstop, specs.Apass, ...
                specs.Astop,specs.MagnitudeUnits);
        case 'n,fst,ast'
            setspecs(hd, M, N, specs.Order, specs.Fstop, specs.Astop, specs.MagnitudeUnits);
        otherwise
            disp(sprintf('Finish %s', spec));
    end
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end

% [EOF]
