function y = demodulate_ApproxLLR_Opt(h, x)
%DEMODULATE_APPROXLLR_OPT Demodulate baseband input signal X using QAM demodulator object H.  
% Return soft demodulated signal Y representing approximate LLR. It uses optimized algorithm
% for computing approximate LLR.

% @modem/@qamdemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:46:44 $

nbits = log2(h.M);
scaleFactor = 1.0; % For Comms toolbox, scaleFactor = 1 (2/minDist = 2/2)

% if input x is not complex, make it complex as the CPP-mex function
% (computeApproxLLR_Opt_QAM) assumes complex input
if isreal(x)
    x = complex(x, 0);
end

% Call CPP-mex function to compute Approximate LLR using optimized
% algorithm
% 'PrivMinIdx0' and 'PrivMinIdx1' are converted to int32 as the core CPP
% function uses them as int32_T.
y = computeApproxLLR_Opt_QAM(x, ...
                             numel(x), ...
                             h.NoiseVariance, ...
                             sqrt(h.M), ...
                             nbits, ...
                             scaleFactor, ...
                             cos(h.PhaseOffset), ...
                             sin(h.PhaseOffset), ...
                             h.Constellation, ...
                             int32(getPrivProp(h,'PrivMinIdx0')), ...
                             int32(getPrivProp(h,'PrivMinIdx1')));

%--------------------------------------------------------------------
% [EOF]
