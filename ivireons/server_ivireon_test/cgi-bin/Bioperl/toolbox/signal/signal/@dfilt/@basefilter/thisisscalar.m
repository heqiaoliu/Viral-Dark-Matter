function f = thisisscalar(Hd)
%THISISSCALAR  True if scalar filter.
%   THISISSCALAR(Hd) returns 1 if Hd is a scalar filter, and 0 otherwise.
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:18:02 $

% This should be private

f = order(Hd)==0;