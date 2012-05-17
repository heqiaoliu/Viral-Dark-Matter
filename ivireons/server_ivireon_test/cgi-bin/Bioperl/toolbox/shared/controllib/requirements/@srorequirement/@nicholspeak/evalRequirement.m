function c = evalRequirement(this,EvalPoint,gamma,StopIfFeasible)
% Evaluates general scalar requirement. Note that this may be an
% objective or a constraint. Constraints may be vectorized, e.g., 
% pole real value. 

% Author(s): A. Stothert 09-Jan-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:27 $

c = this.eval(EvalPoint);   %call abstract method to evaluate requirement
%Protect against non-finite values
idxNF = ~isfinite(c);
if any(idxNF)
   c(idxNF) = sign(c(idxNF))/eps;
end

%Retrieve requirement value
X = this.Data.getData('yData'); %Gain bound stored in y data as on nichols plot

%Make sure we have a good value for normalization
nVal = this.NormalizeValue;
if ~isfinite(nVal) || (nVal == 0)
   nVal = max([abs(X(:));eps]);
end

%Compute requirement
if ~isempty(c)
   %Computed valid requirement value
   if ~this.isConstraint
      if this.isMinimized
         c = max(c(:));   %Could be multi constraint
         %Scalar objective, normalize and weight.
         c =c/nVal*this.RequirementWeight;
      else
         c = min(c(:));  %Could be multi constriant
         %Scalar objective, normalize and weight.
         c = -1*c/nVal*this.RequirementWeight;
      end
   else
      if this.isLowerBound
         %Lower bound
         %Scalar constraint, normalize using bound value
         c = (X-c)/nVal - ...
            StopIfFeasible*(1-this.RequirementWeight)*gamma - ...
            ~StopIfFeasible*gamma;
      else
         %Upper bound
         %Scalar constraint, normalize using bound value
         c = (c - X)/nVal - ...
            StopIfFeasible*(1-this.RequirementWeight)*gamma - ...
            ~StopIfFeasible*gamma;
      end
   end
   %Store constraint size
   this.ConstraintSize = size(c);
else
   %Empty eval, output consistent constraint size
   c = (1e4+1i)*ones(this.ConstraintSize);
end


