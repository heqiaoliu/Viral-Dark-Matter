%DBCLEAR Clear breakpoints
%   The DBCLEAR command removes the breakpoint set by a corresponding DBSTOP
%   command. There are several forms to this command. They are:
%
%   (1)  DBCLEAR in FILESPEC at LINENO
%   (2)  DBCLEAR in FILESPEC at LINENO@
%   (3)  DBCLEAR in FILESPEC at LINENO@N
%   (4)  DBCLEAR in FILESPEC at SUBFUN
%   (5)  DBCLEAR in FILESPEC
%   (6)  DBCLEAR if ERROR
%   (7)  DBCLEAR if CAUGHT ERROR
%   (8)  DBCLEAR if WARNING
%   (9)  DBCLEAR if NANINF  or  DBCLEAR if INFNAN
%   (10) DBCLEAR if ERROR IDENTIFIER
%   (11) DBCLEAR if CAUGHT ERROR IDENTIFIER
%   (12) DBCLEAR if WARNING IDENTIFIER
%   (13) DBCLEAR ALL
%
%   FILESPEC is the name of a MATLAB program file or a MATLABPATH-relative
%   partial pathname (see PARTIALPATH). If the command includes the
%   -completenames option, then FILESPEC need not be on the path, as long
%   as it is specified as a fully qualified file name. (On Windows, this is
%   a file name that begins with \\ or with a drive letter followed by a
%   colon. On Unix, this is a file name that begins with / or ~.) FILESPEC
%   can include a filemarker to specify the path to a particular
%   subfunction or to a nested function within a program file.
%
%   LINENO is a line number within the file specified by FILESPEC, N is an
%   integer specifying the Nth anonymous function on the line, and SUBFUN
%   is the name of a subfunction within the file. IDENTIFIER is a
%   MATLAB Message Identifier (see help for ERROR for a description of
%   message identifiers). The AT and IN keywords are optional.
% 
%   The several forms behave as follows:
%
%   (1)  Removes the breakpoint at line LINENO in the program file
%        specified by FILESPEC.
%   (2)  Removes the breakpoint in the first anonymous function at line LINENO
%        in the file.
%   (3)  Removes the breakpoint in the Nth anonymous function at line LINENO
%        in the file.  (Use this when there is more than one anonymous function
%        on the same line.)
%   (4)  Removes all breakpoints in the specified subfunction in the file.
%   (5)  Removes all breakpoints in the file.
%   (6)  Clears the DBSTOP IF ERROR statement and any DBSTOP IF ERROR
%        IDENTIFIER statements, if set.
%   (7)  Clears the DBSTOP IF CAUGHT ERROR statement, and any DBSTOP IF CAUGHT
%        ERROR IDENTIFIER statements, if set.
%   (8)  Clears the DBSTOP IF WARNING statement, and any DBSTOP IF WARNING
%        IDENTIFIER statements, if set.
%   (9)  Clears the DBSTOP on infinities and NaNs, if set.
%   (10) Clears the DBSTOP IF ERROR IDENTIFIER statement for the specified
%        IDENTIFIER. It is an error to clear this setting on a specific
%        identifier if DBSTOP IF ERROR or DBSTOP IF ERROR ALL is set.
%   (11) Clears the DBSTOP IF CAUGHT ERROR IDENTIFIER statement for the 
%        specified IDENTIFIER. It is an error to clear this setting on a 
%        specific identifier if DBSTOP if caught error or DBSTOP if caught 
%        ERROR all
%        is set. 
%   (12) Clears the DBSTOP IF WARNING IDENTIFIER statement for the specified
%        IDENTIFIER. It is an error to clear this setting on a specific
%        identifier if DBSTOP IF WARNING or DBSTOP IF WARNING ALL is set.
%   (13) Removes all breakpoints in all MATLAB program files, as well as
%        those mentioned in (6)-(9) above.
%
%   See also DBSTEP, DBSTOP, DBCONT, DBTYPE, DBSTACK, DBUP, DBDOWN, DBSTATUS,
%            DBQUIT, ERROR, PARTIALPATH, TRY, WARNING.

%   Steve Bangert, 6-25-91. Revised, 1-3-92.
%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $  $Date: 2010/03/31 18:23:17 $
%   Built-in function.
