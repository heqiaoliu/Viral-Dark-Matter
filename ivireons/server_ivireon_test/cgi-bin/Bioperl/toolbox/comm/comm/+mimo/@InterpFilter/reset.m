function reset(h, x)
%RESET  Reset interpolating filter object.
%
% Inputs:
%    h - Interpolating filter object.
%    x - Optional initial input vector (row vector or matrix).
%    (Rows of x represent channels for multichannel signal.)

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:55:07 $

L = h.SubfilterLength;  % Length of polyphase filters.
NC = h.NumChannels;     % Number of channels (paths).
NL = h.NumLinks;        % Number of links

M = NC * NL;

R = h.PolyphaseInterpFactor; % Polyphase filter interpolation factor.

if nargin==1
    % Default reset.
    
    phase = 1;  % Polyphase filter phase.
    h.FilterInputState = zeros(M, L);
    h.LastFilterOutputs = zeros(M, 2);
    h.NumSamplesProcessed = 0;

else
    % Reset as if processed input samples in x.
    % Determine polyphase filter state (u) and phase.

    [Mx N] = size(x);
    
    if R==1
        u = x(:, end).';
        phase = 1;  % Polyphase filter phase.
    else
        if Mx~=M
            error('comm:mimo:interpfilter_reset:numChannelsLinks', ...
                'Incompatible number of channels and/or links.');
        end
        if N<L
            u = [fliplr(x) zeros(M, L-N)].';
        else
            u = fliplr(x(:, end-L+1:end)).';
        end
        phase = R - (h.LinearInterpFactor==1);
    end

    h.FilterInputState = u.';
    h.LastFilterOutputs(:, 2) = (h.FilterBank(phase, :) * u).';
    h.NumSamplesProcessed = N;

end

% Reset filter phase and linear interpolation index.
h.FilterPhase = phase;
h.LinearInterpIndex = 1;
