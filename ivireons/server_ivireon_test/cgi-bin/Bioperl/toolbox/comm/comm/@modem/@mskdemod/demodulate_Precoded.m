function y = demodulate_Precoded(h, x)
%DEMODULATE_PRECODED Demodulate precoded baseband MSK input signal
%   X using MSK demodulator object H. Return demodulated binary signal Y.
%   Binary symbol mapping is used.

%   Reference: M.K. Simon, S.M. Hinedi, and H.C. Lindsey, Digital Communication
%   Techniques - Signal Design and Detection, New Jersey: Prentice Hall, 1995

%   @modem/@mskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:59:14 $

[sigLen nChan] = size(x);  % number of symbols and number of channels
nSamps = h.SamplesPerSymbol;
nBits = sigLen / nSamps;
IorQ = h.PrivIorQ;
demodStates = h.PrivDecimFilterI.States;

% Reset the demodulator if number of input channels (nChan) and number of
% states in the filter (size(demodStates,2)) are different
if ( nChan ~= size(demodStates,2) )
    warning([getErrorId(h) ':DemodStatesReset'], ['The number of ' ...
        'channels has changed.  Resetting the demodulator.']);
    reset(h, nChan);
    IorQ = h.PrivIorQ;
end;

% IQ processing
[a2n1 b2n] = h.iqDemod(x);

% Insert zeros between rows
an = localUpsample(a2n1, 2);
bn = localUpsample(b2n, 2);

% Combine
if ( mod(nBits, 2) )
    % There are odd number of input bits.  I and Q branches will have
    % different number of bits.
    if ( IorQ )
        % The first bit is be on the I branch.  Interleave I and Q starting
        % with the I branch.
        y = an(1:end-1,:) + [zeros(1, nChan); bn];
    else
        % The first bit is be on the Q branch.  Interleave I and Q starting
        % with the Q branch.
        y = [zeros(1, nChan); an] + bn(1:end-1,:);
    end
    h.PrivIorQ = mod(IorQ+1,2);
else
    % There are even number of input bits.  Both I and Q branches will have
    % the same number of bits.  Since I branch is offset w.r.t. the Q branch
    % to start from zero phase, we need to start interleaving with the Q branch
    y = circshift(an, 1) + bn;
end

% Convert bipolar to binary
y = (y+1)/2;

%--------------------------------------------------------------------
function y = localUpsample(x, nSamp)
[wid, len] = size(x);
y = reshape([1; zeros(nSamp-1,1)]*reshape(x, 1, wid*len),wid*nSamp, len);

%--------------------------------------------------------------------
% [EOF]