function y = demodulate_BitGrayUserDefined(h, x)
%DEMODULATE_BITGRAYUSERDEFINED Demodulate signal X using PAM demodulator object H. Return 
% demodulated binary signal Y. Gray or user-defined symbol mapping is used.

% @modem/@pamdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:58 $

% demodulate considering integer outputType
y = demodulate_IntGrayUserDefined(h, x);

% convert integers to bits
y = convertIntegers2Bits(h, y);

%--------------------------------------------------------------------
% [EOF] 