function y = demodulate_SquareQAMBitBin(h, x)
%DEMODULATE_SQUAREQAMBITBIN Demodulate baseband input signal X using QAM
% demodulator object H. Return demodulated integer signal/symbols in Y.
% Binary symbol mapping is used. 

% @modem/@qamdemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:46:49 $

% demodulate considering binary mapping and integer outputType
y = demodulate_SquareQAMIntBin(h, x);

% convert integers to bits
y = convertIntegers2Bits(h, y);

%-------------------------------------------------------------------------------
% [EOF]        