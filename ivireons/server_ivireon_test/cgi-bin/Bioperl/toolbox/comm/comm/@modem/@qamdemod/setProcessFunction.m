function setProcessFunction(h, M)
%SETPROCESSFUNCTION Set function for ProcessFunction property of QAM demodulator 
% object H.

% @modem/@qamdemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:46:59 $

outputType = h.OutputType;
symbolOrder = h.SymbolOrder;
decisionType = h.DecisionType;
nbits = log2(M);

if strcmpi(decisionType, 'hard decision')

    if (mod(nbits,2) == 0)
        % Square QAM
        if strcmpi(outputType, 'bit')
            if strcmpi(symbolOrder, 'binary')
                h.ProcessFunction = @demodulate_SquareQAMBitBin;
            else 
                % SymbolOrder = 'gray' or 'user-defined'
                h.ProcessFunction = @demodulate_SquareQAMBitGrayUserDefined;
            end
        else 
            % OutputType = 'Integer'
            if strcmpi(symbolOrder, 'binary')
                h.ProcessFunction = @demodulate_SquareQAMIntBin;
            else 
                % SymbolOrder = 'gray' or 'user-defined'
                h.ProcessFunction = @demodulate_SquareQAMIntGrayUserDefined;
            end
        end
    else 
        % Cross QAM
        if strcmpi(outputType, 'bit')
            if strcmpi(symbolOrder, 'binary')
                h.ProcessFunction = @demodulate_CrossQAMBitBin;
            else 
                % SymbolOrder = 'gray' or 'user-defined'
                h.ProcessFunction = @demodulate_CrossQAMBitGrayUserDefined;
            end
        else 
            % OutputType = 'Integer'
            if strcmpi(symbolOrder, 'binary')
                h.ProcessFunction = @demodulate_CrossQAMIntBin;
            else 
                % SymbolOrder = 'gray' or 'user-defined'
                h.ProcessFunction = @demodulate_CrossQAMIntGrayUserDefined;
            end
        end
    end

elseif strcmpi(decisionType, 'llr')
    h.ProcessFunction = @demodulate_LLR;
else
    % decisionType = 'approximate llr'
    if (mod(nbits,2) == 0) && ~strcmpi(h.SymbolOrder, 'user-defined')
        % Square QAM & Binary/Gray mapping - use optimized algorithm
        h.ProcessFunction = @demodulate_ApproxLLR_Opt;
    else
        % Cross QAM or (Square QAM & User-defined mapping) - use
        % non-optimized algorithm
        h.ProcessFunction = @demodulate_ApproxLLR;
    end

end

%--------------------------------------------------------------------
% [EOF] 