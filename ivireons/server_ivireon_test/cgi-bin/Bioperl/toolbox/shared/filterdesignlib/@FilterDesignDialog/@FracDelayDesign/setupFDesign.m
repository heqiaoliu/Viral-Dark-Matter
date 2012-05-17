function [success, msg] = setupFDesign(this, varargin)
%SETUPFDESIGN   Set the upFDesign.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/05/31 23:24:33 $

success = true;
msg     = '';

hd = get(this, 'FDesign');

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

    set(hd, 'FracDelay', specs.FracDelay, 'FilterOrder', specs.Order);
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end

% [EOF]
