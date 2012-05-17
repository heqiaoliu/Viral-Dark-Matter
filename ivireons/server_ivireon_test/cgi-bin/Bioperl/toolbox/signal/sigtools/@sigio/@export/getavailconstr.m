function out = getavailconstr(h,out)
%GETAVAILCONSTR GetFunction for AvailableConstructors property.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:44:41 $

out = get(h,'privAvailableConstructors');

% [EOF]