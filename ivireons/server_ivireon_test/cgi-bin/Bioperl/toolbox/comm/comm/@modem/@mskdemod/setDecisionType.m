function decisionType = setDecisionType(h, decisionType)
%SETDECISIONTYPE Validate and set DecisionType for object H.

%   @modem/@mskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:02:52 $

% Force to HardDecision
if ismember(lower(decisionType), {'llr', 'approximate llr'})
    error([getErrorId(h) ':InvalidDecisionType'], ...
          '''%s'' DecisionType is not allowed with MSKDEMOD.',  ...
          decisionType);
end

% set PrivDecisionType prop - always do this first (after error checking)
setPrivProp(h, 'PrivDecisionType', decisionType);
% changing DecisionType affects ProcessFunction
setProcessFunction(h, h.M);
