function reset(h)
%RESET  Reset multipath figure object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/05/31 02:45:12 $

% Return if the figure window has been closed.
if isempty(h.FigureHandle)
    return
end

% Reset multipath axes objects.
axesObjs = h.AxesObjects;
for m = 1:length(axesObjs)
    ax = axesObjs{m};
    ax.reset;
    ax.Active = false;
end

% This method sets positions of the axes and uicontrols.
h.setfigposition;

% Initialize "channel stored" flags.  These keep track of which multipath
% axes objects have knowledge of the most recent multipath channel object.
falseBool = false;
h.ChannelStored = falseBool(ones(1, h.NumAxes));

% Set current multipath axes.
for axesIdx = h.CurrentAxesIdx
    h.AxesObjects{axesIdx}.Active = true;
end

% Initialize number of frames plotted.
h.NumFramesPlotted = 0;
