function thisTab = timepnl(view,h)

%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $ $Date: 2009/03/09 19:23:25 $

import com.mathworks.toolbox.timeseries.*;

%% Build time panel
TimePnl = tsDomainTimePanel;
thisTab = struct('Name','Domain','Handles',[]);
h.Handles.TimePnl = TimePnl;
thisTab.Name = 'Domain';
h.Tabs = [h.Tabs; thisTab];
h.Handles.TabPane.add(xlate('Define Domain'),TimePnl);     

%% Get time/date format
[formatstrs,absstatus] = tsgetDateFormat;
relformats = get(findtype('TimeUnits'),'String');
absformats = formatstrs([absstatus{:}]);
TimePnl.relformats = relformats;
TimePnl.absformats = absformats;

%% Get the initial state of the view
[isformatted,absflag] = tsIsDateFormat(view.TimeFormat);
if strcmp(view.Absolutetime,'off')
    % Set the units/format
    if ~absflag && ~isempty(view.TimeFormat)
        ind = find(strcmp(view.TimeFormat,relformats));    
    elseif isformatted
        ind = find(strcmp(view.TimeUnits,relformats));
    else
        ind = find(strcmp(view.TimeUnits,relformats));
    end
    TimePnl.setabstimemode(false,ind-1);
else
    % Set the units/format
    if absflag && isformatted
        ind = find(strcmp(view.TimeFormat,absformats));    
    else
        ind = 1;
    end
    TimePnl.setabstimemode(true,ind-1);
end    
    
%% Set the callbacks
set(handle(TimePnl.TXTEndTime,'callbackproperties'),...
    'ActionPerformedCallback',{@localTimeUpdate h view})
set(handle(TimePnl.TXTEndTime,'callbackproperties'),...
    'FocusLostCallback',{@localTimeUpdate h view})
set(handle(TimePnl.TXTStartTime,'callbackproperties'),...
    'ActionPerformedCallback',{@localTimeUpdate h view})
set(handle(TimePnl.TXTStartTime,'callbackproperties'),...
    'FocusLostCallback',{@localTimeUpdate h view})
set(handle(TimePnl.RADIOStartTime,'callbackproperties'),...
    'ActionPerformedCallback',{@localTimeUpdate h view})
set(handle(TimePnl.RADIOStartEvent,'callbackproperties'),...
    'ActionPerformedCallback',{@localTimeUpdate h view})
set(handle(TimePnl.COMBOStartEvent,'callbackproperties'),...
    'ItemStateChangedCallback',{@localTimeUpdate h view})
set(handle(TimePnl.COMBOStartEvent,'callbackproperties'),...
    'ActionPerformedCallback',{@localSetStartRadioSelected h view});
set(handle(TimePnl.RADIOEndTime,'callbackproperties'),...
    'ActionPerformedCallback',{@localTimeUpdate h view})
set(handle(TimePnl.RADIOEndEvent,'callbackproperties'),...
    'ActionPerformedCallback',{@localTimeUpdate h view})
set(handle(TimePnl.COMBOEndEvent,'callbackproperties'),...
    'ItemStateChangedCallback',{@localTimeUpdate h view})
set(handle(TimePnl.COMBOEndEvent,'callbackproperties'),...
    'ActionPerformedCallback',{@localSetEndRadioSelected h view});
set(handle(TimePnl.RADIOAbsTime,'callbackproperties'),...
    'ActionPerformedCallback',{@localAbsRelChange h view})
set(handle(TimePnl.RADIORelTime,'callbackproperties'),...
    'ActionPerformedCallback',{@localAbsRelChange h view})
set(handle(TimePnl.COMBformatunits,'callbackproperties'),...
    'ItemStateChangedCallback',{@localUnitChange h view})
set(handle(TimePnl.BTNHelp,'callbackproperties'),...
    'ActionPerformedCallback','tsDispatchHelp(''pe_time_plot'',''modal'')');
