function updatetime(view,h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Callback for ViewChanged listener which keeps time domain
%% panel updated

xlim = num2cell(view.AxesGrid.getxlim(1));
[isformated,absflag] = tsIsDateFormat(view.TimeFormat);
if strcmp(view.Absolutetime,'on') %Absolute time
    % Convert the xlims to datestrs and write the result to the start
    % end end time edit boxes on the TimePnl
    if ~isempty(view.StartDate)
        if absflag
           xlim{1} = datestr(xlim{1}*tsunitconv('days',view.TimeUnits)+...
               datenum(view.StartDate),view.TimeFormat);
           xlim{2} = datestr(xlim{2}*tsunitconv('days',view.TimeUnits)...
               +datenum(view.StartDate),view.TimeFormat);
        else
           xlim{1} = datestr(xlim{1}*tsunitconv('days',view.TimeUnits)+...
               datenum(view.StartDate));
           xlim{2} = datestr(xlim{2}*tsunitconv('days',view.TimeUnits)...
               +datenum(view.StartDate));
        end
    else
       xlim = {'',''}; 
    end
    awtinvoke(h.Handles.TimePnl.TXTStartTime,'setText(Ljava.lang.String;)',xlim{1});
    awtinvoke(h.Handles.TimePnl.TXTEndTime,'setText(Ljava.lang.String;)',xlim{2});
    % Sets the format in the @timeplot and the TimePnl to the current
    % timeseries format
    formats = {};
    for k=1:h.Handles.TimePnl.COMBformatunits.getItemCount
        formats = [formats; {h.Handles.TimePnl.COMBformatunits.getItemAt(k-1)}];
    end
    ind = find(strcmp(view.TimeFormat,formats));
    localSetMode(h,true,ind)
else  % Relative time
    units = h.Handles.TimePnl.COMBformatunits.getSelectedItem;
    if isformated && ~absflag % Time vector is formated
        % Parse xlim into a formatted time string a write the result
        % to the start and end time edit boxes
        xlow = datestr(xlim{1}*...
          tsunitconv('days',view.TimeUnits),view.TimeFormat);
        awtinvoke(h.Handles.TimePnl.TXTStartTime,'setText(Ljava.lang.String;)',xlow);
        xhigh = datestr(xlim{2}*...
            tsunitconv('days',view.TimeUnits),view.TimeFormat);
        awtinvoke(h.Handles.TimePnl.TXTEndTime,'setText(Ljava.lang.String;)',xhigh);
        ind = find(strcmp(view.TimeFormat,units));
    else % Numerical time vector
        awtinvoke(h.Handles.TimePnl.TXTStartTime,'setText(Ljava.lang.String;)',...
            sprintf('%0.4g',xlim{1}));
        awtinvoke(h.Handles.TimePnl.TXTEndTime,'setText(Ljava.lang.String;)',...
            sprintf('%0.4g',xlim{2}));
        % Sets the units in the @timeplot and the TimePnl to the current
        % timeseries units
        ind = find(strcmp(view.TimeUnits,units));
    end
    localSetMode(h,false,ind)
end

%% Update the events combo with the events currently displayed in
%% the view . TO DO: Remove parent dependency
if ~isempty(view.Parent)
    evlist = view.Parent.getevents;
    if ~isempty(evlist)
        [eventlist,eventParentList] = view.Parent.getevents;
        eventComboContents = cell(length(eventlist),1);
        for k=1:length(eventlist)
            eventComboContents{k} = sprintf('%s in %s',...
                eventlist(k).Name,eventParentList{k}.Name);
        end
        h.Handles.TimePnl.setevents(eventComboContents);
    else
        h.Handles.TimePnl.setevents([]);
    end

    % Unselect event radios for panning and zoom
    if view.PropEditor.Handles.TimePnl.RADIOStartEvent.isSelected || ...
        view.PropEditor.Handles.TimePnl.RADIOEndEvent.isSelected    
        if isempty(evlist)
            awtinvoke(view.PropEditor.Handles.TimePnl.RADIOStartTime,'setSelected(Z)',true);
            awtinvoke(view.PropEditor.Handles.TimePnl.RADIOEndTime,'setSelected(Z)',true);
        else
            if strcmp(view.AbsoluteTime,'on') && ischar(xlim{1}) && ...
                 (any(cellfun('isempty',get(evlist,{'StartDate'}))) || ...
                 ~any(datenum(xlim{1})==datenum(evlist.getTimeStr)))
                awtinvoke(view.PropEditor.Handles.TimePnl.RADIOStartTime,'setSelected(Z)',true);
            elseif strcmp(view.AbsoluteTime,'off') &&  ~any(xlim{1}==cell2mat(get(evlist,{'Time'})))
                awtinvoke(view.PropEditor.Handles.TimePnl.RADIOStartTime,'setSelected(Z)',true);
            end
            if strcmp(view.AbsoluteTime,'on') && ischar(xlim{2}) && ...
                (any(cellfun('isempty',get(evlist,{'StartDate'}))) || ...
                ~any(datenum(xlim{2})==datenum(evlist.getTimeStr)))
                awtinvoke(view.PropEditor.Handles.TimePnl.RADIOEndTime,'setSelected(Z)',true);
            elseif strcmp(view.AbsoluteTime,'off') && ~any(xlim{2}==cell2mat(get(evlist,{'Time'})))
                awtinvoke(view.PropEditor.Handles.TimePnl.RADIOEndTime,'setSelected(Z)',true);
            end
        end
    end
end

%% Update the panner. Position it so that it reflects the position of the 
%% axesgrid xlims relative the interval defined by the view extent
timeExtent = view.getExtent;
xlims = view.AxesGrid.getxlim{1};
pannerPos = 100*(mean(xlims)-timeExtent(1))/(timeExtent(2)-timeExtent(1));
pannerPos = max(min(pannerPos,100),0);
if abs(pannerPos-h.Handles.TimePnl.BarStartPan.getValue)>2
    h.Handles.TimePnl.BarStartPan.setValueNoCallback(pannerPos);
end


function localSetMode(h,state,ind)

if ~isempty(ind)
    h.Handles.TimePnl.setabstimemode(state,ind(1)-1);
else
    h.Handles.TimePnl.setabstimemode(state,0);
end
