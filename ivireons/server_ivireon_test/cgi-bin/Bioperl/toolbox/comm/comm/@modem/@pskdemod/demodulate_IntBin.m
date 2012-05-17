function y = demodulate_IntBin(h, x)
%DEMODULATE_BITBIN Demodulate baseband input signal X using PSK demodulator object H.  
% Return demodulated integer signal/symbols Y. Binary symbol mapping is used.

% @modem/@pskdemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/05/06 15:48:25 $

% De-rotate
x = x .* exp(-i*h.PhaseOffset);

% normalization factor to convert from PI-domain to linear domain
normFactor = h.M/(2*pi); 

% convert input signal angle to linear domain; round the value to get ideal
% constellation points 
y = round((angle(x) .* normFactor));

% move all the negative integers by M
y(y < 0) = h.M + y(y < 0);

%--------------------------------------------------------------------
% [EOF]        