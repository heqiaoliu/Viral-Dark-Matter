function eventTimeChange(h,startRow,col,thisModel)

% Copyright 2005-2006 The MathWorks, Inc.

%% Callback which reacts to changes in the event time made in the events
%% table

%% Find the data which was changed
startRow = startRow+1;
col = col+1;
if col<=0 || col>=4
    return
end

%% Get the tableData
tableData = cell(thisModel.getData);

%% Create transaction
T = tsguis.transaction;
T.ObjectsCell = {T.ObjectsCell{:}, h.Timeseries};
recorder = tsguis.recorder;
        
%% Look for the event who's time has changed
%% Time change
if col==3
    I = find(strcmp(tableData{startRow,1},...
        get(h.Timeseries.events,{'Name'})));
    if ~isempty(I)
        % Compute the new event time in the right frame of reference
        if ~isempty(h.Timeseries.TimeInfo.StartDate)
            try
                evtime = datenum(tableData{startRow,3});
            catch %Abort
                localEventsChange([],[],h.Timeseries,h.Handles.eventTable)
                return
            end

            evtime = (evtime-datenum(h.Timeseries.TimeInfo.StartDate))*...
                tsunitconv(h.Timeseries.TimeInfo.Units,'days');
        else
            evtime = eval(tableData{startRow,3},'[]');
            if isempty(evtime) || ~isscalar(evtime) || ~isfinite(evtime)%Abort
                localEventsChange([],[],h.Timeseries,h.Handles.eventTable)
                return
            end
        end

        % Update the event time
        h.Timeseries.events(I(1)).Time = evtime;

        % Record action
        if strcmp(recorder.Recording,'on')
            T.addbuffer(xlate('%% Modifying event time'));
            T.addbuffer(['[e,J] = findEvent(' h.Timeseries.Name '.Events,' ...
                '''', h.Timeseries.events(I(1)).Name, ''');']);
            T.addbuffer(['e.Time = ' num2str(evtime) ';'],h.Timeseries);
            T.addbuffer([h.Timeseries.Name, '.Events(J) = e;']);
        end

        % Send a datachange event to the affected time series
        h.Timeseries.send('datachange')
    end
    %% Name change
elseif col==1
    evname = tableData{startRow,1};
    % abort if duplicate or invalid event name is found
    if isempty(evname) || ~ischar(evname) || ismember(evname,get(h.Timeseries.Events,{'Name'}))
        localEventsChange([],[],h.Timeseries,h.Handles.eventTable)
        return
    end

    % Record action
    if strcmp(recorder.Recording,'on')
        T.addbuffer(xlate('%% Modifying event name'));
        T.addbuffer(['[e,J] = findEvent(', h.Timeseries.Name '.Events,',...
            '''', h.Timeseries.events(startRow).Name, ''');']);
        T.addbuffer(['e.Name = ''' evname ''';'],h.Timeseries);
        T.addbuffer([h.Timeseries.Name, '.Events(J) = e;']);    
    end

    % Update the name
    h.Timeseries.events(startRow).Name = evname;
    h.Timeseries.send('datachange')

    %% Description change
elseif col==2
    descr = tableData{startRow,2};
    h.Timeseries.events(startRow).EventData = descr;
    if strcmp(recorder.Recording,'on') && ~isempty(descr)
        T.addbuffer(xlate('%% Modifying event description'));
        T.addbuffer(['[e,J] = findEvent(', h.Timeseries.Name '.Events,',...
            '''', h.Timeseries.events(startRow).Name, ''');']);
        T.addbuffer(['e.EventData = ''' descr ''';'],h.Timeseries);
        T.addbuffer([h.Timeseries.Name, '.Events(J) = e;']);
    end 
end

%% Store transaction
T.commit;
recorder.pushundo(T);

function localEventsChange(eventSrc,eventData,ts,eventTable,varargin)

%% Listener callback to @eventsnode "Events" property which keeps the event
%% table in sync
tableData = cell(length(ts.Events),3);
for k=1:length(ts.Events)
    evTimeStr = ts.Events(k).getTimeStr(ts.TimeInfo.Units);
    if ischar(ts.Events(k).EventData)
        tableData(k,:) = {ts.Events(k).Name, ts.Events(k).EventData, evTimeStr{1}};
    else
        tableData(k,:) = {ts.Events(k).Name, '', evTimeStr{1}};
    end
end

%% Passive table data change
eventTable.getModel.setDataVector(tableData,{xlate('Name'),xlate('Description'),xlate('Time')},...
        eventTable);