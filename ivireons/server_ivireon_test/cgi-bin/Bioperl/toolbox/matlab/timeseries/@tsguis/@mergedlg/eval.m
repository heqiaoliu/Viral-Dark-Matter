function success = eval(h)

% Copyright 2004-2008 The MathWorks, Inc.

success = false;

%% Get recorder/transaction handle
recorder = tsguis.recorder;
if get(h.Handles.RADIOinplace,'Value') % In place resample
    T = tsguis.transaction;
else    
    T = tsguis.transaction('notrans');    
end

%% Find the selected time series
tableData = cell(h.Handles.tsTable.getModel.getData);
if isempty(tableData) % No timeseries in the table
    return
end
I = ~cellfun('isempty',tableData(:,2)) & cell2mat(tableData(:,1));
fullpathSelected = tableData(I,3);
if isempty(fullpathSelected)
    return
end

%% If logging write the header for this subsection
if strcmp(recorder.Recording,'on')
   T.addbuffer('%% Time series resample/merge');
end 

%% Resample using a vector from another time series
if get(h.Handles.RADIOtimeseries,'Value') 
    % Get time series which provides the time vector
    tsComboList = get(h.Handles.COMBts,'String');
    selectedTimeseriesName = tsComboList{get(h.Handles.COMBts,'Value')};
    thists = h.ViewNode.getRoot.getts(selectedTimeseriesName);
    thists = thists{1};
    
    % Get its time vector
    time = thists.Time;  
    if strcmp(recorder.Recording,'on')
       T.addbuffer(sprintf('time = %s.Time;',thists.Name),thists);
    end      
    
    % Resample the other selected time series on this time vector
    if length(time)>1 % resample inteprets scalar time vectors as intervals
        for k=1:length(fullpathSelected)
            tsin = h.Viewnode.getRoot.getts(fullpathSelected{k});
            tsin = tsin{1};
            if get(h.Handles.RADIOinplace,'Value') % In place resample
                try
                    tsin.resample(time);
                catch me
                    errordlg(me.message,'Time Series Tools','modal')
                    return
                end
                 
                if strcmp(recorder.Recording,'on')
                   T.addbuffer(sprintf('%s = resample(%s,time);',...
                       tsin.Name,tsin.Name),tsin);
                end 
                T.ObjectsCell = {T.ObjectsCell{:},tsin}; %r.s.
            else % Resample to a copy
                tstemp = tsin.copy;
                try
                    tstemp.resample(time);
                catch me
                    errordlg(me.message,'Time Series Tools','modal')
                    return
                end
                tstemp.Name = sprintf('Resampled_%s',tsin.Name);
                if isa(tsin,'Simulink.Timeseries')
                    h.viewnode.getRoot.tsViewer.SimulinkTSnode.createChild(tstemp);
                else
                    h.viewnode.getRoot.tsViewer.TSnode.createChild(tstemp);
                end
                T.ObjectsCell = {T.ObjectsCell{:}, tstemp};
                if strcmp(recorder.Recording,'on')               
                   T.addbuffer(sprintf('Resampled_%s = resample(%s,time);',...
                       tsin.Name,tsin.Name),tsin,tstemp);          
                end 
            end
        end
    end
