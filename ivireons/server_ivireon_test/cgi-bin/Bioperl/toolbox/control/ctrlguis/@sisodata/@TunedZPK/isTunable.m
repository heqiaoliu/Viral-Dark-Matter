function bool = isTunable(this)
% isTunable Determines if block is tunable based on constraints and sample
% time

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:39:41 $

if isequal(this.TSOrig, this.TS) || isempty(this.Constraints)
    bool = true;
else
    Constraints = this.Constraints;
    if isinf(Constraints.MaxZeros) && isinf(Constraints.MaxPoles) && ...
            (isempty(this.FixedDynamics) || isstatic(this.FixedDynamics)) || ...
             (Constraints.MaxZeros == 0) && (Constraints.MaxPoles == 0)
        bool = true;
    else
        bool = false;
    end
end