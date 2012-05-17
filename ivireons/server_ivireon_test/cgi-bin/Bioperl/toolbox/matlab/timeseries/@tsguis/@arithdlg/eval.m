function [success,newnode] = eval(h)

%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.17 $  $Date: 2009/06/16 04:20:07 $

%% Apply button callback
success = false;
newnode = [];

%% Get the expression
expression = get(h.Handles.TXTexp,'String');

%% Get a list of time series used in the expression
tableData = cell(h.Handles.tsTable.getModel.getData);
aliasNames = tableData(:,1);
if isjava(aliasNames)
    aliasNames = cell(aliasNames);
elseif ischar(aliasNames)
    aliasNames = {aliasNames};
end
pathNames = tableData(:,3);
if isjava(pathNames)
    pathNames = cell(pathNames);
elseif ischar(pathNames)
    pathNames = {pathNames};
end

%% Sort the list in descending order of name length
[~,I] = sort(-cellfun('length',aliasNames));
pathNames = pathNames(I);
aliasNames = aliasNames(I);

%% Parse through the expression and detect time series aliases
v = tsguis.tsviewer;
tslist = {};
basetslist = {};
aliasList = {};
for k=1:length(pathNames)  
    if ~isempty(strfind(expression,aliasNames{k}))
        aliasList = [aliasList; {aliasNames{k}}]; %#ok<AGROW>
        theseNodes = v.TreeManager.Root.search(pathNames{k});
        for j=1:length(theseNodes) % Throw out tscollections
            if isa(theseNodes(j),'tsguis.tsnode')    
                basetslist = [basetslist; {theseNodes(j).Timeseries}]; %#ok<AGROW>
                tslist = [tslist; {theseNodes(j).Timeseries.copy}]; %#ok<AGROW>
                tslist{end}.Name = aliasList{end};
            end
        end
    end
end
  
%% The expression must involve at least one timeseries
if isempty(tslist)
    errordlg('No time series identifier has been provided in the expression',...
        'Time Series Tools','modal')
    return
end
 
%% Create transaction
createNewTimeSeries = (get(h.Handles.COMBnewTs,'value')==2);
recorder = tsguis.recorder;
if strcmp(recorder.Recording,'on')
    T = tsguis.transaction('notrans');
elseif ~createNewTimeSeries
    T = tsguis.transaction;
end
if ~createNewTimeSeries % In-place operations need to cache the @timeseries
    existingTimeseriesPath = get(h.Handles.TXTpath,'string');
    existingTsNode = v.TreeManager.Root.search(existingTimeseriesPath);
    if isempty(existingTsNode)
        errordlg(xlate('Invalid selected time series'),'Time Series Tools','modal')
        return
    end
    T.ObjectsCell = {existingTsNode.Timeseries};
end

%% Evaluate it
try
    [outval,tsind] = xeval(sprintf('%s;',expression),tslist);
catch me
    msg = sprintf('Cannot evaluate expression, error returned was: %s',...
        me.message);
    errordlg(xlate(msg),'Time Series Tools','modal')
    return
end
if isempty(outval)
    msgbox('MATLAB expression returned no output.','Time Series Tools','modal')
    return 
end
%% If necessary create a @timeseries to hold the output data
[tsout,msg] = localCreateTs(outval,tsind,tslist);

%% If @timeseries cannot be created, manage the data returned
if isempty(tsout)
    if isscalar(outval)
       assignin('base','ans',outval);
       msg = sprintf('Scalar value was returned to the workspace as variable ans with value: %f',...
           outval);
    elseif length(outval)>1
       assignin('base','ans',outval);
       if numel(outval)<=500
           msg = sprintf('Matrix value was returned to the workspace as variable ans with size: %s. Matrix has been displayed in the workspace.',...
               num2str(size(outval)));
           disp(outval);
       else
           msg = sprintf('Matrix value was returned to the workspace as variable ans with size: %s.',...
               num2str(size(outval)));
       end
    elseif isempty(msg)
       msg = 'Expression returned no output.';
    end    
    msgbox(xlate(msg),'Time Series Tools','modal')
    return
end     
        
% If a time series is returned from the expression add it to the tree
if createNewTimeSeries
    newName = deblank(get(h.Handles.TXToutname,'String'));
    if ~isempty(newName)
        tsout.Name = newName;
        newnode = v.createTimeSeriesNode(tsout);
        if isempty(newnode) % Aborted
            return
        end
    else
        errordlg('Output Time Series name(s) must be defined',...
            'Time Series Tools','modal')
        return
    end
else % Modify time series in place
    existingTimeseriesPath = get(h.Handles.TXTpath,'string');
    existingTsNode = v.TreeManager.Root.search(existingTimeseriesPath);
    try
        existingTsNode.Timeseries.Data = tsout.Data;
        existingTsNode.Timeseries.Time = tsout.Time;
    catch me1
        msg = 'Cannot overwrite the data in the selected time series with the new data. The most likely reason is that the existing time vector is not compatible with the new data size';
        errordlg(xlate(msg),'Time Series Tools','modal')
        return
    end
end