%% resample using a uniform time vector    
elseif get(h.Handles.RADIOuniform,'Value') 
    % Find the units
    unitlist = get(h.Handles.COMBunits,'String');
    thisunit = unitlist{get(h.Handles.COMBunits,'Value')};
    
    % Get the time interval
    try
        interval = eval(get(h.Handles.EDITinterval,'String'));
    catch me
        errordlg('Invalid time interval','Time Series Tools','modal')
        return
    end
    if isempty(interval) || ~isscalar(interval) || ~isfinite(interval)
        errordlg('Invalid time interval','Time Series Tools','modal')
        return
    end
        
    for k=1:length(fullpathSelected)
        % Get the uniform time vector for each selected time series
        tsin = h.ViewNode.getRoot.getts(fullpathSelected{k});
        tsin = tsin{1};
        
        % Convert interval units
        thisinterval = interval*tsunitconv(tsin.timeInfo.Units,thisunit);
        
        
        % New time vector
        
        % Resample inteprets scalar time vectors as intervals       
        if  thisinterval<=0 || ...
            floor((tsin.timeInfo.End-tsin.timeInfo.Start)/thisinterval)>1 && ...
            floor((tsin.timeInfo.End-tsin.timeInfo.Start)/thisinterval)<1e8    
            time = tsin.timeInfo.Start:thisinterval:tsin.timeInfo.End;
            if strcmp(recorder.Recording,'on')
               T.addbuffer(sprintf('time = %f:%f:%f;',tsin.timeInfo.Start,...
                   thisinterval,tsin.timeInfo.End));
            end 

            % Resample the timeseries
            if get(h.Handles.RADIOinplace,'Value') % In place resample
                 T.ObjectsCell = {T.ObjectsCell{:}, tsin}; %r.s. 
                 try
                     resample(tsin,time);
                 catch me
                     errordlg(me.message,'Time Series Tools','modal')
                     return
                 end
                 
                 if strcmp(recorder.Recording,'on')
                     T.addbuffer(sprintf('%s = resample(%s,time);',tsin.Name,tsin.Name),tsin);
                 end 
            else % Resample a copy
                tstemp = tsin.copy;
                try
                    tstemp.resample(time);
                catch me
                    errordlg(me.message,'Time Series Tools','modal')
                    return
                end                   
                tstemp.Name = sprintf('Resampled_%s',tsin.Name);
                h.viewnode.getRoot.tsViewer.createTimeSeriesNode(tstemp);
                T.ObjectsCell = {T.ObjectsCell{:}, tstemp}; %r.s.
                if strcmp(recorder.Recording,'on')           
                   T.addbuffer(sprintf('Resampled_%s = resample(Resampled_%s,time);',tsin.Name,tsin.Name),...
                       tsin,tstemp);          
                end  
            end 
        else
            errordlg('Resampling cannot produce time series with only one sample or with more than 1e8 samples.',...
                'Time Series Tools','modal')
            return
        end
    end
%% Merge two timeseries
elseif get(h.Handles.RADIOunion,'Value') || get(h.Handles.RADIOintersect,'Value')
    
    % Currently limited to two time series
    if length(fullpathSelected)>2
           errordlg('You can only resample one or two time series.',...
                'Time Series Tools','modal')
            return
    end
 
    % Find the common time vector
    ts1 = h.ViewNode.getRoot.getts(fullpathSelected{1});
    ts1 = ts1{1};
    ts2 = h.ViewNode.getRoot.getts(fullpathSelected{2});
    ts2 = ts2{1};
    
    % Find the method string and check that the common time vector will not
    % be empty. This must be done before the merge so that the operation is
    % not partially complete when any error occurs
    if get(h.Handles.RADIOunion,'Value')
        method = 'union';
    elseif get(h.Handles.RADIOintersect,'Value')
        method = 'intersection';
    end
    maxStart = getIntervalStr(h,{ts1,ts2},method);        
    if strcmp(maxStart,'Empty time vector')
          errordlg('Resulting time vector is empty. Operation aborted.',...
                'Time Series Tools','modal')
            return
    end
        

    if get(h.Handles.RADIOinplace,'Value') % In place resample
        % Cache initial @timeseries
        T.ObjectsCell = {T.ObjectsCell{:}, ts1, ts2}; 
        
        try
            merge(ts1,ts2,method);
        catch me
            errordlg(me.message,'Time Series Tools','modal')
            return
        end
        
        if strcmp(recorder.Recording,'on')
            T.addbuffer(sprintf('[%s,%s] = synchronize(%s,%s,''%s'');',ts1.Name,...
                ts2.Name,ts1.Name,ts2.Name,method),{ts1,ts2});
        end
    else % Create copies
        ts1temp = ts1.copy;
        ts2temp = ts2.copy;
        
        % Cache initial @timeseries
        T.ObjectsCell = {T.ObjectsCell{:}, ts1temp, ts2temp}; %r.s.
        
        % Perform op
        try
            merge(ts1temp,ts2temp,method);
        catch me
            errordlg(me.message,'Time Series Tools','modal')
            return
        end
        ts1temp.Name = sprintf('Merged_%s',ts1temp.Name);
        ts2temp.Name = sprintf('Merged_%s',ts2temp.Name);
        if strcmp(ts1temp.Name,ts2temp.Name)
            ts2temp.Name = sprintf('%s1',ts2temp.Name);
        end
        ts2temp.Name = sprintf('Merged_%s',ts2temp.Name);
        h.viewnode.getRoot.tsViewer.createTimeSeriesNode(ts1temp);
        h.viewnode.getRoot.tsViewer.createTimeSeriesNode(ts2temp);
        
        if strcmp(recorder.Recording,'on')
             T.addbuffer(sprintf('[Merged_%s,Merged_%s] = synchronize(%s,%s,''%s'');', ...
                 ts1.Name,ts2.Name,ts1.Name,ts2.Name,method),{ts1, ts2},{ts1temp,ts2temp});          
        end 
    end
end

%% Store transaction
T.commit;
recorder.pushundo(T);

%% Resport success
success = true;
