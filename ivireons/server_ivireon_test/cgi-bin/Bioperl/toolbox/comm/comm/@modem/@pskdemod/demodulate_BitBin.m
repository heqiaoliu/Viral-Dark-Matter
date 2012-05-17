function y = demodulate_BitBin(h, x)
%DEMODULATE_BITBIN Demodulate baseband input signal X using PSK demodulator object H.  
% Return demodulated binary signal Y. Binary symbol mapping is used.

% @modem/@pskdemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:46:00 $

% demodulate considering binary mapping and integer outputType
y = demodulate_IntBin(h, x);

% convert integers to bits
y = convertIntegers2Bits(h, y);

%--------------------------------------------------------------------
% [EOF]        