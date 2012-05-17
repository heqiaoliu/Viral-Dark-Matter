function setProcessFunction(h, M) %#ok
%SETPROCESSFUNCTION Set function for ProcessFunction property of MSK demodulator
% object H.

% @modem/@mskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:02:55 $

precoding = h.Precoding;
decisionType = h.DecisionType;

if strcmpi(decisionType, 'hard decision')

    if strcmpi(precoding, 'off')
        h.ProcessFunction = @demodulate_Conventional;
    else
        h.ProcessFunction = @demodulate_Precoded;
    end

elseif strcmpi(decisionType, 'llr')
    h.ProcessFunction = @demodulate_LLR;
else
    % decisionType = 'approximate llr'
    h.ProcessFunction = @demodulate_ApproxLLR;
end

%--------------------------------------------------------------------
% [EOF]