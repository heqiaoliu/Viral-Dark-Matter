function move(h,point,mode)

% Copyright 2004-2008 The MathWorks, Inc.

%% Moves the selected waveform to the point "point" through a translation

% Modify the time and amplidude properties without affecting the timeseries
% so that the transaction object is able to capture the complete move once
if strcmp(mode,'motion')
    % Calculate the Y translation needed to move the startpt to the current
    % point. The start Y value is mean of the observation at 
    % h.SelectionStruct.StartPoint
    ydata = h.SelectionStruct.Selectedwave.Data.Amplitude;
    xdata = h.SelectionStruct.Selectedwave.Data.Time; 
    
    delta = point(:)-h.SelectionStruct.HoverPoint;
    h.SelectionStruct.HoverPoint = point(:);
    h.SelectionStruct.Selectedwave.Data.Amplitude = ...
        h.SelectionStruct.Selectedwave.Data.Amplitude+delta(2);
    h.SelectionStruct.Selectedwave.Data.Time = ...
        h.SelectionStruct.Selectedwave.Data.Time + delta(1);

    %% Refresh - call draw on each wave to avoid triggering a viewchnage
    for k=1:length(h.waves)
       h.waves(k).RefreshMode = 'quick';
       % the following try-catch protect against "interp1" errors in case
       % time points become non-unique "while" you are moving a timeseries
       % (r.s.)
       try
           h.waves(k).draw;
       end
    end
    
    drawnow expose
elseif strcmp(mode,'complete') || strcmp(mode,'keyrelease')
    % Get the transaction and recorder handles
    T = tsguis.transaction;
    recorder = tsguis.recorder;
   
    if ~isempty(h.SelectionStruct.Selectedwave)
        
        % Find the deltas
        delta = point(:)-h.SelectionStruct.StartPoint;
        thists = h.SelectionStruct.Selectedwave.DataSrc.Timeseries;
        T.ObjectsCell = {T.ObjectsCell{:}, thists};
        deltaT = delta(1)*tsunitconv(thists.TimeInfo.Units,h.TimeUnits);
        deltaY = delta(2);
        
        % If the recorder is on cache the M code in the transaction buffer   
        if strcmp(recorder.Recording,'on')     
            T.addbuffer(xlate('%% Time series translation'))
            T.addbuffer(sprintf('%s.Data = %s.Data+%f;',thists.Name,thists.Name,...
                 deltaY),thists);
            T.addbuffer(sprintf('%s.Time = %s.Time+%f;', thists.Name,thists.Name,...
                 deltaT),thists);
        end

        % Move events
        for k=1:length(thists.Events)
            thists.Events(k).Time = thists.Events(k).Time+deltaT;
        end

        % During the drag all time series updates were routed to the @timedata
        % Amplitlitude and Time, update the timeseries with these new values. 
        % Do this in such a way that only one datachange event is fired
        newtime = thists.Time+deltaT;
        if ~isequal(h.SelectionStruct.Selectedwave.Data.Time,thists.Time)           
            if min(diff(newtime))<=0
                msg = sprintf('Limited double precision would result in duplicate times after the shift for: %s. Aborting the shift',...
                    thists.Name);
                errordlg(msg,'Time Series Tools','modal')
                return
            end
        end

        cacheDataChangeEventsEnabled = thists.DataChangeEventsEnabled;
        thists.DataChangeEventsEnabled = false;
        thists.Data = thists.Data+deltaY;
        thists.Time = newtime;
        thists.DataChangeEventsEnabled = cacheDataChangeEventsEnabled;
        thists.fireDataChangeEvent(tsdata.dataChangeEvent(thists,'move',[]));
        
        %% Store transaction
        T.commit;
        recorder.pushundo(T);

        %% reset the refresh mode
        set(h.waves,'RefreshMode','normal')

        %% Reset the selection struct and the mouse pointer  
        if strcmp(mode,'complete')
            h.SelectionStruct.StartPoint = [];
            h.SelectionStruct.Centroid = [];
        end   
    end
end