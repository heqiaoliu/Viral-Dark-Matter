function y = modulate_Precoded(h, x)
%MODULATE_PRECODED 	Precoded MSK modulation
%   MODEM.MSKMOD modulator object.

%   Reference: M.K. Simon, S.M. Hinedi, and H.C. Lindsey, Digital Communication
%   Techniques - Signal Design and Detection, New Jersey: Prentice Hall, 1995

%   @modem/@mskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:04 $

[nSym nChan] = size(x);  % number of symbols and number of channels
initY = h.PrivInitY;

% Reset the demodulator if number of input channels (nChan) and number of
% initial state channels (size(initY,2)) are different
if ( nChan ~= size(initY, 2) )
    warning([getErrorId(h) ':InitYReset'], ['The number of ' ...
        'channels has changed.  Resetting the modulator.']);
    reset(h, nChan);
end;

% Convert to bipolar
v = 2*x-1;

% OQPSK modulate with half sinusoidal pulse shaping
y = h.iqMod(v);

%--------------------------------------------------------------------
% [EOF]
