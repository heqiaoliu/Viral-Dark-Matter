function [dtstr] = cnv2icudf(formatstr)
%   CNV2ICUDF maps date format tokens to ICU date format tokens
%   [ICUFORMAT] = CNV2ICUDF(MLFORMAT) turns the date
%   format into a date format that uses the format tokens of the ICU Libraries
%
%   INPUT PARAMETERS:
%   MLFORMAT: char string containing a user specified date format
%             string. See NOTE 1.
%
%   RETURN PARAMETERS:
%   ICUFORMAT: char string, containing date and, optionally, time formated
%              as per user specified format string.
%
%   EXAMPLES:
%   
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

% Copyright 2002-2007 The MathWorks, Inc.

if isempty(formatstr)
    dtstr = '';
    return
else
    dtstr = formatstr;
end

notAMPM = isempty(strfind(formatstr,'AM')) && isempty(strfind(formatstr,'PM'));

if notAMPM
else
    dtstr = strrep(dtstr,'AM','a'); % remove AM to avoid confusion below
    dtstr = strrep(dtstr,'PM','a'); % remove PM to avoid confusion below
end

showyr =  strfind(dtstr,'y'); wrtYr =  numel(showyr);
showmo =  strfind(dtstr,'m'); wrtMo =  numel(showmo);
showday = strfind(dtstr,'d'); wrtDay = numel(showday);
showhr =  strfind(dtstr,'H'); wrtHr =  numel(showhr);
showmin = strfind(dtstr,'M'); wrtMin = numel(showmin);
showsec = strfind(dtstr,'S'); wrtSec = numel(showsec);
showMsec = strfind(dtstr,'F'); wrtMsec = numel(showMsec);
showqrt = strfind(dtstr,'Q'); wrtQrt = numel(showqrt);
showT = strfind(dtstr,'T'); wrtT = numel(showT);

dtstr = strrep(dtstr,'M','N'); % to avoid confusion with ICU month tokens

if(wrtT > 0)
	dtstr = strrep(dtstr,'T','''T''');
end

% Format date
if wrtYr > 0
	if (wrtYr  ~= 4 && wrtYr ~= 2) || showyr(end) - showyr(1) >= wrtYr
		error('MATLAB:datestr:yearFormat','Unrecognized year format.');
	end
end
if wrtQrt > 0
    if wrtQrt == 2 && showqrt(2) - showqrt(1) == 1
        dtstr = strrep(dtstr,'QQ','MM');
    else
        error('MATLAB:datestr:quarterFormat','Unrecognized quarter format.');
    end
    if wrtMo > 0 || wrtDay > 0 || wrtHr > 0 || wrtMin > 0 || wrtSec > 0
        error('MATLAB:datestr:quarterFormat',...
        'Cannot use other time and date fields besides year and quarter.');
    end
end
if wrtMo > 0
	if wrtMo > 4 || showmo(end) - showmo(1) >= wrtMo
		error('MATLAB:datestr:monthFormat','Unrecognized month format.');
	end
	dtstr = strrep(dtstr,'m','M');
end
if wrtDay > 0
    replace.dddd = 'EEEE';
    replace.ddd = 'EEE';
    replace.d = 'E';
    replace.dd = 'dd';
    dtstr =regexprep(dtstr, '(d{1,4})', '${replace.($0)}');  
end 
% Format time
if wrtHr > 0
	if wrtHr == 2 && showhr(end) - showhr(1) < wrtHr
		if ~notAMPM
			dtstr = strrep(dtstr,'H','h'); 
		end
	else
		error('MATLAB:datestr:hourFormat','Unrecognized hour format.');    
	end
end
if wrtMin > 0 
	if wrtMin == 2 && showmin(end) - showmin(1) < wrtMin
		dtstr = strrep(dtstr,'N','m');
	else
		error('MATLAB:datestr:minuteFormat','Unrecognized minute format.');        
	end
end
if wrtSec > 0 
	if wrtSec == 2 && showsec(end) - showsec(1) < wrtSec
		dtstr = strrep(dtstr,'S','s');
	else
		error('MATLAB:datestr:secondFormat','Unrecognized second format.');        
	end 
end
if wrtMsec > 0 
	if wrtMsec == 3 && showMsec(end) - showMsec(1) < wrtMsec
		dtstr = strrep(dtstr,'F','S');
	else
		error('MATLAB:datestr:millisecondFormat','Unrecognized millisecond format.');        
	end 
end