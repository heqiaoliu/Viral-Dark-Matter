function y = demodulate_BitGrayUserDefined(h, x)
%DEMODULATE_BITGRAYUSERDEFINED Demodulate signal X using PSK demodulator object H. Return 
% demodulated binary signal Y. Gray or user-defined symbol mapping is used.

% @modem/@pskdemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:46:01 $

% demodulate considering integer outputType
y = demodulate_IntGrayUserDefined(h, x);

% convert integers to bits
y = convertIntegers2Bits(h, y);

%--------------------------------------------------------------------
% [EOF] 