TimePnl.BarStartPan.setCallback(view,{h});
set(handle(TimePnl.BTNResetTime,'callbackproperties'),'ActionPerformedCallback',...
    {@localSetTimeAuto view});


%% Fire the time type button group callback
if strcmp(view.Absolutetime,'on')
   view.settimemode(h,'absolute') 
else
   view.settimemode(h,'relative')
end

%% Get time axes limits
if ~isempty(view.PropEditor)
    view.updatetime(h)
end
localUnitChange([],[],h,view)

function localTimeUpdate(eventSrc,eventData,h,view)

%% Callback for start and end time edit boxes which updates the AxesGrid

%% Quick return if plot is being deleted
if isempty(view) || ~ishandle(view)
    return
end

%% Get out of pan mode, since depressing the panner button has turned off
%% the limit manager.
pan(ancestor(view.AxesGrid.Parent,'figure'),'off');

%% If in abs time mode re-format the datstrs
if h.Handles.TimePnl.RADIOAbsTime.isSelected
    if h.Handles.TimePnl.RADIOStartTime.isSelected
        try
            if ~isempty(view.TimeFormat) && tsIsDateFormat(view.TimeFormat)
                starttime = (datenum(char(h.Handles.TimePnl.TXTStartTime.getText),view.TimeFormat)...
                     -datenum(view.Startdate))*tsunitconv(view.TimeUnits,'days');
            else    
                starttime = (datenum(char(h.Handles.TimePnl.TXTStartTime.getText))...
                     -datenum(view.Startdate))*tsunitconv(view.TimeUnits,'days');
            end
        catch
            errordlg('Invalid start time','Time Series Tools','modal')
            updatetime(view,h);
            return
        end    
    else
        [eventlist,eventParentList] = view.Parent.getevents;
        ind = h.Handles.TimePnl.COMBOStartEvent.getSelectedIndex+1;
        
        if ~isempty(eventlist(ind).StartDate) && ~isempty(view.StartDate)
            absevtime = datenum(eventlist(ind).StartDate)+...
                eventlist(ind).Time*tsunitconv('days',eventlist(ind).Units);
            starttime = (absevtime-datenum(view.StartDate))*tsunitconv(view.TimeUnits,'days');
        else
            starttime = eventlist(ind).Time*...
                tsunitconv(view.TimeUnits,eventParentList{ind}.TimeInfo.Units);
        end
    end    
     
    if h.Handles.TimePnl.RADIOEndTime.isSelected    
        try
            if ~isempty(view.TimeFormat) && tsIsDateFormat(view.TimeFormat)
                 endtime = (datenum(char(h.Handles.TimePnl.TXTEndTime.getText),view.TimeFormat)...
                     -datenum(view.Startdate))*tsunitconv(view.TimeUnits,'days');           
            else
                 endtime = (datenum(char(h.Handles.TimePnl.TXTEndTime.getText))...
                     -datenum(view.Startdate))*tsunitconv(view.TimeUnits,'days');
            end
        catch %#ok<*CTCH>
           errordlg('Invalid end time','Time Series Tools','modal')
           updatetime(view,h);
           return
        end
    else
        [eventlist,eventParentList] = view.Parent.getevents;
        ind = h.Handles.TimePnl.COMBOEndEvent.getSelectedIndex+1;
        if ~isempty(eventlist(ind).StartDate) && ~isempty(view.StartDate)
            absevtime = datenum(eventlist(ind).StartDate)+...
                eventlist(ind).Time*tsunitconv('days',eventlist(ind).Units);
            endtime = (absevtime-datenum(view.StartDate))*tsunitconv(view.TimeUnits,'days');
        else
            endtime = eventlist(ind).Time*tsunitconv(view.TimeUnits,...
                eventParentList{ind}.TimeInfo.Units);
        end
    end
        
