function sampleTimes = getSampleTimes(this, inputIndex)
%GETSAMPLETIMES Get the sampleTimes.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:42:17 $

data = getSignalData(this.SLConnectMgr);
sampleTimes = data.period;
if nargin < 2
    sampleTimes = repmat(sampleTimes, getNumInputs(this), 1);
end

% [EOF]
