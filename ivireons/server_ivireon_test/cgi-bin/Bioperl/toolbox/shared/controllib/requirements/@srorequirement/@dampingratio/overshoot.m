function pOver = overshoot(this)
% OVERSHOOT  return the percentage overshoot limit defined by this
% constraint
%
% RE: based on second-order behavior
 
% Author(s): A. Stothert 06-Jan-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:41 $

%Retrieve damping ratio
z = this.getData('xData');
%Convert damping ratio into percentage overshoot
if z==1
    pOver = 0;
else
    % PO = 100 * exp(-pi*z/sqrt(1-z^2))
    pOver = 100*exp(-pi*z/sqrt(1-z)/sqrt(1+z));
end
