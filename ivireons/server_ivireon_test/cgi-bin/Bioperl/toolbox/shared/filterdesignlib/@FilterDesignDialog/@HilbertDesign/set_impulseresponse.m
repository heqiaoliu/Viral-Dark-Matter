function set_impulseresponse(this, oldImpulseResponse)
%SET_IMPULSERESPONSE   PreSet function for the 'impulseresponse' property.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/10/18 03:17:22 $

impulseresponse = get(this, 'ImpulseResponse');

% Fix the magnitude units if they do not match the new impulse response.
if strcmpi(impulseresponse, 'fir') && strcmpi(this.MagnitudeUnits, 'squared')
    this.MagnitudeUnits = 'db';
elseif strcmpi(impulseresponse, 'iir') && strcmpi(this.MagnitudeUnits, 'linear')
    this.MagnitudeUnits = 'db';
end

% Fix the filtertype if multirates cannot be designed.
if strcmpi(impulseresponse, 'iir') && ...
        ~strcmpi(this.FilterType, 'single-rate') && ...
        ~allowsMultirate(this)
    set(this, 'FilterType', 'single-rate')
end

updateMethod(this);

% [EOF]
