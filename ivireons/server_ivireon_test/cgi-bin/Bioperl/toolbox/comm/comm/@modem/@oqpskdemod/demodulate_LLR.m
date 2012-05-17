function y = demodulate_LLR(h, x)
%DEMODULATE_LLR Demodulate signal X using demodulator object H. Return 
% soft demodulated signal Y representing LLR (log-likelihood ratio). 

% @modem/@oqpskemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:19 $

% Remove the I-Q delay.  Now the signal looks like QPSK.
x = removeIQShift(h, x);

nbits = log2(h.M);

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