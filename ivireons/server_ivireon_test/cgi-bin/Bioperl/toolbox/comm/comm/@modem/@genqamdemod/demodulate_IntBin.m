function y = demodulate_IntBin(h, x)
%DEMODULATE_BITBIN Demodulate baseband input signal X using General QAM
%   demodulator object H. Return demodulated integer signal/symbols Y. Binary
%   symbol mapping is used.

% @modem/@genqamdemod

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:15:19 $

const = h.Constellation;

y = zeros(size(x));
for p = 1:size(x,1)
    for q = 1:size(x,2)
    %compute the minimum distance for each symbol
        [tmp, idx] = min(abs(x(p,q) - const));
        y(p,q) = idx-1;
    end
end

%--------------------------------------------------------------------
% [EOF]        