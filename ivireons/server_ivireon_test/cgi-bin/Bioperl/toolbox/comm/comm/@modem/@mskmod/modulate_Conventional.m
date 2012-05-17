function y = modulate_Conventional(h, x)
%MODULATE_CONVENTIONAL 	Conventional MSK modulation
%   MODEM.MSKMOD modulator object.

%   Reference: M.K. Simon, S.M. Hinedi, and H.C. Lindsey, Digital Communication
%   Techniques - Signal Design and Detection, New Jersey: Prentice Hall, 1995

%   @modem/@mskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:03 $

[nSym nChan] = size(x);  % number of symbols and number of channels
InitDiffBit = h.PrivInitDiffBit;
% Reset the modulator if number of input channels (nChan) and number of
% initial differential bits channels (size(InitDiffBit,2)) are different
if ( nChan ~= size(InitDiffBit, 2) )
    warning([getErrorId(h) ':InitDiffBitReset'], ['The number of ' ...
        'channels has changed.  Resetting the modulator.']);
    reset(h, nChan);
    InitDiffBit = h.PrivInitDiffBit;
end;

% Differentially encode the input signal
v = cumprod([InitDiffBit; 2*x-1]);
v = v(2:end,:);
h.PrivInitDiffBit = v(end,:);

% OQPSK modulate with half sinusoidal pulse shaping
y = h.iqMod(v);

%--------------------------------------------------------------------
% [EOF]
