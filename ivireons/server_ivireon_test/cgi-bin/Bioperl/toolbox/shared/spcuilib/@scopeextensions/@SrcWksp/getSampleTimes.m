function sampleTimes = getSampleTimes(this, ~)
%GETSAMPLETIMES Get the sampleTimes.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:42:48 $

sampleTimes = 1/this.Data.FrameRate;

% [EOF]
