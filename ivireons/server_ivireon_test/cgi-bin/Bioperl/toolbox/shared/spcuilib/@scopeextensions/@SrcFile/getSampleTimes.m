function sampleTimes = getSampleTimes(this, index)
%GETSAMPLETIMES Get the sampleTimes.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:41:52 $

sampleTimes = 1/this.Data.FrameRate;

% [EOF]
