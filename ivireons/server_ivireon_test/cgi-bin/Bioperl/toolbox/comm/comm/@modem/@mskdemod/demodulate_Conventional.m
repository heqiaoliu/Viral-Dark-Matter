function y = demodulate_Conventional(h, x)
%DEMODULATE_CONVENTIONAL Demodulate conventional baseband MSK input signal
%   X using MSK demodulator object H. Return demodulated binary signal Y.
%   Binary symbol mapping is used.

%   Reference: M.K. Simon, S.M. Hinedi, and H.C. Lindsey, Digital Communication
%   Techniques - Signal Design and Detection, New Jersey: Prentice Hall, 1995

%   @modem/@mskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:02:40 $

[sigLen nChan] = size(x);  % number of symbols and number of channels
nSamps = h.SamplesPerSymbol;
nBits = sigLen / nSamps;
IorQ = h.PrivIorQ;
initDiffBit = h.PrivInitDiffBit;

% Reset the demodulator if number of input channels (nChan) and number of
% initial differential bits (size(initDiffBit,2)) are different
if ( nChan ~= size(initDiffBit,2) )
    warning([getErrorId(h) ':InitDiffBitReset'], ['The number of ' ...
        'channels has changed.  Resetting the demodulator.']);
    reset(h, nChan);
    IorQ = h.PrivIorQ;
    initDiffBit = h.PrivInitDiffBit;
end;

% IQ processing
[a2n1 b2n] = h.iqDemod(x);

% Create 2T sampled sequence
an = localUpsample(a2n1, 2);
bn = localUpsample(b2n, 2);

% Combine and differentially decode
if ( mod(nBits, 2) )
    % There are odd number of input bits.  I and Q branches will have
    % different number of bits.
    if ( IorQ )
        % The first bit is be on the I branch.  Interleave I and Q starting
        % with the I branch.
        y = an(1:end-1, :).*[initDiffBit; bn];
        h.PrivInitDiffBit = an(end, :);
    else
        % The first bit is be on the Q branch.  Interleave I and Q starting
        % with the Q branch.
        y = [initDiffBit; an].*bn(1:end-1, :);
        h.PrivInitDiffBit = bn(end, :);
    end
    h.PrivIorQ = mod(IorQ+1,2);
else
    % There are even number of input bits.  Both I and Q branches will have
    % the same number of bits.  Since I branch is offset w.r.t. the Q branch
    % to start from zero phase, we need to start interleaving with the Q branch
    y = [initDiffBit; an(1:end-1, :)].*bn;
    h.PrivInitDiffBit = an(end, :);
end

% Convert bipolar to binary
y = (y+1)/2;

%--------------------------------------------------------------------
function y = localUpsample(x, nSamp)
[wid, len] = size(x);
y = reshape(ones(nSamp,1)*reshape(x, 1, wid*len),wid*nSamp, len);

%--------------------------------------------------------------------
% [EOF]