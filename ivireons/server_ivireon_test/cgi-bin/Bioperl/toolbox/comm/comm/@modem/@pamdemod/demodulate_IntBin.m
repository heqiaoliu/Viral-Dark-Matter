function y = demodulate_IntBin(h, x)
%DEMODULATE_BITBIN Demodulate baseband input signal X using PAM demodulator object H.  
% Return demodulated integer signal/symbols Y. Binary symbol mapping is used.

% @modem/@pamdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:59 $

% Initialize M-1
M1 = h.M - 1;

% Move the real part of input signal; scale appropriately and round the
% values to get ideal constellation points
y = round( ((real(x) + M1) ./ 2) );

% clip the values that are outside the valid range 
y(y < 0) = 0;
y(y > M1) = M1;

%--------------------------------------------------------------------
% [EOF]        