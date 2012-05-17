function setProcessFunction(h, M) %#ok
%SETPROCESSFUNCTION Set function for ProcessFunction property of PAM demodulator
% object H.

% @modem/@genqamdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:40 $

outputType = h.OutputType;
decisionType = h.DecisionType;

if strcmpi(decisionType, 'hard decision')

    if strcmpi(outputType, 'bit')
        h.ProcessFunction = @demodulate_BitBin;
    else
        % InputType = 'Integer'
        h.ProcessFunction = @demodulate_IntBin;
    end

elseif strcmpi(decisionType, 'llr')
    h.ProcessFunction = @demodulate_LLR;
else
    % decisionType = 'approximate llr'
    h.ProcessFunction = @demodulate_ApproxLLR;

end

%--------------------------------------------------------------------
% [EOF]