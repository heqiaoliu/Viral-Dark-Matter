function f = thisisparallel(Hd)
%THISISPARALLEL  True for filter with parallel stages.
%   THISISPARALLEL(Hd) returns 1 if filter Hd is composed of parallel stages,
%   and 0 otherwise. 
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/12 23:59:06 $

% This should be private

f = true;

