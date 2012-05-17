%getReport Get error message for exception.
%   REPORT = getReport(ME) returns a formatted message string based on the
%   current exception (represented by MException object ME) and that uses
%   the same format as errors thrown by internal MATLAB code. The message
%   string returned by getReport is the same as the error message displayed
%   by MATLAB when it throws the exception.
%
%   REPORT = getReport(ME, TYPE) where TYPE is the type of report desired.
%   'basic' and 'extended' are the allowed types. 'extended' is the default
%   option which provides a formatted error message, a stack and causes
%   summary. The 'basic' report type returns a string with a formatted
%   error message only, without the stack and causes.
%
%   REPORT = getReport(ME, TYPE, 'hyperlinks', VALUE)
%       Where VALUE can be one of: 
%           'off'        --  insures no hyperlinks are added to the report
%           'on'         --  adds hyperlinks to the report
%           'default'    --  specifies that the default for the command
%                            window is used to determine if hyperlinks are
%                            added to the report.
%   Example:
%      try
%         surf
%      catch ME
%         report = getReport(ME)
%      end
%
%   See also MException, MESSAGE, ERROR, ASSERT, TRY, CATCH.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/02/25 08:09:53 $
%   Built-in function.
