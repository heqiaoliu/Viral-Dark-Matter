function this = delsample(this,method,value)
%DELSAMPLE  Delete one or more samples from a timeseries object
%
%   TS = DELSAMPLE(TS,'Index',VALUE) removes samples from the timeseries 
%   object TS. Here, VALUE specifies the indices of the TS time vector that
%   correspond to the samples you want to remove.
%   
%   TS = DELSAMPLE(TS,'Value',VALUE) removes samples from the time series 
%   object TS. Here, VALUE speifies the time values that correspond to the
%   samples you want to remove.  
%
%   See also TIMESERIES/TIMESERIES, TIMESERIES/ADDSAMPLE

%   Copyright 2005-2010 The MathWorks, Inc.


TimeValue = this.Time;

if isempty(value)
    return;
end

if numel(this)~=1
    error('timeseries:delsample:noarray',...
        'The delsample method can only be used for a single timeseries object');
end

%% Process command
if ischar(method) && isvector(method)
    switch lower(method)
        case 'index'
            if ~isnumeric(value) || ~isvector(value)
                error('timeseries:delsample:invalidindex',...
                    'Indices must be specified by a vector of integers.');
            else
                % Make sure indices are unique
                selectedIndexArray = unique(value);
                % Check if all the indices are valid    
                if ~isequal(round(selectedIndexArray),selectedIndexArray)
                    error('timeseries:delsample:nonintegerindex',...
                        'Specified indices are not integers.')
                elseif any(selectedIndexArray <= 0) || any(selectedIndexArray > this.Length)
                       error('timeseries:delsample:outofboundsindex',...
                        'Specified indices are out of bounds.')
                end
                
            end
        case 'value'
            % If it is an array of char (absolute date)
            if ischar(value) || iscellstr(value)
                % If time series object requires relative time points, error out
                if isempty(this.Timeinfo.Startdate)
                    error('timeseries:delsample:nostartdate',...
                        'Time must be a numeric value.');
                end
                % Otherwise, get time values relative to the StartDate and Units values
                try
                    value = tsAnalyzeAbsTime(value,this.Timeinfo.Units,...
                        this.Timeinfo.Startdate);
                catch                     %#ok<*CTCH>
                    error('timeseries:delsample:timeconversion',...
                        'The time value cannot be converted to the timeseries format')
                end
                selectedIndexArray = ismember(round(TimeValue(:) *1e10),round(value(:) * 1e10));
            elseif isnumeric(value) && isvector(value)
                selectedIndexArray = ismember(TimeValue(:),value(:));
            else
                error('timeseries:delsample:invalidtime',...
                    'The Value input must be a date string, cell array of date strings, or numeric');
            end
            if isempty(selectedIndexArray)
                return;
            end
        % case 'nearest'
            % TO DO
        otherwise
            error('timeseries:delsample:unrecognizedmethod',...
                'You must specify a sample index or time to delete each sample.')
    end
else
    error('timeseries:delsample:invalidmethod',...
        'The second argument must be a string specifying the method that identifies the samples to be deleted.')
end

beingBuiltCache = this.BeingBuilt;
this.BeingBuilt = true;
% Update grid info
this.TimeInfo = setlength(this.TimeInfo,this.TimeInfo.Length-length(selectedIndexArray));
% Update data for grid variables
TimeValue(selectedIndexArray) = [];
this.Time = TimeValue;

% Update data for dependent values
is = repmat({':'},[1 length(this.getdatasamplesize)]);
if this.IsTimeFirst
    tempIndex = [{selectedIndexArray} is];
else
    tempIndex = [is {selectedIndexArray}];
end
tmpData = this.Data;
tmpData(tempIndex{:}) = [];
this.Data = tmpData;
if ~isempty(this.Quality)
    this.Quality(selectedIndexArray) = [];
end
this.BeingBuilt = beingBuiltCache;

