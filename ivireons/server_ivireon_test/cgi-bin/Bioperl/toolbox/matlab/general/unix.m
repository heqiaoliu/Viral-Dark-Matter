%UNIX   Execute UNIX command and return result.
%   [status,result] = UNIX('command'), for UNIX systems, calls upon the
%   operating system to execute the given command.  The resulting status
%   and standard output are returned.
%
%   This function is interchangeable with the DOS and SYSTEM functions.
%   They all have the same effect.
%
%   Examples:
%
%       [s,w] = unix('who')
%
%   returns s = 0 and, in w, a MATLAB string containing a list of the users
%   currently logged in.
%
%       [s,w] = unix('why')
%
%   returns a nonzero value in s to indicate failure and sets w to the null
%   matrix because "why" is not a UNIX command.
%
%       [s,m] = unix('matlab')
%
%   never returns because running the second copy of MATLAB requires
%   interactive user input which cannot be provided.
%
%   See also COMPUTER, DOS, PERL, SYSTEM, and ! (exclamation point) under PUNCT.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 5.10.4.4 $  $Date: 2010/03/08 21:41:05 $
%   Built-in function.
