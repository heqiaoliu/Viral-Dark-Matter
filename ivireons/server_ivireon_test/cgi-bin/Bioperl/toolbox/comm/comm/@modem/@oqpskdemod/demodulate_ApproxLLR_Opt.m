function y = demodulate_ApproxLLR_Opt(h, x)
%DEMODULATE_APPROXLLR Demodulate baseband input signal X using OQPSK
% demodulator object H. Return soft demodulated signal Y representing
% approximate LLR. It uses general (non-optimized) algorithm for computing
% approximate LLR. Since QPSK is a special case of PSK, this function uses
% PSK demodulation tools.
 
% @modem/@oqpskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:14 $

% Remove the I-Q delay.  Now the signal looks like QPSK.
x = removeIQShift(h, x);

nbits = log2(h.M);

% Call CPP-mex function to compute Approximate LLR using optimized algorithm
% 'PrivMinIdx0' and 'PrivMinIdx1' are converted to int32 as the core CPP
% function uses them as int32_T. 
y = computeApproxLLR_Opt_PSK(x, ...
                             numel(x), ...
                             h.NoiseVariance, ...
                             h.M, ...
                             nbits, ...
                             h.M/pi, ...
                             cos(h.PhaseOffset+pi/4), ...
                             sin(h.PhaseOffset+pi/4), ...
                             h.Constellation, ...
                             int32(getPrivProp(h,'PrivMinIdx0')), ...
                             int32(getPrivProp(h,'PrivMinIdx1')));

%--------------------------------------------------------------------
% [EOF]
