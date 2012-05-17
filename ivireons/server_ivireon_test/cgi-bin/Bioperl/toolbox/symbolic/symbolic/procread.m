function s = procread(filename)
%PROCREAD Install a Maple procedure
%   The PROCREAD function is not supported and will be removed in a future release.

%   PROCREAD(FILENAME) reads the specified file, which contains 
%   the source text for a Maple procedure. PROCREAD deletes any
%   comments and newline characters, and then sends the resulting 
%   string to Maple.
%
%   Example:
%      Suppose the file "check.src" contains the following
%      source text for a Maple procedure.
%
%         check := proc(A)
%            #   check(A) computes A*inverse(A)
%            local X;
%            X := inverse(A):
%            evalm(A &* X);
%         end;
%
%      Then the statement
%
%         procread('check.src')
%
%      installs the procedure.  It can be accessed with 
%
%         maple('check',magic(3))
%
%      or
%
%         maple('check',vpa(magic(3)))
%
%   See also MAPLE.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/11/05 18:21:17 $

eng = symengine;
if strcmp(eng.kind,'maple')
    s = mapleengine('procread',filename);
else
    error('symbolic:procread:NotInstalled','The PROCREAD function is not available.');
end
