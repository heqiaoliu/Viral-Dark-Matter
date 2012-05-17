function latency = set_latency(this, latency)
%SET_LATENCY   PreSet function for the 'latency' property.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:57:18 $

if isempty(latency) || (isnumeric(latency) && (round(latency)~=latency) || latency<0) || ...
        isnan(latency) || ~isfinite(latency),
    error(generatemsgid('InvalidLatency'),xlate('Latency must be a positive integer.'));
end
this.privnstates = latency;
reset(this);

% clear metadata
clearmetadata(this);

latency = [];



% [EOF]
