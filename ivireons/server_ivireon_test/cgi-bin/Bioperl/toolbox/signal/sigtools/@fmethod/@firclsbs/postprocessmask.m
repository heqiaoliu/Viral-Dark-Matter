function newA = postprocessmask(this, oldA, units)
%POSTPROCESSMASK

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:37 $

newA = oldA;
switch(units)
    case 'db'
        gain = this.PassbandOffset;
        newA(2) = oldA(2) + gain(1);        
        newA(4) = oldA(4) + gain(1);        
        newA(8) = oldA(8) + gain(2);        
        newA(10) = oldA(10) + gain(2);        
    case {'linear', 'zerophase'}
        gain = convertmagunits(this.PassbandOffset,'db','linear','amplitude');
        newA(2) = oldA(2) + gain(1) - 1;
        newA(4) = oldA(4) + gain(1) - 1;        
        newA(8) = oldA(8) + gain(2) - 1;
        newA(10) = oldA(10) + gain(2) - 1;
    case 'squared'                        
        gain = convertmagunits(this.PassbandOffset,'db','linear','amplitude');
        newA(2) = (oldA(2) + gain(1) - 1)^2;
        newA(4) = (oldA(4) + gain(1) - 1)^2;
        newA(8) = (oldA(8) + gain(2) - 1)^2;
        newA(10) = (oldA(10) + gain(2) - 1)^2;
end
newA(3) = newA(2);
newA(5) = newA(4);
newA(9) = newA(8);
newA(11) = newA(10);

% [EOF]

