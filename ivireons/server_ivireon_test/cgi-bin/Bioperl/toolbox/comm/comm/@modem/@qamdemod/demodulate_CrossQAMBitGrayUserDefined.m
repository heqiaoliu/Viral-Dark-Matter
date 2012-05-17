function y = demodulate_CrossQAMBitGrayUserDefined(h, x)
%DEMODULATE_CROSSQAMBITGRAYUSERDEFINED Demodulate baseband input signal X using QAM  
% demodulator object H. Return demodulated binary signal/bits in Y. Gray or 
% user-defined symbol mapping and Cross QAM constellation are used.

% @modem/@qamdemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:46:46 $

% demodulate considering integer outputType
y = demodulate_CrossQAMIntGrayUserDefined(h, x);

% convert integers to bits
y = convertIntegers2Bits(h, y);

%-------------------------------------------------------------------------------
% [EOF]        