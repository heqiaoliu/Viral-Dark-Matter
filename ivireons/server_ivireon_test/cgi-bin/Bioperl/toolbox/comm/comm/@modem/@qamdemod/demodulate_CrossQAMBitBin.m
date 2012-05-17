function y = demodulate_CrossQAMBitBin(h, x)
%DEMODULATE_CROSSQAMBITBIN Demodulate baseband input signal X using QAM demodulator object
% H. Return demodulated binary signal/bits in Y. Binary symbol mapping and Cross QAM
% constellation is used.

% @modem/@qamdemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:46:45 $

% demodulate considering binary mapping and integer outputType
y = demodulate_CrossQAMIntBin(h, x);

% convert integers to bits
y = convertIntegers2Bits(h, y);

%-------------------------------------------------------------------------------
% [EOF]        