function setProcessFunction(h, M) %#ok
%SETPROCESSFUNCTION Set function for ProcessFunction property of OQPSK demodulator 
% object H.

% @modem/@oqpskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:31 $

symbolOrder = h.SymbolOrder;
outputType = h.OutputType;
decisionType = h.DecisionType;

if strcmpi(decisionType, 'hard decision')

    if strcmpi(outputType, 'bit')
        if strcmpi(symbolOrder, 'binary')
            h.ProcessFunction = @demodulate_BitBin;
        else 
            % SymbolOrder = 'gray' or 'user-defined'
            h.ProcessFunction = @demodulate_BitGrayUserDefined;
        end
    else 
        % InputType = 'Integer'
        if strcmpi(symbolOrder, 'binary')
            h.ProcessFunction = @demodulate_IntBin;
        else 
            % SymbolOrder = 'gray' or 'user-defined'
            h.ProcessFunction = @demodulate_IntGrayUserDefined;
        end
    end

elseif strcmpi(decisionType, 'llr')
    h.ProcessFunction = @demodulate_LLR;
else
    % decisionType = 'approximate llr'
    h.ProcessFunction = @demodulate_ApproxLLR_Opt;

end

%--------------------------------------------------------------------
% [EOF] 