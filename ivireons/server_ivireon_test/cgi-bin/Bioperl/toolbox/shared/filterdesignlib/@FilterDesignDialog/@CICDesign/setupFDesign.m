function [success, msg] = setupFDesign(this, varargin)
%SETUPFDESIGN   Setup the contained FDesign.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/31 23:24:29 $

success = true;
msg     = '';

hd = get(this, 'FDesign');

if strcmpi(this.FilterType, 'decimator')
    requiredClass = 'fdesign.decimator';
    factorProp    = 'DecimationFactor';
else
    requiredClass = 'fdesign.interpolator';
    factorProp    = 'InterpolationFactor';
end

if ~isa(hd, requiredClass)
    hd = feval(requiredClass);
    set(hd, 'Response', 'CIC');
    set(this, 'FDesign', hd);
end

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

    set(hd, factorProp, specs.Factor);

    setspecs(hd, specs.DifferentialDelay, specs.Fpass, ...
        specs.Astop, specs.MagnitudeUnits);
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end
% [EOF]
