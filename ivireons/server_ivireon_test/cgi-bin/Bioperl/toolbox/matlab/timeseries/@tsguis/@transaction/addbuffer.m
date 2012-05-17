function addbuffer(T,str,varargin)

% Copyright 2004-2010 The MathWorks, Inc.

%% If a new timeseries variable has been introduced, add it to the list of
%% time series names in the recorder
if nargin>=3
    recorder = tsguis.recorder;
    
    % Are any of the time series members of a @tscollection?
    viewer = tsguis.tsviewer;
    
    if ~isempty(varargin{1})
        tsnodes = viewer.Tsnode.getChildren;
        for k=1:length(tsnodes)
            if isa(tsnodes(k),'tsguis.tscollectionNode')
                tsList = get(tsnodes(k).getChildren,{'Timeseries'});
                if localTsCompare(tsList,varargin{1})
                    warndlg('Recorded code will treat members of a @tscollection as independent time series ',...
                        'Time Series Tools','modal')
                    break
                end
            end
        end

        %% Add the time series to the cache            
        if isa(varargin{1},'tsdata.timeseries') 
            str = localAddTimeseries(recorder,varargin{1},'TimeseriesIn',T,str);
        elseif iscell(varargin{1}) % Cell array of time series have been provided
            tsList = varargin{1};
            for k=1:length(tsList)
                str = localAddTimeseries(recorder,tsList{k},'TimeseriesIn',T,str);
            end
        end
    end
    %% If a new output timeseries variable has been introduced, add it to the list of
    %% output time series names in the recorder
    if nargin>=4
        if isa(varargin{2},'tsdata.timeseries') 
            str = localAddTimeseries(recorder,varargin{2},'TimeseriesOut',T,str);
        elseif  iscell(varargin{2}) % Cell array of time series have been provided 
            tsList = varargin{2};
            for k=1:length(tsList)
               str = localAddTimeseries(recorder,tsList{k},'TimeseriesOut',T,str);
            end
        end
    end

    % If one of the input timeseries was previously built by a logged
    % operation it cannot appear in the list of function inputs   
    I = true(length(recorder.TimeseriesIn),1);
    for k=1:length(recorder.TimeseriesIn)
        for j=1:length(recorder.TimeseriesOut)
            if  recorder.TimeseriesIn(k).Timeseries == recorder.TimeseriesOut(j).Timeseries
                I(k) = false;
            end
        end
    end
    recorder.TimeseriesIn = recorder.TimeseriesIn(I);
end

%% Add a new M recorder string to the buffer
T.Buffer = [T.Buffer; {str}];

function status = localTsCompare(tsList,ts)

status = false;
if isa(tsList,'tsdata.timeseries')
    status = (tsList == ts);
elseif iscell(tsList)
    status = false;
    for k=1:length(tsList)
        if tsList{k}==ts
            status = true;
            return
        end
    end
end


function strout = localAddTimeseries(h,ts,prop,T,strin)

timeSeriesCache = get(h,prop);
strout = strin;

%% If the timeseries has already been cached return
tsNames = cell(length(timeSeriesCache),1);
for k=1:length(timeSeriesCache)
    if timeSeriesCache(k).Timeseries == ts
       return
    end
    tsNames{k} = timeSeriesCache(k).Name;
end

%% Check that the name of this timeseries does not clash
%% with another timeseries in the list, if so gice it a new name
newName = ts.Name;
oldName = ts.Name;
k = 1;
while any(strcmp(newName,tsNames));
    newName = sprintf('%s%d',ts.Name,k);
end

%% Replace all instances of oldName in buffer string to be added with
%% newName
if ~strcmp(oldName,newName)
    strout = strrep(strin,oldName,newName);
    T.Buffer = strrep(T.Buffer,oldName,newName);
end
    

%% Add the new time series to the list as a struct
set(h,prop,[timeSeriesCache; ...
       struct('Name',newName,'Timeseries',ts)]);