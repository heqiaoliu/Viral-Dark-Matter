function y = demodulate_IntBin(h, x)
%DEMODULATE_BITBIN Demodulate baseband input signal X using PAM demodulator object H.  
% Return demodulated integer signal/symbols Y. Binary symbol mapping is used.

% @modem/@oqpskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:17 $

% OQPSK M is always 4
M = 4;

% Remove the I-Q delay.  Now the signal looks like QPSK.
x = removeIQShift(h, x);

% De-rotate
x = x .* exp(-i*h.PhaseOffset);

% normalization factor to convert from PI-domain to linear domain
normFactor = M/(2*pi); 

% convert input signal angle to linear domain; round the value to get ideal
% constellation points 
y = round(((angle(x) - pi/4) .* normFactor));
% move all the negative integers by M
y(y < 0) = M + y(y < 0);

%--------------------------------------------------------------------
% [EOF]        