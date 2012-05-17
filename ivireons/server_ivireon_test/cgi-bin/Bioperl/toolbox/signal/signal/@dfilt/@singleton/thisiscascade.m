function f = thisiscascade(Hd)
%ISCASCADE  True for cascaded filter.
%   ISCASCADE(Hd) returns 1 if filter Hd is cascade of filters, and 0 otherwise.
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:59:51 $

% This should be private

% The overloaded @cascade/iscascade will be called if Hd is cascaded.
f = false;

