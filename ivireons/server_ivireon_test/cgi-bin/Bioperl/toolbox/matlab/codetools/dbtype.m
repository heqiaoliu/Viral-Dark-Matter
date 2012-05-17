%DBTYPE Display program file with line numbers
%   The DBTYPE function displays the contents of a MATLAB program file with
%   line numbers to aid the user in setting breakpoints.  There are two
%   forms to this command.  They are:
%
%   DBTYPE FILESPEC
%   DBTYPE FILESPEC RANGE
%
%   DBTYPE FILESPEC displays the contents of the MATLAB program file
%   specified by FILESPEC. The FILESPEC input is a string containing the
%   file name and possibly the full or partial path to the file (see
%   PARTIALPATH).
%
%   DBTYPE FILESPEC RANGE displays those lines of the program file that 
%   are within the specified RANGE of line numbers. The RANGE input
%   consists of a starting line number, followed by a colon, followed by 
%   an ending line number, as shown here:
%
%      dbtype myfun.m 10:24    % Display lines 10 through 24 of myfun.m.
%

%   See also DBSTEP, DBSTOP, DBCONT, DBCLEAR, DBSTACK, DBUP, DBDOWN,
%            DBSTATUS, DBQUIT, PARTIALPATH, TYPE.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/03/31 18:23:21 $
%   Built-in function.

