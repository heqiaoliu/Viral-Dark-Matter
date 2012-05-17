function out = getavaildes(h,out)
%GETAVAILDES GetFunction for AvailableDestinations property.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:44:42 $

out = get(h,'privAvailableDestinations');

% [EOF]