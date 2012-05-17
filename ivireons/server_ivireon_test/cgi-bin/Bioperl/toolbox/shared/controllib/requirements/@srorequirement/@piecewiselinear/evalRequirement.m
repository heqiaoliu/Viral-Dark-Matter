function c = evalRequirement(this,EvalPoint,gamma,StopIfFeasible)
% Evaluates general 2D requirement. Note that these requirements are always
% constraints and may be vectors, e.g., piecewise constraints.
 
% Author(s): A. Stothert 25-Feb-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:48 $

c = this.eval(EvalPoint);   %call abstract method to evaluate requirement
%Protect against non-finite values
idxNF = ~isfinite(c);
if any(idxNF)
   c(idxNF) = sign(c(idxNF))/eps;
end

if ~isempty(c)
   %Adjust weight and normal value to account for any open ends
   Weight = this.getData('Weight');
   nVal   = this.getNormalizeValue;
   nC     = size(c,1);
   Weight = Weight(1:nC);
   nVal   = nVal(1:nC);
   c = c./(nVal*ones(1,size(c,2))) - StopIfFeasible*(1-Weight*ones(1,size(c,2)))*gamma - ...
      ~StopIfFeasible*gamma;
   %Store constraint size
   this.ConstraintSize = size(c);
else
   c = (1e4+1i)*ones(this.ConstraintSize);
end

% Safeguard against instability
idx = (c>10);
c(idx) = 10*(1+log(c(idx)/10));

%Flatten constraint values for use by optimizer
c = c(:);


