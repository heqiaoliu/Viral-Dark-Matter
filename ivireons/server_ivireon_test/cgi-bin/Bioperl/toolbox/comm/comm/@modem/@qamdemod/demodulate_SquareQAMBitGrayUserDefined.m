function y = demodulate_SquareQAMBitGrayUserDefined(h, x)
%DEMODULATE_SQUAREQAMBITGRAYUSERDEFINED Demodulate baseband input signal X using QAM  
% demodulator object H. Return demodulated binary signal/bits Y. Gray or 
% user-defined symbol mapping and Square QAM constellation are used.

% @modem/@qamdemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:46:50 $

% demodulate considering integer outputType
y = demodulate_SquareQAMIntGrayUserDefined(h, x);

% convert integers to bits
y = convertIntegers2Bits(h, y);

%-------------------------------------------------------------------------------
% [EOF]        