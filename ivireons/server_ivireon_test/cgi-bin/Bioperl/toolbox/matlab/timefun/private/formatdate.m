function [dtstrarray] = formatdate(dtvector,formatstr,islocal)
%   FORMATDATE casts date vector into a specified date format
%   [DATESTRING] = FORMATDATE(DATEVECTOR, FORMATSTRING) turns the date
%   vector into a formated date string, according to the user's date
%   format template.
%
%   INPUT PARAMETERS:
%   DATEVECTOR: 1 x m double array, containing standard MATLAB date vector.
%   FORMATSTRING: char string containing a user specified date format
%                 string. See NOTE 1.
%
%   RETURN PARAMETERS:
%   DATESTRING: char string, containing date and, optionally, time formated
%               as per user specified format string.
%
%   EXAMPLES:
%   The date vector [2002 10 01 16 8] reformed as a date and time string,
%   using a user format, 'dd-mm-yyyy HH:MM', will display as 
%   01-10-2002 16:08 .
%   
%   NOTE 1: The format specifier allows free-style date format, within the
%   following limits - 
%   ddd  => day is formatted as abbreviated name of weekday
%   dd   => day is formatted as two digit day of month
%   d    => day is formatted as first letter of day of month
%   mmm  => month is formatted as three letter abbreviation of name of month
%   mm   => month is formatted as two digit month of year
%   m    => month is formatted as one or two digit month of year
%   yyyy => year is formatted as four digit year
%   yy   => year is formatted as two digit year
%   HH   => hour is formatted as two digit hour of the day
%   MM   => minute is formatted as two digit minute of the hour
%   SS   => second is formatted as two digit second of the minute
%   The user may use any separator and other delimiters of his liking, but
%   must confine himself to the above format tokens regarding day, month,
%   year, hour, minute and second.
% 
%   
%------------------------------------------------------------------------------

% Copyright 2003-2009 The MathWorks, Inc.

if isempty(dtvector) || isempty(formatstr)
    dtstrarray = '';
    return
else
    dtstr = formatstr;
end

notAMPM = isempty(strfind(formatstr,'AM')) && isempty(strfind(formatstr,'PM'));
year = []; month = []; day = []; dayOfWeek= []; hour = []; minute = []; second = []; 
millisecond = [];
wrtWeekday = 0; wrtday = 0;

% make sure days are capital D and seconds are capital second, so as not to
% confuse d for day with d as in %d when building conversion string.
dtstr = strrep(dtstr,'d','D');
dtstr = strrep(dtstr,'s','S');
dtstr = strrep(dtstr,'Y','y');
if notAMPM
else
    if islocal
        ampm = getampmtokensmx;
    else
        ampm = {'AM','PM'};
    end
    dtstr = strrep(dtstr,'AM',''); % remove AM to avoid confusion below
    dtstr = strrep(dtstr,'PM',''); % remove PM to avoid confusion below
end

%All indices for sorting are computed before modifying the length of the
%string
showyr =  strfind(dtstr,'y'); wrtYr =  numel(showyr);
showmo =  strfind(dtstr,'m'); wrtMo =  numel(showmo);                     
showhr =  strfind(dtstr,'H'); wrtHr =  numel(showhr);
showmin = strfind(dtstr,'M'); wrtMin = numel(showmin);
showsec = strfind(dtstr,'S'); wrtSec = numel(showsec);
showMsec = strfind(dtstr,'F'); wrtMsec = numel(showMsec);
showqrt = strfind(dtstr,'Q'); wrtQrt = numel(showqrt);
[starts, ends] = regexp(dtstr, 'D{1,4}', 'start', 'end');

% Format date
if wrtYr > 0
	if showyr(end) - showyr(1) >= wrtYr
		error('MATLAB:datestr:yearFormat','Unrecognized year format. Format string: %s.', formatstr);
	end
    switch wrtYr
        case 4,
            dtstr = strrep(dtstr,'yyyy','%.4d');
        case 2,
            dtstr = strrep(dtstr,'yy','%02d');
            dtvector(:,1) = mod(abs(dtvector(:,1)),100);
        otherwise
            error('MATLAB:formatdate:yearFormat','Unrecognized year format. Format string: %s.', formatstr);
    end
    showyr = showyr(1);
	year = mod(dtvector(:,1),10000); 
end
if wrtQrt > 0
	if wrtQrt~= 2 || showqrt(end) - showqrt(1) >= wrtQrt
		error('MATLAB:formatdate:quarterFormat','Unrecognized quarter format. Format string: %s.', formatstr);
	end
    dtstr = strrep(dtstr,'QQ','Q%1d');
    if wrtMo > 0 || wrtday > 0 || wrtHr > 0 || wrtMin > 0 || wrtSec > 0
        error('MATLAB:formatdate:quarterFormat',...
        'Cannot use other time and date fields besides year and quarter.  Format string: %s.', formatstr);
    end
    showqrt = showqrt(1);
	qrt = floor((dtvector(:,2)-1)/3)+1;
end
if wrtMo > 0
	if showmo(end) - showmo(1) >= wrtMo
		error('MATLAB:formatdate:monthFormat','Unrecognized month format.  Format string: %s.', formatstr);
	end
    switch wrtMo
        case 4,
            %long month names
            if islocal
                month = getmonthnamesmx('longloc');
            else
                month = getmonthnamesmx('long');
            end
            monthfmt = '%s';
            dtstr = strrep(dtstr,'mmmm',monthfmt);
            month = char(month(dtvector(:,2)));
        case 3,
            if islocal
                month = getmonthnamesmx('shortloc');
            else
                month = {'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'};
            end
            monthfmt = '%s';
            dtstr = strrep(dtstr,'mmm',monthfmt);
            month = char(month(dtvector(:,2)));
        case 2,
            dtstr = strrep(dtstr,'mm','%02d');
            month = abs(dtvector(:,2));
        case 1,
            if islocal
                month = getmonthnamesmx('shortloc');
            else
                month = {'J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'};
            end
            dtstr = strrep(dtstr,'m','%.1s');
            month = char(month(dtvector(:,2)));
        otherwise
            error('MATLAB:formatdate:monthFormat','Unrecognized month format.  Format string: %s.', formatstr);
    end
    showmo = showmo(1);
