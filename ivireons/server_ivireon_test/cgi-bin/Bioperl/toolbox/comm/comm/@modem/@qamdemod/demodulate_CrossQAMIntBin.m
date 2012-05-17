function y = demodulate_CrossQAMIntBin(h, x)
%DEMODULATE_CROSSQAMINTBIN Demodulate baseband input signal X using QAM demodulator  
% object H. Return demodulated integer signal/symbols in Y. Binary symbol
% mapping and Cross QAM constellation are used.

% @modem/@qamdemod

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/05/31 23:15:24 $

constellation = h.Constellation;

y = zeros(size(x));
for i = 1:size(x,1)
    for j = 1:size(x,2)
        %compute the minimum distance for each symbol
        [varNotUsed, idx] = min(abs(x(i,j) - constellation));
        y(i,j) = idx-1;
    end
end

%-------------------------------------------------------------------------------
% [EOF]
