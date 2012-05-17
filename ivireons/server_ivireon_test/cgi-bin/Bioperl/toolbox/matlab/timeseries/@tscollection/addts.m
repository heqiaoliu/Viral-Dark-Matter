function h = addts(h, data, varargin)
%ADDTS  Add data vector or time series object into tscollection.
%
% TSC = ADDTS(TSC,TS) adds a time series TS into tscollection TSC.
%
% TSC = ADDTS(TSC,TS), where TS is a cell array of time series, adds all the time
% series into tscollection TSC. 
%
% TSC = ADDTS(TSC,TS,NAME), where TS is a cell array of time series and NAME is a
% cell array of strings, adds all the time series into tscollection TSC
% using the name NAME.
%
% TSC = ADDTS(TSC,DATA,NAME), where DATA is a numerical array and NAME is a string,
% creates a new time series using DATA and NAME, and then adds it into tscollection TSC
%

%   Copyright 2005-2010 The MathWorks, Inc.

% Validate the number of the input arguments
N = nargin;
errmsg = nargchk(2,4,N); %#ok<NCHK>
if ~isempty(errmsg)
     error('tscollection:addts:inargs',errmsg);
end
% deal with name
if N==2
    if iscell(data)
        if isvector(data) && all(cellfun(@(x) isa(x,'timeseries'),data))
            name = cell(1,length(data));
            for i=1:length(data)
                name(i) = {genvarname(data{i}.Name)};
            end
        else
            error('tscollection:addts:badcell',...
                xlate('Invalid cell array of time series. Cell array arguments must be cell vectors of time series objects.'));
        end
    elseif isa(data,'timeseries')
        name = genvarname(data.Name);
    else
        error('tscollection:addts:badinput',...
            'The second attribute of addts must be either an array or a time series object.') 
    end
else
    if iscell(varargin{1})
        name = cell(1,length(data));
        for i=1:length(varargin{1})
            name(i) = {genvarname(varargin{1}{i})};
        end
    elseif ischar(varargin{1})
        name = genvarname(varargin{1});
    else
        error('tscollection:addts:badname',...
            'The time series name must be a string.') 
    end
end

% Prepare name string
if iscellstr(name)
    if length(unique(name))<length(name)
        error('tscollection:addts:dupinputnames',...
            xlate('The names of time series you are trying to add must be unique'));
    end
    for i=1:length(name)
        if any(strcmpi(name{i},gettimeseriesnames(h)))
            error('tscollection:addts:dupexistingname',...
                'The name of the time series you are trying to add conflicts with the name of an existing member.') 
        end
    end
elseif any(strcmpi(name,gettimeseriesnames(h)))
    error('tscollection:addts:dupexistingname',...
            'The name of the time series you are trying to add conflicts with the name of an existing member.')
end

% If tscollection object is initially empty (truly case)
if iscell(data)
    if isvector(data) && all(cellfun(@(x) isa(x,'timeseries'),data))
        for i=1:length(data)
            localCheckTS(h,data{i});
            h = localUpdateTS(h,data{i},name{i});
        end
    end
else
    % Create a local ts object based on data
    if isa(data,'timeseries')
        localCheckTS(h,data);
        ts = data;
    else
        s = size(data);
        if s(1) == h.Length
            ts = timeseries(data,h.Time,'IsTimeFirst',true);
        elseif s(end)==h.Length
            ts = timeseries(data,h.Time,'IsTimeFirst',false);
        elseif h.Length==1
            % defaultIsTimeFirst is true, unless all current members are
            % otherwise
            tsnames = gettimeseriesnames(h);
            defaultIsTimeFirst = false;
            for k=1:length(tsnames)
                thists = getts(h,tsnames{k});
                if (thists.IsTimeFirst~=defaultIsTimeFirst)
                    defaultIsTimeFirst = true;
                    break;
                end
            end
            ts = timeseries(data,h.Time,'IsTimeFirst',defaultIsTimeFirst);
        else
            error('tscollection:addts:baddata',...
                'Data is not compatible with tscollection length')
        end 
    end
    % Check if datainfo is available
    if N==4 && isa(varargin{2},'tsdata.datametadata')
        ts.DataInfo = varargin{2};
        h = localUpdateTS(h,ts,name);
    else
        h = localUpdateTS(h,ts,name);
    end
end



%------------------------------------------------------------------------
function localCheckTS(h,ts)

% Allow time vectors to mismatch when adding a timeseries to an
% empty tscollection
if isempty(h.Members_) && isempty(h.Time)
    return
end

tsIntimevec = localUnitConv(h.TimeInfo.Units,ts.TimeInfo.Units)*ts.Time;
% If the tscollection has an absolute time vector any added time series
% must have a matching abs time vector
if ~isempty(h.TimeInfo.StartDate) 
    if isempty(ts.TimeInfo.StartDate) 
        error('tscollection:addts:badstartdate',...
            'The time series you are adding must have a valid StartDate property.')
    end
    % Account for differences in References of the tscollection and the
    % added timeseries
    tmpT = tsgetrelativetime(ts.TimeInfo.StartDate,h.TimeInfo.StartDate,h.TimeInfo.Units);    
    tsIntimevec = tsIntimevec+tmpT;
else
    if ~isempty(ts.TimeInfo.StartDate) 
        warning('tscollection:addts:ignorestartdate',...
            'The StartDate property of the time series you are adding was ignored because the tscollection does not use dates.')
    end    
end

% Does the time vector match
if ~tsIsSameTime(tsIntimevec,h.Time)
    error('tscollection:addts:badtime',...
        'The time vector of the time series you are adding must match the tscollection time vector.')
end

% Does the timemetadata class change
if ~strcmp(class(ts.TimeInfo),class(h.TimeInfo))
    warning('tscollection:addts:classchange',...
        xlate('The TimeInfo property of the added time series has been changed to match the tscollection.'))
end

%--------------------------------------------------------------------------
function h = localUpdateTS(h,ts,name)

% Update this tscollection object with the new time series if it does not
% have an invalid name

ts.Name = name;

if any(strcmpi(name,methods(h)))
    error('tscollection:addts:badmethod',...
        '%s is reserved as a tscollection method name.',name)
end
if strcmpi(ts.Name,'timeseries')
    error('tscollection:addts:badproperty',...
        '%s is a reserved tscollection property name.',name)
end

% Add this ts object into the collection
% Allow time vectors to mismatch when adding a timetimereis to an
% empty tscollection
if isempty(h.Members_) && isempty(h.Time)
    h.Time = ts.Time;
end
h = setts(h,ts,ts.Name);

%--------------------------------------------------------------------------
function convFactor = localUnitConv(outunits,inunits)

try
    % Get available units
    availableUnits = {'weeks', 'days', 'hours', 'minutes', 'seconds',...
         'milliseconds', 'microseconds', 'nanoseconds'};
    factors = [604800 86400 3600 60 1 1e-3 1e-6 1e-9];  
    indIn = find(strcmp(inunits,availableUnits));
    if isempty(indIn)
        return
    end
    factIn = factors(indIn);
    indOut = find(strcmp(outunits,availableUnits));
    if isempty(indOut)
        return
    end
    factOut = factors(indOut);
    convFactor = factIn/factOut;
catch me %#ok<NASGU>
    convFactor = 1; % Return 1 if error or unknown units
end