end

%Replace the various day and Weekday formats with the corresponding format
%specifications.
dtstr = strrep(dtstr, 'DDDD', '%s');
dtstr = strrep(dtstr, 'DDD', '%s');
dtstr = strrep(dtstr, 'DD', '%02d');
dtstr = strrep(dtstr, 'D', '%s');
showday = [];
showWeekDay = [];
for i = 1: length(starts)
    if ends(i) - starts(i) == 1
        if ~isempty(showday) %Only one numeric day subformat allowed
            error('MATLAB:formatdate:dayFormat','Unrecognized day format.  Format string: %s.', formatstr);
        end
        wrtday = 1;
        showday = starts(i);
        day = abs(dtvector(:,3));
    else
        if ~isempty(showWeekDay) %Only one weekday subformat allowed
            error('MATLAB:formatdate:dayFormat','Unrecognized day format.  Format string: %s.', formatstr);
        end
        showWeekDay = starts(i);
        wrtWeekday = 1; 
        if islocal
            locale = 'local';
        else
            locale = 'en_us';
        end
        switch  ends(i) - starts(i)
            case 3,
                %long month names
                [daynr,dayOfWeek] = weekday(datenum(dtvector), 'long', locale);%#ok
            case {0, 2},
                [daynr,dayOfWeek] = weekday(datenum(dtvector), locale);%#ok
                if (ends(i) == starts(i))
                    dayOfWeek = dayOfWeek(:,1);
                end
        end
    end
end

% Format time
if wrtHr > 0
    if wrtHr ~= 2 || showhr(end) - showhr(1) >= wrtHr
        error('MATLAB:formatdate:hourFormat','Unrecognized hour format.  Format string: %s.', formatstr);
    end
    if notAMPM
        fmt = '%02d';
    else
        fmt = '%2d';
        h = dtvector(:,4);
        c(h<12) = ampm(1);
        c(h>=12) = ampm(2);
        dtvector(:,4) = mod(h-1,12) + 1; % replace hour column with 12h format.
        dtstr = [dtstr '%s']; % append conversion string for AM or PM
    end
	dtstr = strrep(dtstr,'HH',fmt); 
    hour   = dtvector(:,4); 
	showhr = showhr(1);
end

if wrtMin > 0
	if wrtMin ~= 2 || showmin(end) - showmin(1) >= wrtMin
		error('MATLAB:formatdate:minuteFormat','Unrecognized minute format.  Format string: %s.', formatstr);    
	end
    dtstr = strrep(dtstr,'MM','%02d');
	minute = dtvector(:,5); 
	showmin = showmin(1);
end

if wrtSec > 0
	if wrtSec ~= 2 || showsec(end) - showsec(1) >= wrtSec
		error('MATLAB:formatdate:secondFormat','Unrecognized second format.  Format string: %s.', formatstr);     	
	end	
    dtstr = strrep(dtstr,'SS','%02d');
	second = floor(dtvector(:,6));
	showsec = showsec(1);
end

if wrtMsec > 0
	if wrtMsec ~= 3 || showMsec(end) - showMsec(1) >= wrtMsec
		error('MATLAB:formatdate:millisecondFormat','Unrecognized millisecond format.  Format string: %s.', formatstr);     	
	end	
    dtstr = strrep(dtstr,'FFF','%03d');
	millisecond = floor(1000*(dtvector(:,6) - floor(dtvector(:,6))));
	showMsec = showMsec(1);
end
% build date-time array to print
if wrtQrt > 0
    dtorder = [showyr, showqrt];    
    dtarray = [{year} {qrt}];
    dtarray = dtarray([(wrtYr>0) (wrtQrt>0)]);
else
    dtorder = [showyr, showmo, showday, showWeekDay, showhr, showmin, showsec, showMsec];
    dtarray = [{year} {month} {day} {dayOfWeek} {hour} {minute} {second} {millisecond}];
    dtarray = dtarray([(wrtYr>0) (wrtMo>0) (wrtday>0) (wrtWeekday>0) (wrtHr>0) ...
         (wrtMin>0) (wrtSec>0) (wrtMsec>0)]);
end

% sort date vector in the order of the time format fields
[tmp,dtorder] = sort(dtorder);%#ok

% print date vector using conversion string
dtarray = dtarray(dtorder);
rows = size(dtvector,1);
if (rows == 1)
    %optimize if only one member
    if notAMPM
        dtstrarray = sprintf(dtstr,dtarray{:});
    else
        dtstrarray = sprintf(dtstr,dtarray{:},char(c));
    end
else
    dtstrarray = cell(rows,1);
    numeldtarray = length(dtarray);
    thisdate = cell(1,numeldtarray);
    for i = 1:rows
        for j = 1:numeldtarray
            % take horzontal slice through cells
            thisdate{j} = dtarray{j}(i,:);
        end
        if notAMPM
            dtstrarray{i} = sprintf(dtstr,thisdate{:});
        else
            dtstrarray{i} = sprintf(dtstr,thisdate{:},char(c{i}));
        end
    end
end
