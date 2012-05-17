function [success, msg] = setupFDesign(this, varargin)
%SETUPFDESIGN   Setup the contained FDesign.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:56:45 $

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

    switch lower(spec)
        case 'n,bw'
            setspecs(hd, specs.CombType, specs.Order, specs.BW);
        case 'n,q'
            setspecs(hd, specs.CombType, specs.Order, specs.Q);
        case 'l,bw,gbw,nsh'
            setspecs(hd, specs.CombType, specs.NumPeaksOrNotches, specs.BW, ...
                specs.GBW, specs.ShelvingFilterOrder);
        otherwise
            fprintf('Finish %s', spec);
    end
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end

% [EOF]
