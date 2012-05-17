function f = thisisminphase(Hd,tol)
%THISISMINPHASE True if minimum phase.
%   THISISMINPHASE(Hd) returns 1 if filter Hd is minimum phase, and 0 otherwise.
%
%   THISISMINPHASE(Hd,TOL) uses tolerance TOL to determine when two numbers are
%   close enough to be considered equal.
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/06/16 08:19:21 $

% This should be private

if nargin<2, tol=[]; end;
f = true;
for i = 1:nstages(Hd),
    f = f && thisisminphase(Hd.Stage(i),tol);
end

% [EOF]
