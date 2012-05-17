%DBSTOP Set breakpoints
%   The DBSTOP function is used to temporarily stop the execution of a
%   program and give the user an opportunity to examine the local
%   workspace. There are several forms to this command. They are:
%
%   (1)  DBSTOP in FILESPEC at LINENO
%   (2)  DBSTOP in FILESPEC at LINENO@
%   (3)  DBSTOP in FILESPEC at LINENO@N
%   (4)  DBSTOP in FILESPEC at SUBFUN
%   (5)  DBSTOP in FILESPEC
%   (6)  DBSTOP in FILESPEC at LINENO if EXPRESSION
%   (7)  DBSTOP in FILESPEC at LINENO@ if EXPRESSION
%   (8)  DBSTOP in FILEPAEC at LINENO@N if EXPRESSION
%   (9)  DBSTOP in FILESPEC at SUBFUN if EXPRESSION
%   (10) DBSTOP in FILESPEC if EXPRESSION
%   (11) DBSTOP if error 
%   (12) DBSTOP if caught error
%   (13) DBSTOP if warning 
%   (14) DBSTOP if naninf  or  DBSTOP if infnan
%   (15) DBSTOP if error IDENTIFIER
%   (16) DBSTOP if caught error IDENTIFIER
%   (17) DBSTOP if warning IDENTIFIER
%
%   FILESPEC is a string specifying the MATLAB program file in which you
%   want the Debugger to stop. FILESPEC may include a full or partial path
%   to the file (see PARTIALPATH). You can specify a file that is not on 
%   the current path by using the keyword -completenames in the command,
%   and specifying FILESPEC as a fully qualified file name. (On Windows,
%   this is a file name that begins with \\ or with a drive letter followed
%   by a colon. On Unix, this is a file name that begins with / or ~.) You
%   can also include a filemarker in FILESPEC to specify the path to a
%   particular subfunction or to a nested function within the same file.
%
%   LINENO is a line number within the file specified by FILESPEC, N is an
%   integer specifying the Nth anonymous function on the line, and SUBFUN
%   is the name of a subfunction within the file. EXPRESSION is a string
%   containing an evaluatable conditional expression. IDENTIFIER is a
%   MATLAB Message Identifier (see help for ERROR for a description of
%   message identifiers). The AT and IN keywords are optional.
% 
%   The forms behave as follows:
%
%   (1)  Stops at line LINENO in the program file specified by FILESPEC.
%   (2)  Stops just after any call to the first anonymous function
%        in the specified line number.
%   (3)  As (2), but just after any call to the Nth anonymous function.
%   (4)  Stops at the specified subfunction in the file.
%   (5)  Stops at the first executable line in the file.
%   (6-10) As (1)-(5), except that execution stops only if EXPRESSION
%        evaluates to true. EXPRESSION is evaluated (as if by EVAL) in the
%        workspace of the program being debugged. Evaluation takes place
%        when MATLAB encounters the breakpoint. EXPRESSION must evaluate 
%        to a scalar logical value (true or false).
%   (11) Causes a stop in any function causing a run-time error that
%        would not be detected within a TRY...CATCH block.
%        You cannot resume execution after an uncaught run-time error.
%   (12) Causes a stop in any function, causing a run-time error that
%        would be detected within a TRY...CATCH block. You can resume 
%        execution after a caught run-time error.
%   (13) Causes a stop in any function causing a run-time warning. 
%   (14) Causes a stop in any function where an infinite value (Inf)
%        or Not-a-Number (NaN) is detected.
%   (15-17) As (11)-(13), except that MATLAB only stops on an error or
%        warning whose message identifier is IDENTIFIER. (If IDENTIFIER 
%        is the special string 'all', then these uses behave exactly like
%        (11)-(13).)
%
%   When MATLAB reaches a breakpoint, it enters debug mode. The prompt
%   changes to a K>> and, depending on the "Open Files when Debugging"
%   setting in the Debug menu, the debugger window may become active. 
%   Any MATLAB command is allowed at the prompt. To resume execution, 
%   use DBCONT or DBSTEP. To exit from the debugger, use DBQUIT.
%
%   See also DBCONT, DBSTEP, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN, DBSTATUS,
%            DBQUIT, ERROR, EVAL, LOGICAL, PARTIALPATH, TRY, WARNING.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.16 $  $Date: 2010/03/31 18:23:20 $
%   Built-in function.

