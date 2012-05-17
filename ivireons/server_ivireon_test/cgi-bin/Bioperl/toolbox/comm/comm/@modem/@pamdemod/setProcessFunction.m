function setProcessFunction(h, M) %#ok
%SETPROCESSFUNCTION Set function for ProcessFunction property of PAM demodulator 
% object H.

% @modem/@pamdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:48:10 $

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
    h.ProcessFunction = @demodulate_ApproxLLR;

end

%--------------------------------------------------------------------
% [EOF] 