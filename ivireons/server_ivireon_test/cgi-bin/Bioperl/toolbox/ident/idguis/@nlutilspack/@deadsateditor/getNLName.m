function nlstr = getNLName(this)
%return name of the nonlinearity

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:54:51 $

if this.isSat
    nlstr =  'saturation';
else
    nlstr = 'dead zone';
end
    