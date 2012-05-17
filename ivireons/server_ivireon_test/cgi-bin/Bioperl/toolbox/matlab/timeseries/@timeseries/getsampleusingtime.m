function ts = getsampleusingtime(this,StartTime,varargin)
%GETSAMPLEUSINGTIME  Extract samples from a time series object between a
% specified start and end time values into a new time series object
% 
% TS2 = GETSAMPLEUSINGTIME(TS1,TIME) returns a new time series TS2 with a
% single sample corresponding to time TIME in TS1
%
% TS2 = GETSAMPLEUSINGTIME(TS1,START,END) returns a new time series TS2 with 
% samples between the times START and END in TS1
%
% TS2 = GETSAMPLEUSINGTIME(TS1,TIME,'ALLOWDUPLICATETIMES',VALUE)
% You can explicitly allow the single time case to return multiple samples 
% when it coincides with a duplicate time value by adding the Property-Value
% pair: 'allowduplicatetimes',VALUE where VALUE is either true or false.
%
% Note: (1) When the time vector in TS1 is numeric, START and END must be
% numeric. (2) When the times in TS1 are date strings, but the START
% and END values are numeric, START and END values are treated as DATENUM
% values.
%

%   Copyright 2005-2010 The MathWorks, Inc.

error(nargchk(2,5,nargin,'struct'));
if numel(this)~=1
    error('timeseries:getsampleusingtime:noarray',...
        'The getsampleusingtime method can only be used for a single timeseries object');
end
if this.Length==0
    ts = this;
    return
end

% Parse the inputs
allowduplicatetimes = false;
if nargin == 2
    EndTime = StartTime;
elseif nargin==3
    EndTime = varargin{1};
elseif nargin==4 
    if ischar(varargin{1}) && strcmpi('allowduplicatetimes',varargin{1}) && ...
        isscalar(varargin{2})
        EndTime = StartTime;
        allowduplicatetimes = logical(varargin{2});
    else
        error('timeseries:getsampleusingtime:invalidpv',...
            'Invalid property-value pair.')
    end
end


% Only work if the time vector is absolute
if isempty(this.TimeInfo.StartDate)
    % The time vector is relative for this time series object
    % in this case, start and end have to be numeric values
    if isnumeric(StartTime) && isnumeric(EndTime)
        StartIndex = find(this.Time >= StartTime);
        EndIndex = find(this.Time <= EndTime);        
    else
        error('timeseries:getsampleusingtime:invalidrelativetime',...
            'The start and end times must be numeric values.')
    end
else
    % The time vector is absolute for this time series object
    % in this case, if start and end are numeric values, they are treated
    % as datenum value; if start and end are strings, they are treated
    % as date strings; otherwise error out
    if (ischar(StartTime) && ischar(EndTime)) || ...
       (isnumeric(StartTime) && isnumeric(EndTime))
        StartValue = timeseries.tsgetrelativetime(StartTime,...
            this.TimeInfo.StartDate,this.TimeInfo.Units);
        EndValue = timeseries.tsgetrelativetime(EndTime,...
            this.TimeInfo.StartDate,this.TimeInfo.Units);
        StartIndex = find(this.Time >= StartValue);
        EndIndex = find(this.Time <= EndValue);        
    else
        error('timeseries:getsampleusingtime:invalidabsolutetime',...
            'Invalid start time format')
    end
end
index = intersect(StartIndex,EndIndex);

% Check that we are not asking for a single time value which coincides with
% a duplicate time.
if ~allowduplicatetimes && this.hasduplicatetimes && length(index)>=2
    error('timeseries:getsampleusingtime:invalidduptimes',...
        'The specified time value is duplicated in the timeseries. Set the AllowDuplicateTimes flag when calling GETSAMPLEUSINGTIME to obtain samples at a duplicate time');
end

if ~isempty(index)
    ts = getsamples(this,index);
else
    ts = timeseries;
    ts.Name = 'unnamed';
end