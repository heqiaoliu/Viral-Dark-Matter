function reset(h, x);
%RESET  Reset interpolating filter object.
%
% Inputs:
%    h - Interpolating filter object.
%    x - Optional initial input vector (row vector or matrix).
%    (Rows of x represent channels for multichannel signal.)

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/10 19:19:48 $

M = h.SubfilterLength; % Length of polyphase filters.
NC = h.NumChannels; % Number of channels.
R = h.PolyphaseInterpFactor; % Polyphase filter interpolation factor.

if nargin==1
    
    % Default reset.
    
    phase = 1;  % Polyphase filter phase.
    h.FilterInputState = zeros(NC, M);
    h.LastFilterOutputs = zeros(NC, 2);
    h.NumSamplesProcessed = 0;

else
    
    % Reset as if processed input samples in x.
    % Determine polyphase filter state (u) and phase.

    [NCx N] = size(x);
    
    if R==1
        u = x(:, end).';
        phase = 1;  % Polyphase filter phase.
    else
        if NCx~=NC
            error('comm:channel_interpfilter_reset:numChannels', ...
                'Incompatible number of channels.');
        end
        if N<M
            u = [fliplr(x) zeros(NC, M-N)].';
        else
            u = fliplr(x(:, end-M+1:end)).';
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