%% If the recorder is on, cache the M code in the transaction buffer
if strcmp(recorder.Recording,'on')
    tslist = tslist(tsind);
    
    % Build the second arg for xeval (list of @timeseries)
    tslststr = sprintf('{%s',tslist{1}.Name);
    for k=2:length(tsind)
        tslststr = [tslststr, sprintf(',%s',tslist{k}.Name)]; %#ok<AGROW>
    end
    tslststr = [tslststr, '}'];
    
    T.addbuffer(xlate('%% Application of MATLAB function/arithmetic'));
    for k=1:length(tslist)
        T.addbuffer([aliasList{k} ' = ' basetslist{k}.Name ';'],basetslist{k});
        T.addbuffer([aliasList{k} '.Name = ''' aliasList{k} ''';']);
    end    

    % Write data evaluation
    T.addbuffer(sprintf('data = xeval(%s%s%s,%s);','''',expression,'''',tslststr));
    
    % If tsout has abs time vector all time series in the expression had
    % the same abs time vector
    if createNewTimeSeries
        if ~isempty(tsout.TimeInfo.StartDate)
            T.addbuffer(sprintf('%s = timeseries(data);',tsout.Name),[],tsout);
            T.addbuffer(sprintf('%s.TimeInfo.StartDate = %s.TimeInfo.StartDate;',...
                tsout.Name,tslist{1}.Name));
            T.addbuffer(sprintf('%s.Time = %s.Time;',tsout.Name,tslist{1}.Name));        
        % If tsout has a relative time vector, the start time must be zero and
        % we may need to convert the units.
        else
            T.addbuffer(sprintf('%s = timeseries(data);',tsout.Name),[],tsout);

            if strcmp(tsout.TimeInfo.Units,tslist{1}.TimeInfo.Units)
                if tsout.Time(1)==0
                    T.addbuffer([tsout.Name '.Time = (' tslist{1}.Name '.Time-' tslist{1}.Name ...
                        '.Time(1));']);
                else
                    T.addbuffer([tsout.Name '.Time = ' tslist{1}.Name '.Time;']);
                end
            else
                T.addbuffer(...
                     [tsout.Name '.Time = ' tslist{1}.Name '.Time*tsunitconv(''' ...
                         tsout.TimeInfo.Units ''',''' tslist{1}.TimeInfo.Units ''');']);
                if tsout.Time(1)==0
                    T.addbuffer([tsout.Name '.Time = ' tsout.Name '.Time - ' ...
                        tsout.Name '.Time(1);']);
                end
            end
        end
        T.addbuffer([tsout.Name '.TimeInfo.Units = ''' tsout.TimeInfo.Units ''';'],tsout.Name); 
        T.addbuffer([tsout.Name '.Name = ''' tsout.Name ''';']);
    else
        T.addbuffer([existingTsNode.Timeseries.Name '.Data = data;'],existingTsNode.Timeseries);
    end    
end

%% Store transaction
if ~createNewTimeSeries
    T.commit;
    recorder.pushundo(T);
elseif strcmp(recorder.Recording,'on')
    recorder.pushundo(T);
end

%% Report success
success = true;

function [tsout,msg] = localCreateTs(result,ind,tslist)

%% Use the result of xeval to create a new @timeseries if the input
%% @timeseries have compatible time vectors

tsout = [];
msg = '';

%% Data must be derived from a @timeseries and must at least have the same
%% length as the first @timeseries that was used in the expression
if isempty(ind) || ...
        ~isequal(size(result,1),tslist{ind(1)}.TimeInfo.Length)
    return
end
tsoutdata = result;

%% Initialization
ts = tslist{ind(1)};
tsInfo = ts.TimeInfo;
tsoutvec = ts.Time;

%% Check sizes of all the @timeseries used in the expression match
for k=2:length(ind)
    if ~isequal(ts.TimeInfo.Length,tslist{ind(k)}.TimeInfo.Length)
        msg = xlate('Time Series have differing lengths.');
        return
    end
end

%% Loop through each time vector and convert to the smallest units and
%% the earliest start date (if any)
outprops = struct('ref',tsInfo.StartDate,'outformat',tsInfo.Format,'outunits',...
    tsInfo.Units);      
warnabouttime = false;
for k=2:length(ind)
   [tsoutvec,tsoutvec2,outprops] = ...
        timemerge(tsInfo,tslist{ind(k)}.timeInfo,tsoutvec,tslist{ind(k)}.time);   
   tsInfo.StartDate = outprops.ref;
   tsInfo.Format = outprops.outformat;
   tsInfo.Units = outprops.outunits;
       
   % Relative time vectors - remove initial values
   if isempty(outprops.ref) && tsoutvec(1)~=tsoutvec2(1)
       tsoutvec = tsoutvec-tsoutvec(1);
       tsoutvec2 = tsoutvec2-tsoutvec2(1);
       warnabouttime = true;
   end
   % Check that the time vectors match
   intervalLen = ((tsoutvec(end)-tsoutvec(1))/length(tsoutvec));
   if norm(tsoutvec-tsoutvec2)/intervalLen>1e-6
      msg = 'Time vectors do not match.';
      return
   end
end

%%  Warn about relative time shifts
if warnabouttime
    uiwait(msgbox('The time vector of the output time series has been shifted to start at zero because two or more time series have differing start times',...
        'modal'))
end    
   

% Create output time series
tsout = tsdata.timeseries(tsoutdata,tsoutvec);
tsout.timeInfo.Startdate = outprops.ref;
tsout.timeInfo.Units = outprops.outunits;
tsout.timeInfo.Format = outprops.outformat;
