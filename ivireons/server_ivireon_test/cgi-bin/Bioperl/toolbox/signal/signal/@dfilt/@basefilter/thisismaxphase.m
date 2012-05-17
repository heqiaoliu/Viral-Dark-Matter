function f = thisismaxphase(Hd,tol)
%THISISMAXPHASE True if maximum phase.
%   THISISMAXPHASE(Hd) returns 1 if filter Hd is maximum phase, and 0 otherwise.
%
%   THISISMAXPHASE(Hd,TOL) uses tolerance TOL to determine when two numbers are
%   close enough to be considered equal.
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:18:00 $

% This should be private

if nargin<2, tol=[]; end;
[b,a] = tf(Hd);
f = signalpolyutils('ismaxphase',b,a,tol);