else % Relative mode
    if h.Handles.TimePnl.RADIOStartTime.isSelected
        thisformat =  h.Handles.TimePnl.COMBformatunits.getSelectedItem;
        % Try to parse any datastrs
        if tsIsDateFormat(thisformat)
             try
                 starttime = datenum(char(h.Handles.TimePnl.TXTStartTime.getText))...
                     -datenum('00:00:00');
                 starttime = tsunitconv(view.TimeUnits,'days')*starttime;
             catch 
                 starttime = [];
             end
             if isempty(starttime) || ~isscalar(starttime) || ~isfinite(starttime)
                 updatetime(view,h);
                 return
             end
        else
             try
                 starttime = eval(char(h.Handles.TimePnl.TXTStartTime.getText));
             catch
                 starttime = [];
             end
             if isempty(starttime) || ~isscalar(starttime) || ~isfinite(starttime)
                errordlg('Invalid start time','Time Series Tools','modal')
                updatetime(view,h);
                return
             end
        end
    else
        [eventlist,eventParentList] = view.Parent.getevents;
        ind = h.Handles.TimePnl.COMBOStartEvent.getSelectedIndex+1;
        starttime = eventlist(ind).Time*tsunitconv(view.TimeUnits,eventParentList{ind}.TimeInfo.Units);
    end
    if h.Handles.TimePnl.RADIOEndTime.isSelected
        thisformat =  h.Handles.TimePnl.COMBformatunits.getSelectedItem;
        % Try to parse any datastrs
        if tsIsDateFormat(thisformat)
             try
                 endtime = datenum(char(h.Handles.TimePnl.TXTEndTime.getText))...
                     -datenum('00:00:00');
                 endtime = tsunitconv(view.TimeUnits,'days')*endtime;
             catch
                 endtime = [];
             end
             if isempty(endtime) || ~isscalar(endtime) || ~isfinite(endtime)
                 updatetime(view,h);
                 return
             end   
        else
            try
                endtime = eval(char(h.Handles.TimePnl.TXTEndTime.getText));
            catch
                endtime = [];
            end
            if isempty(endtime) || ~isscalar(endtime) || ~isfinite(endtime)
                errordlg('Invalid end time','Time Series Tools','modal')
                updatetime(view,h);
                return
            end
        end
    else
        [eventlist,eventParentList] = view.Parent.getevents;
        ind = h.Handles.TimePnl.COMBOEndEvent.getSelectedIndex+1;
        endtime = eventlist(ind).Time*tsunitconv(view.TimeUnits,eventParentList{ind}.TimeInfo.Units);
    end
end

%% Prevent triggering an unnecessary viewChange event if nothing has
%% changed
currentXLims = view.AxesGrid.getxlim;
currentXLims = currentXLims{1};
if starttime==currentXLims(1) && endtime==currentXLims(2)
    return
end
if endtime>starttime 
    view.AxesGrid.setxlim([starttime endtime]);
