function y = demodulate_ApproxLLR(h, x)
%DEMODULATE_APPROXLLR Demodulate baseband input signal X using QAM demodulator 
% object H. Return soft demodulated signal Y representing approximate LLR.
% It uses general (non-optimized) algorithm for computing approximate LLR.
 
% @modem/@qamdemod

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:15:23 $

nbits = log2(h.M);

% if input x is not complex, make it complex as the CPP-mex function
% (computeApproxLLR_QAM) assumes complex input
if isreal(x)
    x = complex(x, 0);
end

% Call CPP-mex function to compute approximate LLR using general
% (non-optimized) algorithm
% 'PrivS0' and 'PrivS1' are converted to int32 as the core CPP function uses
% them as int32_T. To convert them from ML indices to C/CPP indices, 1 is
% subtracted.
y = computeApproxLLR_QAM(x, ...
                         numel(x), ...
                         h.NoiseVariance, ...
                         h.M, ...
                         nbits, ...
                         h.Constellation, ...
                         int32(getPrivProp(h,'PrivS0')-1), ...
                         int32(getPrivProp(h,'PrivS1')-1));

%--------------------------------------------------------------------
% [EOF]




    
        
        
        
        
        

        