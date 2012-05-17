function createPlaybackSchedule(this)
%createPlaybackSchedule Compute a playback schedule.
%  Determine playback schedule to use, impacting both
%  timer rate and frame skip factor

%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/06/13 15:28:44 $

% Always reset skip-counter when new schedule is created.
this.SchedCounter = 0;

[warn_str, warn_id] = lastwarn;
lastwarn('');
w = warning('off', ...
    'spcuilib:scopeextensions:FrameRate:calculatePlaybackSchedule:PlaybackScheduleFailure');

% Calculate 
[fps, show, skip] = calculatePlaybackSchedule(this);

if ~isempty(lastwarn)
    warndlg(lastwarn, 'Frame Rate');
end

lastwarn(warn_str, warn_id);
warning(w);

this.SchedFPS       = fps;
this.SchedShowCount = show;
this.SchedSkipCount = skip;

% [EOF]
