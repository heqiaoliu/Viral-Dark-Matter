function sampleTimes = getSampleTimes(this, index)
%GETSAMPLETIMES Get the sampleTimes.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:44 $

sampleTimes = this.SampleTimes;

if nargin > 1
    sampleTimes = sampleTimes(index);
end

% [EOF]
