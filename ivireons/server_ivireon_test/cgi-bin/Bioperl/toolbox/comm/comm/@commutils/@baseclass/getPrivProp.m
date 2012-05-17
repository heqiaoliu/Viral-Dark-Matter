function value = getPrivProp(this, prop)
%GETPRIVPROP Get private property PROP of object H.

%   @commsutils/@baseclass
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:20:03 $

value = get(this, prop);

%-------------------------------------------------------------------------------
% [EOF]