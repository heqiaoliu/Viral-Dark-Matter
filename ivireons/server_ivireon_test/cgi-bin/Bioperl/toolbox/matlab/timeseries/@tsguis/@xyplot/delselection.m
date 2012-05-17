function delselection(h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Deletes selected points and resets the selected status of deleted points

%% Get the data
xdata = h.Responses.DataSrc.Timeseries.Data;
ydata = h.Responses.DataSrc.Timeseries2.Data;

if strcmp(h.State,'DataSelect')
    
    % Disable DataChangeEventsEnabled
    h.Responses.DataSrc.Timeseries.DataChangeEventsEnabled = false;
    h.Responses.DataSrc.Timeseries2.DataChangeEventsEnabled = false;
    
    try
        % Create transaction and get the handle to the event recorder
        recorder = tsguis.recorder;
        T = tsguis.transaction;

        ts1Name = h.Responses.DataSrc.Timeseries.Name;
        ts2Name = h.Responses.DataSrc.Timeseries2.Name;

        % Replace selected points with NaNs. Note that for >1x1 views the 
        % same observation may be referenced by multiple points: e.g.: 
        % points (1,1,10) and (2,1,10) both affect time series 2 at 
        % col 1 observation 10. If any of these points are marked for
        % deletion NaN replacement occurs at the corresponding point
        selectedRectangles = h.Responses.View.SelectedRectangles;
        T.ObjectsCell = {T.ObjectsCell{:}, h.Responses.DataSrc.Timeseries,...
            h.Responses.DataSrc.Timeseries2};
        for k=1:size(h.Responses.View.SelectedRectangles,1)
            row = h.Responses.View.SelectedRectangles(k,1);
            col = h.Responses.View.SelectedRectangles(k,2);
            xlow = selectedRectangles(k,3);
            xhigh = selectedRectangles(k,4);
            ylow = selectedRectangles(k,5);
            yhigh = selectedRectangles(k,6);       
            ts1Data = h.Responses.DataSrc.Timeseries.Data;
            ts2Data = h.Responses.DataSrc.Timeseries2.Data;
            I = ts1Data(:,col)>=xlow & ts1Data(:,col)<=xhigh & ...
               ts2Data(:,row)>=ylow & ts2Data(:,row)<=yhigh;
            h.Responses.DataSrc.Timeseries.Data(I,:) = NaN;
            h.Responses.DataSrc.Timeseries2.Data(I,:) = NaN;
            if strcmp(recorder.Recording,'on')
               T.addbuffer([...
                   tsParseBufferStr(ts1Name,'I = #.Data(:,',col,') >= ',xlow,... 
                   ' & #.Data(:,',col,') <= ',xhigh,' & '), ...
                   tsParseBufferStr(ts2Name,'#.Data(:,', row, ') >= ',ylow,... 
                   ' & #.Data(:,',row,') <= ',yhigh,';')]);
               T.addbuffer(tsParseBufferStr(ts1Name,'#.Data(I,:) = NaN;'),...
                   h.Responses.DataSrc.Timeseries);
               T.addbuffer(tsParseBufferStr(ts2Name,'#.Data(I,:) = NaN;'),...
                   h.Responses.DataSrc.Timeseries2);           
            end
        end

        % Clear selected for deleted points
        h.Responses.View.SelectedRectangles = [];

        % Store transaction
        T.commit;
        recorder.pushundo(T);

        % Fire a single datachange to avoid a flicker
        h.Responses.DataSrc.Timeseries.DataChangeEventsEnabled = true;
        h.Responses.DataSrc.Timeseries2.DataChangeEventsEnabled = true;
        h.Responses.DataSrc.Timeseries.fireDataChangeEvent;
        h.Responses.DataSrc.Timeseries2.fireDataChangeEvent;
    catch
        h.Responses.DataSrc.Timeseries.DataChangeEventsEnabled = true;
        h.Responses.DataSrc.Timeseries2.DataChangeEventsEnabled = true;       
    end
end
                  