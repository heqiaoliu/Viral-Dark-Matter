function refreshsnapshot(h);
%REFRESHSNAPSHOT  Refresh snapshot for multipath figure object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:21:47 $

% This routine sets the current time according to the slider value.  Then,
% if not animating or if paused, it plots the channel snapshot for that
% time.  It is called by uicontrol callbacks, such as selectaxes.

% Get UI handles.
uiHandles = h.UIHandles;

% Set current time.
val = get(uiHandles.Slider, 'Value');
buffSize = h.CurrentChannel.PGAndTGBufferSizes;  % Samples per frame
h.CurrentTime = (round(val)-1)/buffSize;

% If not currently animating graphics or if paused, plot channel snapshot.
if (~h.Animating || get(uiHandles.PauseButton, 'Value')==1)
    h.plotsnapshots;
end

% Note that the schedule isn't really what has been updated.  Setting this
% flag, however, ensures that animations behave correctly.
h.ScheduleUpdated = true;
