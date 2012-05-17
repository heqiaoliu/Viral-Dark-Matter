function y = iqMod(h, v)
%IQMOD Modulate bipolar input v using an IQ structure similar to an OQPSK signal
%   with half sinusoidal pulse shaping.

% @modem/@mskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:01 $

[nSym nChan] = size(v);  % number of symbols and number of channels
nSamps = h.SamplesPerSymbol;
IorQ = h.PrivIorQ;
signStateI = h.PrivSignStateI;
signStateQ = h.PrivSignStateQ;
initY = h.PrivInitY;

y = zeros(nSym*nSamps, nChan);
for p=1:nChan
    % Determine in-phase and quadrature bit indices.  Note that the very first
    % bit is placed on the quadrature branch, to ensure that the modulator
    % output phase starts from phase zero.
    if ( IorQ )
        % First bit to in-phase branch
        qIndex = 2:2:size(v,1);
        iIndex = 1:2:size(v,1);
    else
        % First bit to quadrature branch
        qIndex = 1:2:size(v,1);
        iIndex = 2:2:size(v,1);
    end

    % Calculate quadrature data stream (v(2n))
    v2n = v(qIndex, p);
    v2nLen = length(v2n);
    % Alternate sign to implement multiplication with a continuous sinusoidal
    % through
    % pulse shaping with half sinusoidal.
    v2np = ((-1).^((1:v2nLen)'+signStateQ)).*v2n;

    % Calculate in-phase data stream (v(2n-1))
    v2n1 = v(iIndex, p);
    v2n1Len = length(v2n1);
    % Alternate sign to implement multiplication with a continuos sinusoidal through
    % pulse shaping with half sinusoidal
    v2n1p = ((-1).^((1:v2n1Len)'+signStateI)).*v2n1;

    % Pulse shape the phase with half sinusoidal pulse and delay Q by nSamps
    vI = localUpsample(v2n1p, 2*nSamps);
    vQ = localUpsample(v2np, 2*nSamps);
    yI = filter(h.PrivInterpFilterI, vI);
    yQ = filter(h.PrivInterpFilterQ, vQ);

    if mod(nSym,2)
        % There are odd number of input bits.  I and Q branches will have
        % different number of bits.  
        if IorQ
            % The first bit was put into the I branch.  I branch will be nSamps
            % longer than needed.  Store the last nSamps of the I branch for the
            % next call.  Append the Q branch with the samples saved from the
            % last call.
            y(:,p) = complex(yI(1:end-nSamps, :), -[initY(:,p); yQ(1:end, :)]);
            h.PrivInitY(:,p) = yI(end-nSamps+1:end,:);
        else
            % The first bit was put into the Q branch.  Q branch will be nSamps
            % longer than needed.  Store the last nSamps of the Q branch for the
            % next call.  Append the I branch with the samples saved from the
            % last call.
            y(:,p) = complex([initY(:,p); yI(1:end, :)], -yQ(1:end-nSamps, :));
            h.PrivInitY(:,p) = yQ(end-nSamps+1:end,:);
        end
    else
        % There are even number of input bits.  Both I and Q branches will have
        % the same number of bits.  Since I branch is offset w.r.t. the Q branch
        % to start from zero phase, we need to restore the first nSamps from the
        % previous call and save the last nSmaps for the next call.
        y(:,p) = complex([initY(:,p); yI(1:end-nSamps, :)], -yQ(1:end, :));
        h.PrivInitY(:,p) = yI(end-nSamps+1:end,:);
    end
end

% Store states
h.PrivIorQ = mod(IorQ+nSym,2);
h.PrivSignStateI = mod(signStateI+v2n1Len, 2);
h.PrivSignStateQ = mod(signStateQ+v2nLen, 2);

%--------------------------------------------------------------------
function y = localUpsample(x, nSamp)
[wid, len] = size(x);
y = reshape([1; zeros(nSamp-1,1)]*reshape(x, 1, wid*len),wid*nSamp, len);

%--------------------------------------------------------------------
% [EOF]