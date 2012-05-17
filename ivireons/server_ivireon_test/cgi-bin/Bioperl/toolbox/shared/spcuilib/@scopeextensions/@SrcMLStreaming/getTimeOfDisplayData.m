function timeOfDisplayData = getTimeOfDisplayData(this)
%GETTIMEOFDISPLAYDATA Get the timeOfDisplayData.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:42:00 $

frameCount = this.FrameCount;
if frameCount == 0
    timeOfDisplayData = 0;
else
    timeOfDisplayData = (this.FrameCount-1)*max(getSampleTimes(this));
end

% [EOF]
