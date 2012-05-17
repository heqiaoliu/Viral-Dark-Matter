function display(h)
%DISPLAY  Overloaded DISPLAY

%   Copyright 2005-2010 The MathWorks, Inc.

fprintf('\nTime Series Collection Object: %s\n\n',h.Name);

% Check for empty time
if isempty(h.Time)
    fprintf(1,'      Empty\n\n');
    return
end

fprintf(1,'Time vector characteristics\n\n'); % Time vector characteristics
if ~isempty(h.TimeInfo.Startdate)
    % time is in absolute date/time format
    formatstr = '      %s%s%s\n';
    strStartTime = xlate('Start date');
    strEndTime = xlate('End date');
    % determine the display format
    if tsIsDateFormat(h.TimeInfo.Format)
        % display format has been specified and the format is supported by tstool
        fprintf(1,formatstr, strStartTime, blanks(22-length(strStartTime)), ...
            datestr(tsunitconv('days',h.TimeInfo.Units)*h.TimeInfo.Start+...
            datenum(h.TimeInfo.Startdate),h.TimeInfo.Format));
        fprintf(1,formatstr, strEndTime, blanks(22-length(strEndTime)), ...
            datestr(tsunitconv('days',h.TimeInfo.Units)*h.TimeInfo.End+...
            datenum(h.TimeInfo.StartDate),h.TimeInfo.Format));   
    else
        % use default display format 0: 'dd-mmm-yyyy HH:MM:SS'
        fprintf(1,formatstr, strStartTime, blanks(22-length(strStartTime)), ...
            datestr(tsunitconv('days',h.TimeInfo.Units)*h.TimeInfo.Start+...
            datenum(h.TimeInfo.Startdate),'dd-mmm-yyyy HH:MM:SS'));
        fprintf(1,formatstr, strEndTime, blanks(22-length(strEndTime)), ...
            datestr(tsunitconv('days',h.TimeInfo.Units)*h.TimeInfo.End+...
            datenum(h.TimeInfo.Startdate),'dd-mmm-yyyy HH:MM:SS'));   
    end           
else
    if ~isempty(h.TimeInfo.Startdate)
        startdatestr = xlate('Reference start date');
        fprintf(1,'      %s%s%s\n', startdatestr, ...
            blanks(22-length(startdatestr)),h.TimeInfo.Startdate);
    end
    strStartTime = xlate('Start time');
    strEndTime = xlate('End time');
    formatstr = '      %s%s%d %s\n';
    fprintf(1,formatstr, strStartTime, blanks(22-length(strStartTime)), h.TimeInfo.Start, h.TimeInfo.Units);
    fprintf(1,formatstr, strEndTime, blanks(22-length(strEndTime)), h.TimeInfo.End, h.TimeInfo.Units);
end    

memberVars = gettimeseriesnames(h);
fprintf(1,'\nMember Time Series Objects:\n\n');
for k=1:length(memberVars)
    fprintf(1,'      %s\n', memberVars{k});
end
fprintf(1,'\n\n');
