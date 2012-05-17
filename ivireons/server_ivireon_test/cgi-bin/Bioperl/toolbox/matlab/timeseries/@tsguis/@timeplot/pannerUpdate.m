function pannerUpdate(view,h)

% Copyright 2005 The MathWorks, Inc.

%% Panner callback. The position of the panner centers the xlim interval of
%% the axesgrid between the beginning and end of the overall time interval
%% (earliest time of any time series to the lastest time of any time
%% series)
if h.Handles.TimePnl.BarStartPan.getValueIsAdjusting
    return
end

%% Get out of pan mode, since depressing the panner button has turned off
%% the limit manager.
btn = uigettoolbar(ancestor(view.AxesGrid.Parent,'figure'),'Exploration.Pan');
pan(ancestor(view.AxesGrid.Parent,'figure'),'off');


%% Get parameters
timeExtent = view.getExtent;
currentInterval = view.AxesGrid.getxlim{1};

%% Current panner pos
pannerCenterPos = h.Handles.TimePnl.BarStartPan.getValue/100*...
    (timeExtent(2)-timeExtent(1))+timeExtent(1);

%% xinterval
xinterval = currentInterval(2)-currentInterval(1);

%% Move the current axesgrid xlims to that they are centered by the current
%% panner position
if abs(-(currentInterval(2)+currentInterval(1))/2+pannerCenterPos)>.02*xinterval
     newxlims = currentInterval - (currentInterval(2)+currentInterval(1))/2+pannerCenterPos;
     view.AxesGrid.setxlim(newxlims);
     % Send another viewChange (in addition to the one triggered by
     % setxlim) since for the first viewChange the limit picker may not
     % have valid data if caching is on.
     view.AxesGrid.send('ViewChange')  
end
