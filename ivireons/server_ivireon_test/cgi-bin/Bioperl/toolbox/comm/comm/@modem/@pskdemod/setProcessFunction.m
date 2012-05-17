function setProcessFunction(h, M) %#ok
%SETPROCESSFUNCTION Set function for ProcessFunction property of PSK demodulator 
% object H.

% @modem/@pskdemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:46:09 $

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