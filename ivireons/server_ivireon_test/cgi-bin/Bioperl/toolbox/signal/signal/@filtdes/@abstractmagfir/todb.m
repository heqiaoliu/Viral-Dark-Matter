function newval = todb(h,val,passOrStop)
%TODB Convert linear value to dB.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:28:28 $

switch passOrStop,
    
case 'pass',
    newval = 20*log10((1+val)/(1-val));
    
case 'stop',
    newval = -20*log10(val);
end
