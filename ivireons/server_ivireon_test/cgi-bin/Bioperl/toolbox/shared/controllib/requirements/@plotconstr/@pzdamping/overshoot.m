function PO = overshoot(Constr)
%OVERSHOOT  Computes overshoot level for given damping

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:08 $

% RE: based on second-order behavior
z = Constr.Damping;
if z==1
    PO = 0;
else
    % PO = 100 * exp(-pi*z/sqrt(1-z^2))
    PO = 100*exp(-pi*z/sqrt(1-z)/sqrt(1+z));
end
