function decisionType = setDecisionType(h, decisionType)
%SETDECISIONTYPE Set the decision type of object H.

% @modem/@genqamdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:37 $

% check for correct combination of OutputType & DecisionType  
if ismember(lower(decisionType), {'llr', 'approximate llr'}) && ...
        strcmpi(getPrivProp(h,'PrivOutputType'), 'integer')
    error([getErrorId(h) ':InvalidDecisionTypeAndOutputType'], ...
          ['''%s'' DecisionType is not allowed when OutputType is'... 
           ' ''Integer''.\nPlease set OutputType to ''Bit'' before changing '...
          'DecisionType.'], decisionType);
end

M= h.M;

% set PrivDecisionType prop - always do this first (after error checking)
setPrivProp(h, 'PrivDecisionType', decisionType);

% changing DecisionType affects ProcessFunction
setProcessFunction(h, M);

% changing DecisionType may require some initialization for LLR or Approximate
% LLR (Soft demodulation) computations.  Assumes binary mapping.
initSoftDemod(h, M, 0:M-1);

%-------------------------------------------------------------------------------
% [EOF]