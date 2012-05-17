function y = generateoutput(s, L)
%GENERATEOUTPUT  Generate output from filtered Gaussian source object.
%   Y = GENERATEOUTPUT(S, L) generates M fading process outputs, where M
%   is the number of channels (given by NumChannels property of S) and L
%   is the length of each random process.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/04/21 03:05:21 $

% Extract private data (used for speed, instead of individual properties).
sData = s.PrivateData;

% Number of paths and length of state vectors.
[M Ls] = size(sData.State);

% If no outputs required, return empty matrix (with correct number of
% rows).
if L==0, y=zeros(M, 0); return; end

% If quasi-static, simply return replication of last outputs.
if s.QuasiStatic
    y = repmat(sData.LastOutputs(:, end), [1 L]);
    return
end

if ~sData.UseCMEX

    % Impulse response of filter (same for all channels).
    h = sData.ImpulseResponse;
    [Nh, Lh] = size(h); % Size of filter response.
    
    % Create a local random number stream using either the seed or
    % the full state stored in source object.
    if isscalar(sData.WGNState)
        stream = RandStream('shr3cong','seed',sData.WGNState);
    else
        stream = RandStream('shr3cong');
        stream.State = sData.WGNState;
    end

    % Generate noise vector with prepended state.
    % Generated as 2*M x L to handle real/imag parts in correct order.
    % This order can be important when resetting state.
    w2 = 1/sqrt(2) * randn(stream, 2*M, L);
    wgnoise = [sData.State (w2(1:M,:) + 1i*w2(M+1:end,:))];

    % Save random number stream state to source object.
    sData.WGNState = stream.State;
    
    % Compute waveform.
    y = zeros(M, L);
    for m = 1:M
        if Nh == 1
            % One impulse response vector
            yrow = conv(h, wgnoise(m, :));  % Filter noise.
        else
            % Matrix of impulse responses
            yrow = conv(h(m,:), wgnoise(m, :));
        end    
        y(m, :) = yrow(Lh:end-Lh+1); % Trim waveform.
    end

    % Update state and last outputs.
    sData.State = wgnoise(:, end-Ls+1:end);

    % Store last *two* outputs for each channel.
    % Needed for interpolation by parent objects.
    if L==1
        sData.LastOutputs = [sData.LastOutputs(:, end) y(:, 1)];
    else
        sData.LastOutputs = y(:, end-[1 0]);
    end

else
    
   % Use C-MEX function (for speed).
   
    % Force a copy of sData.
    % Changing WGNState makes sure this happens.
    sData.WGNState = sData.WGNState + 0;
    legacyMode = double(legacychannelsim || s.PrivLegacyMode);
  
    y = fggen(...
        L, ...
        sData.ImpulseResponse, ...
        sData.State, ...
        sData.LastOutputs, ...
        sData.WGNState, ...
        legacyMode);
    y = y.';
    
end

% Store private data.
s.PrivateData = sData;

% This does nothing for base class.
storeoutput(s, y);
