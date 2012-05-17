function set_impulseresponse(this, oldImpulseResponse)
%SET_IMPULSERESPONSE   PostSet function for the 'impulseresponse' property.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:15:59 $

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

updateFreqConstraints(this);

% [EOF]
