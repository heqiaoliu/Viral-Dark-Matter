function y = demodulate_ApproxLLR_Opt(h, x)
%DEMODULATE_APPROXLLR_OPT Demodulate signal X using PSK demodulator object H. Return 
% soft demodulated signal Y representing approximate LLR. It uses optimized algorithm
% to compute approximate LLR.

% @modem/@pskdemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:45:59 $

nbits = log2(h.M);

% if input x is not complex, make it complex as the CPP-mex function
% (computeApproxLLR_Opt_PSK) assumes complex input
if isreal(x)
    x = complex(x, 0);
end

% Call CPP-mex function to compute Approximate LLR using optimized
% algorithm
% 'PrivMinIdx0' and 'PrivMinIdx1' are converted to int32 as the core CPP
% function uses them as int32_T.
y = computeApproxLLR_Opt_PSK(x, ...
                             numel(x), ...
                             h.NoiseVariance, ...
                             h.M, ...
                             nbits, ...
                             h.M/pi, ...
                             cos(h.PhaseOffset), ...
                             sin(h.PhaseOffset), ...
                             h.Constellation, ...
                             int32(getPrivProp(h,'PrivMinIdx0')), ...
                             int32(getPrivProp(h,'PrivMinIdx1')));

%--------------------------------------------------------------------
% [EOF]