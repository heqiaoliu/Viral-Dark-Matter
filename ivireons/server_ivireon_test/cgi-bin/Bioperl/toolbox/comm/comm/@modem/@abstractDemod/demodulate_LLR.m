function y = demodulate_LLR(h, x)
%DEMODULATE_LLR Demodulate signal X using demodulator object H. Return 
% soft demodulated signal Y representing LLR (log-likelihood ratio). 

% @modem/@abstractDemod

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:15:17 $

nbits = log2(h.M);

% if input x is not complex, make it complex as the CPP-mex function
% (computeLLR) assumes complex input
if isreal(x)
    x = complex(x, 0);
end

% Call CPP-mex function to compute LLR
% 'PrivS0' and 'PrivS1' are converted to int32 as the core CPP function uses
% them as int32_T. To convert them from ML indices to C/CPP indices, 1 is
% subtracted.
y = computeLLR(x, ...
               numel(x), ...
               h.NoiseVariance, ...
               h.M, ...
               nbits, ...
               h.Constellation, ...
               int32(getPrivProp(h,'PrivS0')-1), ...
               int32(getPrivProp(h,'PrivS1')-1));

%--------------------------------------------------------------------
% [EOF]        