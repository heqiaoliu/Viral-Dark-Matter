function plot(h, chan)
%PLOT  Plot multipath channel data in multipath figure object.

%   Copyright 1996-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/05/20 01:58:15 $

% Return if the figure window has been closed.
if isempty(h.FigureHandle)
    return
end

% Get UI handles.
uiHandles = h.UIHandles;
animationMenu = uiHandles.AnimationMenu;
hSlider = uiHandles.Slider;
pauseButton = uiHandles.PauseButton;

% Enable pause button.
set(pauseButton, 'Enable', 'on');

% If in pause mode, need to wait before plotting new data.
if (get(pauseButton, 'Value')==1)
    blk = h.CurrentChannel.SimulinkBlock;
    if isempty(blk)
        % MATLAB mode
        uiwait(h.FigureHandle);
    else
        % Simulink mode
        set_param(bdroot(blk), 'simulationcommand', 'pause');
    end
    % Return if the figure window has been closed.
    if isempty(h.FigureHandle)
        return
    end
end

% Use current channel if no new multipath channel object passed.
if (nargin==1)
    chan = h.CurrentChannel;
end

% Reset figure if required.
if (chan.FigNeedsToBeReset)
    h.reset;
    chan.FigNeedsToBeReset = false;
end

% Store new channel if the number of frames processed has increased since
% last plot.  Note that there will be a discontinuity of the number of
% frames has increased by more than 1.
if (h.NumFramesPlotted<chan.NumFramesProcessed)

    % Store new channel with multipath figure object.
    h.CurrentChannel = chan;

    % Store new channel with *all* axes objects.
    % Alternative (for speed): store data only for *active* axes objects.
    axObjs = h.AxesObjects;
    for m = 1:h.NumAxes
        newchannel(axObjs{m}, chan);
    end

end

% Set channel stored flags to 1.
boolVal = true;
h.ChannelStored = boolVal(ones(1, h.NumAxes));

% Get counters and calculate/store time-related info.
numSampProc = chan.NumSamplesProcessed;
buffSize = chan.PGAndTGBufferSizes;
Ts = chan.InputSamplePeriod;
h.FramePeriod = buffSize*Ts;
h.FrameStartTime = (numSampProc-buffSize)*Ts;

% If buffer size has changed, initialize slider limits and value (slider
% step is set in the setanimation method, below).
if (get(hSlider, 'max')~=buffSize)
     set(hSlider, 'min', 1, 'max', buffSize, 'value', buffSize);
end

% Initialize animation conditions.  This also sets the slider step.
h.setanimation;

% Display frame count.
set(uiHandles.FrameCount, 'string', num2str(chan.NumFramesProcessed));

% Update multipath axes schedule.  This can be influenced by the multipath
% channel properties.
h.updateschedule;

% The time stamp is a normalized timing metric: 0<=t<=1.  For animations,
% it is initialized to zero.  It is incremented throughout the animation
% according to a schedule dictated by the multipath axes objects.  It can
% be decremented manually, via slider.  Once it has reached the final time
% in the schedule, the updating of all multipath axes objects is completed.
if (get(animationMenu, 'Value')==1 || get(pauseButton, 'Value')==1)
    val = get(hSlider, 'Value');
    h.CurrentTime = (round(val)-1)/buffSize;
else
    h.CurrentTime = 0.0;
    h.Animating = true;
end

% Plot channel snapshots.
plotsnapshots(h);

h.Animating = false;

% Set channel stored flags to 0.
boolVal = false;
h.ChannelStored = boolVal(ones(1, h.NumAxes));

% Store number of frames plotted.
h.NumFramesPlotted = chan.NumFramesProcessed;
