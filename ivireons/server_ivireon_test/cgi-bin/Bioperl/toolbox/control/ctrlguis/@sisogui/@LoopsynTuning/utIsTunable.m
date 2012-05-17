function b = utIsTunable(this)
%utIsTunable Determines if compensator is tunable using loopsyn

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/11/17 13:25:25 $

C = this.TunedCompList(this.IdxC);

if C.isTunable && (isempty(C.FixedDynamics) || isstatic(C.FixedDynamics))
    Constraints = C.Constraints;
    if isempty(Constraints) || (isinf(Constraints.MaxZeros) && isinf(Constraints.MaxPoles))
        b = true;
    else
        b = false;
    end
else
    b = false;
end
    
 