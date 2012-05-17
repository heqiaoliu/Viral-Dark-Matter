function z = sinint(x)
%SININT Sine integral function.
%  SININT(x) = int(sin(t)/t,t,0,x).
%
%  See also COSINT.

%   Copyright 1993-2002 The MathWorks, Inc. 
%  $Revision: 1.1.6.1 $  $Date: 2009/03/09 20:41:48 $

z = double(sinint(sym(x)));
