function [result,status] = mupadmex(varargin) %#ok
%This undocumented function may be removed in a future release.

%   MUPADMEX(STMT) executes STMT in MuPAD. STMT must be a string or cell
%   array of strings. A cell array is converted into a MuPAD matrix or array.
%   Y = MUPADMEX(STMT) executes STMT in MuPAD and returns the result as
%   sym object Y. STMT must be a string or cell array of strings. If STMT
%   is a cell Y is a string reference instead of a sym.
%   Y = MUPADMEX(FCN,ARG1,ARG2, ...) evaluates FCN(ARG1,ARG2,...). The inputs
%   must be strings.
%   Y = MUPADMEX(... ,0) returns Y as a string instead of a sym.
%   Y = MUPADMEX(REF ,1) adds REF to the garbage list.
%   Y = MUPADMEX(STMT,2) frees any garbage.
%   Y = MUPADMEX(VAL ,3) formats VAL as 'symr'.
%   Y = MUPADMEX(VAL ,4) formats VAL as 'symfl'.
%   Y = MUPADMEX(VAL ,5) toggles the trace feature. VAL must be 'on' or 'off'.
%   Y = MUPADMEX(STMT,6) resets MuPAD.
%   Y = MUPADMEX(VAL ,7) toggles the pretty-print feature.
%   Y = MUPADMEX(VAL ,8) sets the complex unit. VAL is 'I' or 'sqrtmone'.
%   Y = MUPADMEX(... ,9) returns Y as a logical instead of a sym.
%   Y = MUPADMEX(VAL ,10) toggles the synchronous evaluation mode (out-of-process kernel only).
%   Y = MUPADMEX(... ,11) returns Y as a string reference.
%   Y = MUPADMEX(VAL ,12) print out memory usage
%   Y = MUPADMEX(VAL ,13) toggles lazy evaluation mode
%   Y = MUPADMEX(VAL ,14) evaluates all the lazy statements
%   Y = MUPADMEX(VAL ,15) sets DIGITS
%   [Y,STATUS] = ... sets STATUS to 0 if the command completes without error
%   and otherwise sets STATUS to 1 and Y to the error string.

%   Copyright 2008-2010 The MathWorks, Inc.

error('symbolic:mupadmex:notAvailable','The Symbolic Math Toolbox is not yet available for this architecture.')
