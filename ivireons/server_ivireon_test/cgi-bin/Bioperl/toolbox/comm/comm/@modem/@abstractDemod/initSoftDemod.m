function initSoftDemod(h, M, symbolMapping)
%INITSOFTDEMOD Initialize/pre-compute properties required for soft
% demodulation (LLR or Approximate LLR) computation.

%   @modem/@abstractDemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:45:32 $

if ~strcmpi(h.DecisionType, 'hard decision')
    if strcmpi(h.DecisionType, 'llr')
        initLLR(h, symbolMapping);
    else
        % DecisionType = 'approximate LLR'
        initApproximateLLR(h, M, symbolMapping);
    end
end

%-------------------------------------------------------------------------------
% [EOF]