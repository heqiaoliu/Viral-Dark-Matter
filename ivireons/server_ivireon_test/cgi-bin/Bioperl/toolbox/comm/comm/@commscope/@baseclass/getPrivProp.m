function value = getPrivProp(this, prop)
%GETPRIVPROP Get private property PROP of object H.

%   @commscope/@baseclass

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:18:08 $

value = get(this, prop);

%-------------------------------------------------------------------------------
% [EOF]