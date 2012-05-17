function [a2n1 b2n] = iqDemod(h, v)
%IQDEMOD Demodulate the received MSK signal using an IQ structure similar to an
%OQPSK signal with half sinusoidal pulse shaping.

% @modem/@mskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:02:46 $

[sigLen nChan] = size(v);  % number of symbols and number of channels
nSamps = h.SamplesPerSymbol;
IorQ = h.PrivIorQ;
signStateI = h.PrivSignStateI;
signStateQ = h.PrivSignStateQ;

% Filter the input signal
v2n1 = filter(h.PrivDecimFilterI, real(v));
v2n = -filter(h.PrivDecimFilterQ, imag(v));

% Chose the right sampling point and decimate
a2n1p = sign(v2n1(1+(1-IorQ)*nSamps:2*nSamps:end, :));
b2np = sign(v2n(1+IorQ*nSamps:2*nSamps:end, :));

% Alternate sign
a2n1 = a2n1p.*(-1).^repmat(((0:size(a2n1p,1)-1)+signStateI)', 1, nChan);
b2n = b2np.*(-1).^repmat(((0:size(b2np,1)-1)+signStateQ)', 1, nChan);

% Update state
h.PrivSignStateI = mod(size(a2n1p,1)+signStateI,2);
h.PrivSignStateQ = mod(size(b2np,1)+signStateQ,2);


%--------------------------------------------------------------------
% [EOF]