elseif endtime==starttime % 1e-4 is the rounding error produced by sprintf('%0.4g
    view.AxesGrid.setxlim([starttime-1e-4 endtime+1e-4]);
else % Start time is after end time - revert
    errordlg('End time precedes start time','Time Series Tools','modal')
    if ~isempty(eventData) && ~isempty(eventData.getSource)
        if isequal(handle(h.Handles.TimePnl.RADIOStartEvent),handle(eventData.getSource)) || ...
                isequal(handle(h.Handles.TimePnl.COMBOStartEvent),handle(eventData.getSource)) 
            awtinvoke(h.Handles.TimePnl.RADIOStartTime,'setSelected(Z)',true);
            drawnow
        end
        if isequal(handle(h.Handles.TimePnl.RADIOEndEvent),handle(eventData.getSource)) || ...
                isequal(handle(h.Handles.TimePnl.COMBOEndEvent),handle(eventData.getSource))
            awtinvoke(h.Handles.TimePnl.RADIOEndTime,'setSelected(Z)',true);
            drawnow
        end
    end
    updatetime(view,h);
end

function localAbsRelChange(es,ed,h,view) %#ok<*INUSL>

%% Callback to the absolute/relative time radio buttons

%% Get out of pan mode, since depressing the panner button has turned off
%% the limit manager.
pan(ancestor(view.AxesGrid.Parent,'figure'),'off');

if h.Handles.TimePnl.RADIORelTime.isSelected
    view.StartDate = '';
    view.settimemode(h,'relative')
else
    view.TimeFormat = 'dd-mmm-yyyy HH:MM:SS';
    % If the view has no start date base it on the start data of one of the
    % the timeseries. Otherwise resort to now...
    if isempty(view.StartDate)       
        tsList = view.getTimeSeries;
        if numel(tsList)>=1
            view.StartDate  = tsList{1}.TimeInfo.StartDate;
        else
            view.StartDate = datestr(floor(now));
        end
    end
    if isempty(view.StartDate)
        h.Handles.TimePnl.showErrorDlg(xlate('The Time Plot cannot be set to display absolute times because the timeseries has no start date.'));
    else
        view.settimemode(h,'absolute');
    end
end


%% Refresh
S = warning('off','all'); % Disable "Some data is missing @resppack warn..."
view.draw;
warning(S);

function localUnitChange(es,ed,h,view)

import java.awt.event.*;

%% Format/units combo callback. Note that the view change listener will
%% call the refresh method which will update the start and end edit boxes
%% to the right format. If the Time Panel is in an invalid state (abs
%% format selected with relative time radio button or rel time units
%% selected with abs time radio button selected this callback is a no-op)

%% Only respond to selection events
if ~isempty(ed) && ed.getStateChange~=ItemEvent.SELECTED
    return
end

%% Get out of pan mode, since depressing the panner button has turned off
%% the limit manager.
pan(ancestor(view.AxesGrid.Parent,'figure'),'off');

%% Get the selected format
thisformat = h.Handles.TimePnl.COMBformatunits.getSelectedItem;

S = warning('off','all'); % Disable "Some data is missing @resppack warn..."
if ~isempty(view)
     % Absolute time
    if h.Handles.TimePnl.RADIOAbsTime.isSelected && ...
            ~any(strcmp(thisformat,get(findtype('TimeUnits'),'Strings')))
         % Set the @timeplot format 
         view.TimeFormat = thisformat;
         view.Axesgrid.Xunits = '';
         view.Axesgrid.send('Viewchange')
    elseif h.Handles.TimePnl.RADIORelTime.isSelected
         if any(strcmp(thisformat,get(findtype('TimeUnits'),'Strings')))
             view.TimeUnits = thisformat;
             view.TimeFormat = '';
             view.Axesgrid.Xunits = thisformat;
         else
             view.TimeFormat = thisformat; % thisformat could be a relative datestr
         end
    end 
    view.draw;
end

warning(S);
     
function localSetTimeAuto(es,ed,h)

%% Get out of pan mode, since depressing the panner button has turned off
%% the limit manager.
pan(ancestor(h.AxesGrid.Parent,'figure'),'off');

% If the event radio was selected, unselect it
awtinvoke(h.PropEditor.Handles.TimePnl.RADIOEndTime,'setSelected(Z)',true);
awtinvoke(h.PropEditor.Handles.TimePnl.RADIOStartTime,'setSelected(Z)',true);
drawnow
     
h.AxesGrid.xlimmode = 'auto';
% Must recompute foci if data has changed
for k=1:length(h.waves)
    h.waves(k).DataSrc.send('sourcechange');
end
h.AxesGrid.LimitManager = 'on';
h.AxesGrid.send('viewchange')


function localSetStartRadioSelected(es,ed,h,view)

if ed.getModifiers==0
    return
end
awtinvoke(h.Handles.TimePnl.RADIOStartEvent,'setSelected(Z)',true);
drawnow
localTimeUpdate(es,ed,h,view);


function localSetEndRadioSelected(es,ed,h,view)

if ed.getModifiers==0
    return
end
awtinvoke(h.Handles.TimePnl.RADIOEndEvent,'setSelected(Z)',true);
drawnow
localTimeUpdate(es,ed,h,view);