function [Time,Startdate]=tsAnalyzeAbsTime(timeArray,Units,varargin)
%
% tstool utility function
% TSANALYZEABSTIME inteprets absolute date/time string and returns
% information needed
%
% [Time,Format,Startdate]=TSANALYZEABSTIME(timeArray, Unit, varargin) check
% the string content in the timeArray, which can be either a cell array of
% strings or a char array.  Unit should be one of 'weeks', 'days', 'hours',
% 'minutes', 'seconds', 'milliseconds', 'microseconds', 'nanoseconds'.
% Varargin, if supplied, should be a string containing a valid absolute
% start date, e.g. '10-Oct-2004 12:34:56', which is used as the reference
% date for generating the relative time value. 
%
% Time is the numeric value (in the given unit) of TimeArray relative to
% either the reference date (if suuplied) or the first time point in
% TimeArray. However, if TimeArray contains only hour/minute/second (e.g.
% 'HH:MM:SS'), Time is the numeric value (in the given unit) of TimeArray
% relative to the '00:00:00' time point.
% 
% Format returns the default display format, which is either the Standard
%   % Revision % % Date %
%
% Startdate returns the first value in TimeArray if no reference date is
% supplied.  Otherwise, it returns the reference date.
%

%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2009/08/23 19:05:55 $

if nargin == 4
    try
        % get abs time in [year mon day hour min sec] format and sort them
        dateVec = sortrows(round(datevec(timeArray,varargin{2})));
    catch %#ok<*CTCH>
        error('timeseries:tsAnalyzeAbsTime:invalidformat',...
            'Invalid date string format');
    end
else    
    try
        % get abs time in [year mon day hour min sec] format and sort them
        dateVec = sortrows(round(datevec(timeArray)));
    catch
        error('timeseries:tsAnalyzeAbsTime:invalidformat',...
            'Invalid date string format');
    end
end

% get time difference and convert it into date number format
YMD_half=dateVec;
YMD_half(:,4:6)=0;
HMS_half=dateVec;
HMS_half(:,1:3)=0;
YMD_dateNum=datenum(YMD_half);
HMS_dateNum=datenum(HMS_half);

% get the first time point string
if iscell(timeArray)
    refPoint=timeArray{1};
else
    refPoint=timeArray(1,:);
end

% start date is supplied by user
if ~isempty(varargin) && ~isempty(varargin{1})
    % reference time point is provided
    if ~(ischar(varargin{1}) && isvector(varargin{1}))
        error('timeseries:tsAnalyzeAbsTime:invalidrefpoint',...
            'The reference time point should be a string.');
    end
    if length(refPoint)<=11 && ~isempty(strfind(refPoint,':'))
        % contains only hour/minute/second information
        % ignore the reference time point
        Time = tsunitconv(Units,'days')*(YMD_dateNum-datenum('00:00:00')) + tsunitconv(Units,'days')*HMS_dateNum;
        % set format
        % Format = 'HH:MM:SS';
        % set start date empty
        Startdate = '';        
    else
        % time point is in date format
        if length(refPoint)<=11 && ~isempty(strfind(refPoint,':'))
            error('timeseries:tsAnalyzeAbsTime:invalidtimevalue',...
                'Time value must be a date string (e.g. ''10/25/2004 12:34:56'').');
        else
            try
                dateVecStart = round(datevec(varargin{1}));
            catch
                error('timeseries:tsAnalyzeAbsTime:invalidstartdateformat',...
                    'Format of the start date is not recognizable.');
            end
            % get time difference and convert it into date number format
            YMD_halfStart=dateVecStart;
            YMD_halfStart(:,4:6)=0;
            HMS_halfStart=dateVecStart;
            HMS_halfStart(:,1:3)=0;
            YMD_dateNumStart=datenum(YMD_halfStart);
            HMS_dateNumStart=datenum(HMS_halfStart);
            % contains absolute date information
            Time = tsunitconv(Units,'days')*(YMD_dateNum-YMD_dateNumStart) + tsunitconv(Units,'days')*(HMS_dateNum-HMS_dateNumStart);
            % set format
            % Format = 'dd-mmm-yyyy HH:MM:SS';
            % set start date
            Startdate = varargin{1};
        end
    end    
else
    % use string length and ':' to identify whether it contains date or not
    if length(refPoint)<=11 && ~isempty(strfind(refPoint,':'))
        % contains only hour/minute/second information
        Time = tsunitconv(Units,'days')*(YMD_dateNum-datenum('00:00:00')) + tsunitconv(Units,'days')*HMS_dateNum;
        % set format
        % Format = 'HH:MM:SS';
        % set start date empty
        Startdate = '';        
    else
        % contains absolute date information
        Time = tsunitconv(Units,'days')*(YMD_dateNum-YMD_dateNum(1)) + tsunitconv(Units,'days')*(HMS_dateNum-HMS_dateNum(1));
        % set format
        % Format = 'dd-mmm-yyyy HH:MM:SS';
        % set start date and force it to be the desired format: 'dd-mmm-yyyy HH:MM:SS'
        Startdate = datestr(datenum(dateVec(1,:)),0);
    end
end