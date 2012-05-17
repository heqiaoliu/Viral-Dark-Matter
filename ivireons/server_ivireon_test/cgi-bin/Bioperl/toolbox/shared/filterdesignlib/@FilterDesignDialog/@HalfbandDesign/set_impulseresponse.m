function set_impulseresponse(this, oldImpulseResponse) %#ok
%SET_IMPULSERESPONSE PreSet function for the 'impulseresponse' property

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:42:30 $

impulseresponse = get(this, 'ImpulseResponse');

% Fix the magnitude units if they do not match the new impulse response.
if strcmpi(impulseresponse, 'fir') && strcmpi(this.MagnitudeUnits, 'squared')
    this.MagnitudeUnits = 'db';
elseif strcmpi(impulseresponse, 'iir') && strcmpi(this.MagnitudeUnits, 'linear')
    this.MagnitudeUnits = 'db';
end

% Fix the filtertype if multirates cannot be designed.
if strcmpi(impulseresponse, 'iir') && strcmpi(this.Type, 'highpass')
    set(this, 'FilterType', 'single-rate')
end

updateFreqConstraints(this);

% [EOF]
