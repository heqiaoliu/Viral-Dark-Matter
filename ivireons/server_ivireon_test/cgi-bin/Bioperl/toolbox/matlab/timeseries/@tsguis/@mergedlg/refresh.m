function refresh(h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Updates the components on the dialog to reflect the selected time series
%% Specifically, enables and disables redio buttons and displays the
%% "common" time vector

import javax.swing.*; 

%% List of enable-able components 
components = {h.Handles.BTNok,h.Handles.BTNcancel,h.Handles.RADIOinplace,...
               h.Handles.RADIOnewmerged,h.Handles.RADIOunion, ...
               h.Handles.RADIOintersect,h.Handles.RADIOuniform,...
               h.Handles.RADIOtimeseries,h.Handles.EDITinterval,...
               h.Handles.COMBunits,h.Handles.COMBts};
           
%% If the timePlot has gone disable components and do nothing
if isempty(h.ViewNode.getTimeSeries)
    mask = {'off','on','off','off','off','off','off','off','off','off','off'};
else
    % Find the selected time series
    drawnow % Ensure the table is ready
    tableData = cell(h.Handles.tsTable.getModel.getData);
    if isempty(tableData) % No time series in the view
        return
    end
    I = ~cellfun('isempty',tableData(:,2)) & cell2mat(tableData(:,1));
    fullPathSelected = tableData(I,3);
        
    % Refresh the timeseries combo
    tsList = h.ViewNode.getTimeSeries;
    tsNames = cell(size(tsList));
    for k=1:length(tsList)
        tsNames{k} = constructNodePath(h.ViewNode.getRoot.find('Timeseries',tsList{k}));
    end
    tscombval = get(h.Handles.COMBts,'Value');
    previoustsnames = get(h.Handles.COMBts,'String');
    ind = [];
    if length(previoustsnames)>=tscombval
        ind = find(strcmp(previoustsnames{tscombval},tsNames));
    end
    if ~isempty(ind) % Keep last selection if it is still valid
        set(h.Handles.COMBts,'String',tsNames,'Value',ind(1));
    else
        set(h.Handles.COMBts,'String',tsNames,'Value',1)
    end

    %% Enable/disable components based on the number of time series selected               
    if isempty(fullPathSelected) % Disable all components
        mask = repmat({'off'},[1 11]);
        start = 'empty';
        finish = 'empty';
        % Select the default time vector
        set(h.Handles.RADIOtimeseries,'Value',1) 
    elseif length(fullPathSelected)==1 % Single time series resample
        mask = {'on','on','on','on','off','off','on','on','on','on','on'};
        % If either of the disabled radio buttons are selected then select the
        % default radio and and select this time series in the corresponding
        % time series combo
        if get(h.Handles.RADIOunion,'Value') || get(h.Handles.RADIOintersect,'Value')
            set(h.Handles.RADIOuniform,'Value',1)    
        end

        % If uniform time vector is selected set the start and end time
        % accordingly
        thists = h.Viewnode.getRoot.getts(fullPathSelected);
        if get(h.Handles.RADIOuniform,'Value')
            [start,finish] = getIntervalStr(h,thists,'uniform');
        else % Resample using another series time vector
            tsComboList = get(h.Handles.COMBts,'String');
            selectedTimeseriesName = tsComboList{get(h.Handles.COMBts,'Value')};
            [start,finish] = getIntervalStr(h,h.ViewNode.getRoot.getts(selectedTimeseriesName),'uniform');
        end  
    else % Multiple time series merge
        mask = {'on','on','on','on','on','on','on','off','on','on','off'};
        % If the disabled radio buttons is selected then select the
        % default radio and and select this time series in the corresponding
        % time series combo
        if get(h.Handles.RADIOtimeseries,'Value') 
            set(h.Handles.RADIOuniform,'Value',1)    
        end
  
        % Find the start and end of the union on the overlapping interval
        % TO DO: Deal with abs time
        if get(h.Handles.RADIOunion,'Value')
            [start,finish] = getIntervalStr(h,h.Viewnode.getRoot.getts(fullPathSelected),'union');
        % Find the intersection time vector
        elseif get(h.Handles.RADIOintersect,'Value')
            [start,finish] = getIntervalStr(h,h.Viewnode.getRoot.getts(fullPathSelected),'intersection');
        elseif get(h.Handles.RADIOuniform,'Value')
            [start,finish] = getIntervalStr(h,h.Viewnode.getRoot.getts(fullPathSelected),'uniform');
        end
    end    

    % Update the time vector panel
    set(h.Handles.TXTstarttime,'String',sprintf('Start time: %s',start));
    set(h.Handles.TXTendtime,'String',sprintf('End time:  %s',finish));
end

%% Enable/disable the components using the mask 
for k=1:length(components)
    set(components{k},'Enable',mask{k})
end
