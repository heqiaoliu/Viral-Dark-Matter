function y = demodulate_BitGrayUserDefined(h, x)
%DEMODULATE_BITGRAYUSERDEFINED Demodulate signal X using OQPSK demodulator
% object H. Return demodulated binary signal Y. Gray or user-defined symbol
% mapping is used. 

% @modem/@oqpskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:16 $

% demodulate considering integer outputType
y = demodulate_IntGrayUserDefined(h, x);

% convert integers to bits
y = convertIntegers2Bits(h, y);

%--------------------------------------------------------------------
% [EOF] 