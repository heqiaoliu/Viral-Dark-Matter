function y = demodulate_SquareQAMIntBin(h, x)
%DEMODULATE_SQUAREQAMINTBIN Demodulate baseband input signal X using QAM
% demodulator object H. Return demodulated integer signal/symbols in Y.
% Binary symbol mapping and Square QAM constellation are used.

% @modem/@qamdemod

%   Copyright 2006 - 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/05/06 15:48:52 $

% De-rotate
x = x .* exp(-i*h.PhaseOffset);

% Precompute for later use
sqrtM = sqrt(h.M);

% Inphase/real rail
% Move the real part of input signal; scale appropriately and round the
% values to get index ideal constellation points
rIdx = round( ((real(x) + (sqrtM-1)) ./ 2) );
% clip values that are outside the valid range 
rIdx(rIdx <= -1) = 0;
rIdx(rIdx > (sqrtM-1)) = sqrtM-1;

% Quadrature/imaginary rail
% Move the imaginary part of input signal; scale appropriately and round 
% the values to get index of ideal constellation points
iIdx = round( ((imag(x) + (sqrtM-1)) ./ 2) );
% clip values that are outside the valid range 
iIdx(iIdx <= -1) = 0;
iIdx(iIdx > (sqrtM-1)) = sqrtM-1;

% compute output from indices of ideal constellation points 
y = sqrtM-iIdx-1 +  sqrtM*rIdx;

%-------------------------------------------------------------------------------
% [EOF]        