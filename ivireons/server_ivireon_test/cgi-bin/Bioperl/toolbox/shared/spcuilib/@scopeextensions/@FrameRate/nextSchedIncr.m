function nextIncr = nextSchedIncr(this)
%nextSchedIncr Get next frame increment from scheduler
%  Schedule is based on .sched_showCount and
%                       .sched_skipCount properties
%
%   this.source_fps  -> original rate of data source
%   this.desired_fps -> desired playback rate
%   this.sched_fps   -> rate we drive the timer
%   this.sched_showCount -> part of schedule for frame playback
%   this.sched_skipCount -> part of schedule for frame playback
%
%   If we show 5 then drop 1, showCount=5, skipCount=1
%        (1.2x increase in frame rate)
%   If we show 1 then drop 1, showCount=1, skipCount=1
%        (2x increase in frame rate)
%
%   (output rate) = (input rate) * (showCount+skipCount)/showCount

%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/23 19:04:43 $

if this.SchedShowCount == 1
    % don't bother with the counter:
    nextIncr = 1 + this.SchedSkipCount;
else
    % More complex timing - increment counter:
    this.SchedCounter = 1 + this.SchedCounter;
    
    if this.SchedCounter == this.SchedShowCount
        % skip frames
        this.SchedCounter = 0;
        nextIncr = 1+this.SchedSkipCount;
    else
        % unity increment, no skip:
        nextIncr = 1;
    end
end

% [EOF]
