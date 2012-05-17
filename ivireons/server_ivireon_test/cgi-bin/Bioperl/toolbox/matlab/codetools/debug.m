%DEBUG List M-file debugging functions
%
%   dbstop     - Set breakpoint.
%   dbclear    - Remove breakpoint.
%   dbcont     - Resume execution.
%   dbdown     - Change local workspace context.
%   dbmex      - Enable MEX-file debugging.
%   dbstack    - List who called whom.
%   dbstatus   - List all breakpoints.
%   dbstep     - Execute one or more lines.
%   dbtype     - List M-file with line numbers.
%   dbup       - Change local workspace context.
%   dbquit     - Quit debug mode.
%
%   When a breakpoint is hit, MATLAB goes into debug mode, the debugger
%   window becomes active, and the prompt changes to a K>>.  Any MATLAB
%   command is allowed at the prompt.  
%
%   To resume M-file function execution, use DBCONT or DBSTEP.  
%   To exit from the debugger use DBQUIT.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/12/04 22:39:00 $
