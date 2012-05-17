function rmselection(h,varargin)

% Copyright 2004-2005 The MathWorks, Inc.

%% Deletes selected points and resets the selected status of deleted points



if strcmp(h.State,'DataSelect') 

    % Disable DataChangeEventsEnabled
    h.Responses.DataSrc.Timeseries.DataChangeEventsEnabled = false;
    h.Responses.DataSrc.Timeseries2.DataChangeEventsEnabled = false;
    
    try
        % Get the data
        xdata = h.Responses.DataSrc.Timeseries.Data;
        ydata = h.Responses.DataSrc.Timeseries2.Data;


        % Create transaction and get the handle to the event recorder
        recorder = tsguis.recorder;
        T = tsguis.transaction;

        % Note that for >1x1 views the
        % same observation may be referenced by multiple points: e.g.:
        % points (1,1,10) and (2,1,10) both affect time series 2 at
        % col 1 observation 10. If any of these points are marked for
        % removal then it occurs at all corresponding points
        I = false(size(xdata,1),1);
        for k=1:size(h.Responses.View.SelectedRectangles,1)
            row = h.Responses.View.SelectedRectangles(k,1);
            col = h.Responses.View.SelectedRectangles(k,2);
            ts1Data = h.Responses.DataSrc.Timeseries.Data;
            ts2Data = h.Responses.DataSrc.Timeseries2.Data;
            I = I | (ts1Data(:,col)>=h.Responses.View.SelectedRectangles(k,3) & ...
               ts1Data(:,col)<=h.Responses.View.SelectedRectangles(k,4) & ...
               ts2Data(:,row)>=h.Responses.View.SelectedRectangles(k,5) & ...
               ts2Data(:,row)<=h.Responses.View.SelectedRectangles(k,6));
        end

        % Clear selected for deleted points
        selectedRectangles = h.Responses.View.SelectedRectangles;
        h.Responses.View.SelectedRectangles = [];

        % Don't remove all data
        if all(I)
            errordlg('Removing all points would create an empty time series. No action taken.',...
               'Time Series Tools','modal')
            h.Responses.DataSrc.Timeseries.DataChangeEventsEnabled = true;
            h.Responses.DataSrc.Timeseries2.DataChangeEventsEnabled = true;
            return
        end

        % Suspend warnings between updateing time series since they will
        % be temporarily out of sync between the two updates
        if any(I)
            swarn = warning('off','all');
        else 
            h.Responses.DataSrc.Timeseries.DataChangeEventsEnabled = true;
            h.Responses.DataSrc.Timeseries2.DataChangeEventsEnabled = true;
            return
        end

        %% Write selection action to buffer
        if strcmp(recorder.Recording,'on')
            ts1Name = h.Responses.DataSrc.Timeseries.Name;
            ts2Name = h.Responses.DataSrc.Timeseries2.Name;
            I = false(size(xdata,1),1);
            T.addbuffer(tsParseBufferStr(ts1Name,'I = false(size(#.Data,1),1);'));
            for k=1:size(selectedRectangles,1)
               row = selectedRectangles(k,1);
               col = selectedRectangles(k,2);          
               xlow = selectedRectangles(k,3);
               xhigh = selectedRectangles(k,4);
               ylow = selectedRectangles(k,5);
               yhigh = selectedRectangles(k,6);
               T.addbuffer([...
                   tsParseBufferStr(ts1Name,'I = I |(#.Data(:,',col,') >= ',xlow,... 
                   ' & #.Data(:,',col,') <= ',xhigh,' & '), ...
                   tsParseBufferStr(ts2Name,'#.Data(:,', row, ') >= ',ylow,... 
                   ' & #.Data(:,',row,')<= ',yhigh,');')]);
            end
        end  

        % Remove selected points
        T.ObjectsCell = {T.ObjectsCell{:}, h.Responses.DataSrc.Timeseries,...
            h.Responses.DataSrc.Timeseries2};
        if nargin>=2 && strcmp(varargin{1},'complement')
            % Convert indices to time so that we don't remove data twice if
            % both time series are part of a tscollection
            t1 = h.Responses.DataSrc.Timeseries.Time(find(~I));
            t2 = h.Responses.DataSrc.Timeseries2.Time(find(~I));
            h.Responses.DataSrc.Timeseries.delsample('value',t1);
            h.Responses.DataSrc.Timeseries2.delsample('value',t2);
            if strcmp(recorder.Recording,'on') % Recorder uses indices for tscollection
                T.addbuffer(sprintf('%s.Time = %s.Time;',ts1Name,ts2Name));
                T.addbuffer(tsParseBufferStr(ts1Name,'# = delsample(#,''index'',find(~I));'),...
                    h.Responses.DataSrc.Timeseries);
                T.addbuffer(tsParseBufferStr(ts2Name,'# = delsample(#,''index'',find(~I));'),...
                    h.Responses.DataSrc.Timeseries2);
            end
        else
            % Convert indices to time so that we don't remove data twice if
            % both time series are part of a tscollection
            t1 = h.Responses.DataSrc.Timeseries.Time(find(I));
            t2 = h.Responses.DataSrc.Timeseries2.Time(find(I));
            h.Responses.DataSrc.Timeseries.delsample('value',t1);
            h.Responses.DataSrc.Timeseries2.delsample('value',t2);
            if strcmp(recorder.Recording,'on') % Recorder uses indices for tscollection
                T.addbuffer(sprintf('%s.Time = %s.Time;',ts1Name,ts2Name));            
                T.addbuffer(tsParseBufferStr(ts1Name,'# = delsample(#,''index'',find(I));'),...
                    h.Responses.DataSrc.Timeseries);
                T.addbuffer(tsParseBufferStr(ts2Name,'# = delsample(#,''index'',find(I));'),...
                    h.Responses.DataSrc.Timeseries2);
            end
        end




        % Restore warning state
        if any(strcmp({swarn.('state')},'on'))
            warning on;
        end

        % Store transaction
        T.commit;
        recorder.pushundo(T);


        % Fire a single datachange to avoid a flicker
        h.Responses.DataSrc.Timeseries.DataChangeEventsEnabled = true;
        h.Responses.DataSrc.Timeseries2.DataChangeEventsEnabled = true;
        h.Responses.DataSrc.Timeseries.fireDataChangeEvent;
        h.Responses.DataSrc.Timeseries2.fireDataChangeEvent;
    catch % Restore DataChangeEventsEnabled flag if error
        h.Responses.DataSrc.Timeseries.DataChangeEventsEnabled = true;
        h.Responses.DataSrc.Timeseries2.DataChangeEventsEnabled = true;
    end
end