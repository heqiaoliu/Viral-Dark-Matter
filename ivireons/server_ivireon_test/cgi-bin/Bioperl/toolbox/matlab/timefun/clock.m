%CLOCK  Current date and time as date vector.
%   C = CLOCK returns a six element date vector containing the current time
%   and date in decimal form:
% 
%      [year month day hour minute seconds]
% 
%   The sixth element of the date vector output (seconds) is accurate to
%   several digits beyond the decimal point. FIX(CLOCK) rounds to integer
%   display format.
%
%   Note: When timing the duration of an event, use the TIC and TOC
%   functions instead of CLOCK or ETIME. These latter two functions are
%   based on the system time which can be adjusted periodically by the
%   operating system and thus might not be reliable in time comparison
%   operations.
%
%   See also DATEVEC, DATENUM, NOW, ETIME, TIC, TOC, CPUTIME.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 5.11.4.6 $  $Date: 2008/07/23 18:29:36 $
%   Built-in function.