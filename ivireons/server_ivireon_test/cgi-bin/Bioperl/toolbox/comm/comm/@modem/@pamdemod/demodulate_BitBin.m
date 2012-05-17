function y = demodulate_BitBin(h, x)
%DEMODULATE_BITBIN Demodulate baseband input signal X using PAM demodulator object H.  
% Return demodulated binary signal Y. Binary symbol mapping is used.

% @modem/@pamdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:57 $

% demodulate considering binary mapping and integer outputType
y = demodulate_IntBin(h, x);

% convert integers to bits
y = convertIntegers2Bits(h, y);

%--------------------------------------------------------------------
% [EOF]        