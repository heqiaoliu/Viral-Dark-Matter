function y = removeIQShift(h, x)
%REMOVEIQSHIFT Remove the I-Q time delay from the OQPSK signal

% @modem/@oqpskdemod

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 17:45:42 $

if mod(size(x,1),2)
    error([getErrorId(h) ':InvalidInputLength'], ...
        'Number of rows of input signal X must be even.');
end

Nsamp = 2;

% Get the number of channels
nChan = size(x, 2); 

% Get state variables
initI = h.PrivInitI;
initSamps = h.PrivInitSamps;
% If initI's length is not the same as the number of channels, reset
if (size(initI, 2) ~= nChan) || (size(initSamps, 2) ~= nChan)
    warning([getErrorId(h) ':NumChanReset'], ['The number of ' ...
        'channels has changed.  Resetting the demodulator.']);
    reset(h, nChan);
    initI = h.PrivInitI;
    initSamps = h.PrivInitSamps;
end

% Separate the signal into I and Q
xI = real(x);
xQ = imag(x);

% Store last xI
h.PrivInitI = xI(end,:);

% Remove offset 
xI = [initI; xI(1:end-1,:)];

% Create non-offset signal
x = [initSamps; xI + 1i*xQ];

% Integrate.
y = intdump(x(1:end-1, :), Nsamp);

% Store last xI
h.PrivInitSamps = x(end,:);

%--------------------------------------------------------------------
% [EOF]
