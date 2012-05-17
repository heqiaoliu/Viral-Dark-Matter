function update(h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Maintain listeners to the current view member time series to keep the
%% table up to date
import com.mathworks.toolbox.timeseries.*;

%% Find the time series in the view 
if ~isempty(h.ViewNode) && ishandle(h.ViewNode)
    timePlot = h.ViewNode.Plot;
else % Node has been deleted, remove time series listeners
    h.StateListeners.Timeseries = [];
    return
end

%% If the viewNode has just been created there will not yet be a timePlot.
%% In this case open an empty table
%% TO DO: Deal with absolute times
if ~isempty(timePlot) && ishandle(timePlot)
    tsList = timePlot.getTimeSeries;
    
    % Update the datachange listeners
    delete(h.StateListeners.Timeseries)
    h.StateListeners.Timeseries = [];
    for k=1:length(tsList)
        h.StateListeners.Timeseries = [h.StateListeners.Timeseries; ...
            handle.listener(tsList{k},'datachange',@(es,ed) eventsupdate(h,tsList{k}))];
    end    
    
    % Listeners to keep time units and time formats updated
    if isempty(h.UnitListener)
        h.UnitListener = [handle.listener(timePlot.AxesGrid,'ViewChange',...
            {@localSetTimeUnits h.Handles.LBLunits timePlot});...
                          handle.listener(timePlot,timePlot.findprop('Absolutetime'),...
             'PropertyPostSet',@(es,ed) eventsupdate(h))];
            
    end
    localSetTimeUnits([],[],h.Handles.LBLunits,timePlot);
else
    timeseriesNames = cell(0,1);
    timeShifts = cell(0,1);
    tsnames = {''};
    tsList = [];
    set(h.Handles.LBLunits,'String','')
end

%% Reset the time shift/events table
tsnames = {};
tsPath = {};
for k=length(tsList):-1:1
    tsPath{k} = constructNodePath(h.ViewNode.getRoot.find('Timeseries',tsList{k}));
end
h.Handles.tsTable.setTableData(tsPath);
h.eventsupdate

function localSetTimeUnits(es,ed,LBLunits,timePlot)

%% TimePlot unit change callback
if strcmp(timePlot.Absolutetime,'off')
    set(LBLunits,'String',sprintf('Plot time units: %s',...
            timePlot.TimeUnits))
else
    set(LBLunits,'String','')
end