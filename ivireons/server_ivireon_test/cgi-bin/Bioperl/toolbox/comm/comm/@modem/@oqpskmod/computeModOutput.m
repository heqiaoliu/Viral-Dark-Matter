function y = computeModOutput(h, x)
%COMPUTEMODOUTPUT Compute modulator output for MODEM.OQPSKMOD modulator
%   object. This function implicitly upsamples by a factor of 2, because an 
%   odd number of samples per symbol is not allowed for OQPSK.

% @modem/@oqpskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/07 18:20:08 $

% Get the number of symbols and the number of channels
[nSym nChan] = size(x); 

% Get the initial value of the Q
initQ = h.PrivInitQ;

% If initQ's length is not the same as the number of channels, reset
if ( size(initQ, 2) ~= nChan )
    warning([getErrorId(h) ':NumChanReset'], ['The number of ' ...
        'channels has changed.  Resetting the modulator.']);
    reset(h, nChan);
    initQ = h.PrivInitQ;
end

% upsample
Nsamp = 2;
[wid, len] = size(x);
x = reshape(ones(Nsamp,1)*reshape(x, 1, wid*len),wid*Nsamp, len);

% Get constellation
constellation = h.Constellation(:);

% Get transformed mapping
mapping = h.TransSymMapping;

% compute symbols
y = constellation(mapping(x+1));

% separate the signal into I and Q
yI = real(y);
yQ = imag(y);

% Store last Q value
h.PrivInitQ = yQ(end,:);

% introduce the timing offset in the quadrature channel.  Use PrivInitQ as the
% initial value for the Q
yQ = [initQ; yQ(1:end-1,:)];
y = yI + j*yQ;

%--------------------------------------------------------------------
% [EOF]
