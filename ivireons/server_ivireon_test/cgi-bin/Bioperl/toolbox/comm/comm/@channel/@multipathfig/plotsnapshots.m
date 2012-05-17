function plotsnapshots(h)
%PLOTSNAPSHOTS  Plot snapshots for multipath figure object.

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/05/31 23:14:58 $

% Get cell array of multipath axes objects.
axObjs = h.AxesObjects;

% Handles to UI controls/text.
uiHandles = h.UIHandles;
animationMenu = uiHandles.AnimationMenu;
hSlider = uiHandles.Slider;
hPause = uiHandles.PauseButton;
sampleIdxText = uiHandles.SampleIdx;

% Get buffer size and sample period.  These will be used to compute the
% current time of a channel object snapshot.
chan = h.CurrentChannel;
buffSize = chan.PGAndTGBufferSizes;
Ts = chan.InputSamplePeriod;

% This flag is used to make sure the axes update schedule is retrieved the
% first time around the animation loop.
retrievedSchedule = false;

% The following animation code can handle a user event (menu selection) in
% which a new multipath visualization is selected.

% Plotting loop.
plotting = true;
while plotting
            
    % Check whether figure window is still open.
    if isempty(h.FigureHandle)
        return
    end
    
    % Get current time of snapshot.  This can change if interrupted by
    % slider movement.
    t = h.CurrentTime;
        
    % Get the latest axes update schedule.  Due to a user event (menu
    % selection), the schedule may change during the animation loop.  This
    % event will set the flag h.ScheduleUpdated to true.  The loop below is
    % used to handle the case for which the schedule may change while we
    % are retrieving it.
    while (h.ScheduleUpdated || ~retrievedSchedule)
        h.ScheduleUpdated = false;
        tS = h.TimeStampSchedule;
        axIdx = h.AxesIdxSchedule;
        snapIdx = h.SnapshotIdxSchedule;
        retrievedSchedule = true;
        % Find next future time stamp in time stamp vector.
        k = find(t<tS, 1);
    end
    
    % Length of time stamp vector.
    tSLength = length(tS);

    ok = (~isempty(k) && k<=tSLength);
    if (ok)

        % Get time stamp from schedule.
        t = tS(k);
    
        % Save current time.
        h.CurrentTime = t;

        % Calculate and display sample index.  Also save snapshot time.
        sampIdx = round(t*buffSize);
        set(sampleIdxText, 'string', num2str(sampIdx));
        snapTimeOffset = sampIdx*Ts;
        h.CurrentSnapshotTime = h.FrameStartTime + snapTimeOffset;
             
        % The following loop ensures that all axes with same time stamps
        % are updated.
        while (k<=tSLength && tS(k)<=t)
            update(axObjs{axIdx(k)}, snapIdx(k));
            k = k + 1;
        end

    end

    % Update slider position.
    set(hSlider, 'Value', sampIdx);

    if (get(animationMenu, 'Value')==1 || get(hPause, 'Value')==1)
        % "No animation" mode: No further snapshots to plot.
        plotting = false;
    else
        % Animation mode: update slider.        
        plotting = ok;
    end
               
    drawnow
        
end
