function newval = tolinear(h,val,passOrStop)
%TOLINEAR Convert dB value to linear.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:28:37 $

switch passOrStop,
    
case 'pass',
    newval = (10^(val/20) - 1)/(10^(val/20) + 1);
    
case 'stop',
    newval = 10^(-val/20);
end
