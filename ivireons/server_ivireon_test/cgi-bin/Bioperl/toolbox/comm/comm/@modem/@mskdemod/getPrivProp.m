function value = getPrivProp(h, prop)
%GETPRIVPROP Get private property PROP of object H and return its value in VALUE.

%   @modem/@mskdemod
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:02:43 $

value = get(h, prop);

%-------------------------------------------------------------------------------
% [EOF]