function updateTimeStatus(this)
%UPDATETIMESTATUS Update the time status.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:42:07 $

if this.FrameCount == 0
    timeStatus = '';
else
    timeStatus = getTimeStatusString(this.DataHandler);
end
this.FrameCountStatusBar.Text = timeStatus;

% [EOF]
