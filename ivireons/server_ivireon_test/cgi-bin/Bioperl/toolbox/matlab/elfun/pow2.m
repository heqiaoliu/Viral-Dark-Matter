%POW2   Base 2 power and scale floating point number.
%   X = POW2(Y) for each element of Y is 2 raised to the power Y.
%
%   X = POW2(F,E) for each element of the real array F and a integer
%   array E computes X = F .* (2 .^ E).  The result is computed
%   quickly by simply adding E to the floating point exponent of F.
%   This corresponds to the ANSI C function ldexp() and the IEEE
%   floating point standard function scalbn().
%
%   See also LOG2, REALMAX, REALMIN.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.9.4.4 $  $Date: 2005/05/31 16:30:52 $
%   Built-in function.

