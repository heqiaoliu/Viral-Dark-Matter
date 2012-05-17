function this = setuniformtime(this,varargin)
%SETUNIFORMTIME  Assigns a uniform time vector to a time series object.
% TSOUT = SETUNIFORMTIME(TSIN,'PROPERTYNAME',VALUE) returns a copy of the
% timeseries object TSIN where the time vector has been modified to be
% uniform. The uniform time vector is defined by the property
% ('PROPERTYNAME') and its given value (VALUE). 
% PROPERTYNAME can be any of the following strings: 
%       (1) 'StartTime' 
%       (2) 'Interval'
%       (3) 'EndTime'
%  
%  and VALUE must be a numeric scalar. The uniform time vector is
%  constructed to have the same length as the number of samples in TSIN as 
%  follows: The first unspecified value of 'StartTime','Interval','EndTime'
%  is assigned to a default value of 0,1,1 respectively and then the third 
%  remaining property is calculated to obtain a matching length.
%
% TSOUT =
% SETUNIFORMTIME(TSIN,'PROPERTYNAME1',VALUE1,'PROPERTYNAME2',VALUE2,...)
% returns a copy of the timeseries object TSIN where the time vector has 
% been modified to be uniform based on multiple parameters defined by the 
% property-value pairs ('PROPERTYNAME1',VALUE1,'PROPERTYNAME2',VALUE2, etc.)
% If all 3 uniform time properties are specified, the length of the uniform
% time vector defined by the specified parameters must match the number of 
% samples in TSIN. If only 2 uniform time properties are specified, the 
% third one is calculated to so that the length of the uniform time vector
% defined by the specified parameters matches the number of samples in TSIN.
% 
% Note that the uniform time is actually stored in compressed form using
% the specified parameters and is only constructed when the time vector is
% actually accessed via the TIME property.
%
%    EXAMPLES:
%
%      tsout = setuniformtime(tsin,'StartTime',10);
%
%   Assigns the time vector of ts1 to be uniformly spaced with interval 1
%   starting at time 10.
%
%      tsout = setuniformtime(tsin,'StartTime',10,'EndTime',20);
%
%   Assigns the time vector of ts1 to be uniformly spaced from a 
%   start time of 10 to and end time of 20 with interval chosen so that the
%   length of TSOUT matches that of TSIN.
%   See also TIMESERIES
%
 
%   Copyright 2009-2010 The MathWorks, Inc.


ni = nargin-1; % ni >= 1
PNVStart = 1;
if numel(this)~=1
    error('timeseries:setuniformtime:noarray',...
     'The setuniformtime method can only be used for a single timeseries object');
end

% The number of pv pairs must be even and >=2
if ni<2 || rem(ni,2)~=0
    error('timeseries:setuniformtime:invargs',...
        'setuniformtime requires a minimum of 2 property-value pairs.');
end

% timeseries cannot be empty
if this.Length<=0
    error('timeseries:setuniformtime:nonempty',...
        'setuniformtime requires a timeseries with at least one sample.');
end


startTime = NaN;
endTime = NaN;
interval = NaN;
for i=PNVStart:2:ni
    % Set each Property Name/Value pair in turn. 
    Property = varargin{i};
    if i+1>ni
        error('timeseries:setuniformtime:pvset',...
            'A specified property has no corresponding value.')
    else
        Value = varargin{i+1};
    end
    
    if ~ischar(Property)
        error('timeseries:setuniformtime:propnostr',...
            'Properties must be specified as strings.')
    end
    
    switch lower(Property)
        case 'starttime'
            % Assign the StartTime
            if ~isempty(Value) && isnumeric(Value) && isscalar(Value) 
                % StartTime has been specified 
                startTime = Value;
            else
                error('timeseries:setuniformtime:starttime',...
                    'StartTime property must be a numeric scalar.')
            end
        case 'endtime'
            % Assign the EndTime
            if ~isempty(Value) && isnumeric(Value) && isscalar(Value) 
                % EndTime has been specified 
                endTime = Value;
            else
                error('timeseries:setuniformtime:endtime',...
                    'EndTime property must be a numeric scalar.')
            end
        case 'interval'
            % Assign the Interval
            if ~isempty(Value) && isnumeric(Value) && isscalar(Value) 
                % Interval has been specified 
                interval = Value;
            else
                error('timeseries:setuniformtime:interval',...
                    'Interval property must be a numeric scalar.')
            end                   
        otherwise
            error('timeseries:setuniformtime:pvset','Invalid uniform time property.')
   end % switch
end % for

this.TimeInfo = this.TimeInfo.setuniformtime(startTime,interval,endTime);
