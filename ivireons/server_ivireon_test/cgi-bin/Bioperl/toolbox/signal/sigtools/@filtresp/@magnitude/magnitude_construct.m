function allPrm = magnitude_construct(this, varargin)
%MAGNITUDE_CONSTRUCT Construct a magresp object

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.3.4.7 $  $Date: 2007/12/14 15:17:19 $

set(this, 'Name', 'Magnitude Response');

allPrm = this.frequencyresp_construct(varargin{:});

createparameter(this, allPrm, 'Magnitude Display', 'magnitude', ...
    {'Magnitude', 'Magnitude (dB)', 'Magnitude squared', 'Zero-phase'}, ...
    'Magnitude (db)');

createparameter(this, allPrm, 'Normalize Magnitude to 1 (0 dB)', ...
    'normalize_magnitude', 'on/off', 'off');

l = handle.listener(this.FilterUtils, this.FilterUtils.findprop('Filters'), ...
    'PropertyPostSet', @lclfilters_listener);
set(l, 'CallbackTarget', this);
set(this, 'MagnitudeFilterListeners', l);

lclfilters_listener(this);

% -----------------------------------------------------------
function checkrange(value)

if ~isa(value, 'double') || length(value) ~= 2
    error(generatemsgid('InvalidDimensions'),'The dB Display Range must be a double vector of length 2.');
end

% -----------------------------------------------------------
function lclfilters_listener(this, eventData)

hPrm = getparameter(this, 'magnitude');
if isreal(this),
    enableoption(hPrm, 'zero-phase');
else
    disableoption(hPrm, 'zero-phase');
end

% [EOF]
