function k = getFormattedGain(this)
% GETGain Returns the formatted gain of the TunedMask

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/11/09 16:22:19 $

% If zpkdata is empty update it
if isempty(this.zpkdata)
    this.updateZPK;
end

k = this.zpkdata.k / formatfactor(this);