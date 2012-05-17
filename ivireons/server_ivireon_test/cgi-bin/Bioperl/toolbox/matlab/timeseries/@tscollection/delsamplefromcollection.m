function this = delsamplefromcollection(this,method,value)
%DELSAMPLEFROMCOLLECTION  Delete sample(s) from a tscollection object.
%
%   TSC = DELSAMPLEFROMCOLLECTION(TSC,'Index',VALUE) removes samples from
%   the tscollection
%   object TSC. Here, VALUE specifies the indices of the TSC time vector that
%   correspond to the samples you want to remove.
%   
%   TSC = DELSAMPLEFROMCOLLECTION(TSC,'Value',VALUE) removes samples from the tscollection
%   object TSC. Here, VALUE speifies the time values that correspond to the
%   samples you want to remove.  
%
%   See also TSCOLLECTION/TSCOLLECTION, TSCOLLECTION/ADDSAMPLETOCOLLECTION

%   Copyright 2005-2009 The MathWorks, Inc.


% Process input args
if ischar(method) && isvector(method)
    switch lower(method)
        case 'index'
            if ~isnumeric(value) || ~isvector(value)
                error('tscollection:delsample:needinteger',...
                    'Indices must be specified by a vector of integers.');
            else
                % Make sure indices are unique
                selectedIndexArray = unique(value);
                % Check if all the indices are valid    
                if ~isequal(round(selectedIndexArray),selectedIndexArray) || any(selectedIndexArray<0) || ...
                        any(selectedIndexArray>this.Length)
                    error('tscollection:delsample:badindex',...
                        'Specified indices are either not integers, out of bounds, or negative.')
                end
            end
        case 'value'
            % If it is an array of char (absolute date)
            if ischar(value) || iscellstr(value)
                % If time series object requires relative time points, error out
                if isempty(this.Timeinfo.Startdate)
                    error('tscollection:delsample:badvalue',...
                        'Time must be a numeric value.');      
                else  % Otherwise, get time values relative to the StartDate and Units values   
                    value = tsAnalyzeAbsTime(value,this.Timeinfo.Units,this.Timeinfo.Startdate);
                end
            elseif isnumeric(value) && isvector(value)
                % Make sure time is a column vector
                if size(value,2) > 1
                    value = value';
                end
            else
                error('tscollection:delsample:badtimeformat',...
                    'Invalid time format');
            end
            try
                selectedIndexArray = ismember(this.Time,value);
            catch %#ok<*CTCH>
                error('tscollection:delsample:badformat',...
                    'The specified time format does not match the time format of the time series.')
            end
            if isempty(selectedIndexArray)
                return;
            end
        case 'nearest'
            % TO DO
        otherwise
            error('tscollection:delsample:badsyntax',...
                'You must specify a sample index or time to delete each sample.')
    end
else
    error('tscollection:delsample:badmethod',...
        'The second argument must be a string specifying the method that identifies the samples to be deleted.')
end

% Delete sample in a loop

% Modify the time vector
time = this.Time;
time(selectedIndexArray) = [];
this.TimeInfo = setlength(this.TimeInfo,length(time));
this.Time = time;

% Modify the members
for k=1:length(this.Members_)   
    ind = repmat({':'},[1 ndims(this.Members_(k).Data)-1]);
    if this.Members_(k).IsTimeFirst
        this.Members_(k).Data(selectedIndexArray,ind{:}) = [];
        if ~isempty(this.Members_(k).Quality)
           ind = repmat({':'},[1 ndims(this.Members_(k).Quality)-1]);
           this.Members_(k).Quality(selectedIndexArray,ind{:}) = [];
        end
    else
        this.Members_(k).Data(ind{:},selectedIndexArray) = [];
        if ~isempty(this.Members_(k).Quality)
           ind = repmat({':'},[1 ndims(this.Members_(k).Quality)-1]);
           this.Members_(k).Quality(ind{:},selectedIndexArray) = [];
        end
    end
end