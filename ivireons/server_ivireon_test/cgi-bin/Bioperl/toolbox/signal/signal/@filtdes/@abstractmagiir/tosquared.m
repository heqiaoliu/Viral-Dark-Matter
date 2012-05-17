function newval = tolinear(h,val,notused)
%TOLINEAR Convert dB value to linear.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:28:49 $


newval = 1/(10^(val/10));
