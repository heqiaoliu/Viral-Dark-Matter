function dC = slackgrad(this,StopIfFeasible) 
% SLACKGRAD  Method to compute slack variable gradient for requirement
%
 
% Author(s): A. Stothert 11-Apr-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:01 $


Weight  = this.getData('Weight');
if StopIfFeasible
   %Slack variable weighted
   dC = -(1-Weight(1:this.ConstraintSize(1)));
else
   %Slack variable not weighted
   dC = -ones(this.ConstraintSize(1),1);
end

%Adjust for constraint size
if numel(this.ConstraintSize) > 1
   dC = repmat(dC,this.ConstraintSize(2),1);
end
