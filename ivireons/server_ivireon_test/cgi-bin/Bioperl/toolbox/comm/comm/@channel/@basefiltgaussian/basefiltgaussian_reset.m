function basefiltgaussian_reset(h, WGNState)
%BASEFILTGAUSSIAN_RESET  Reset filtered Gaussian source object.
%   BASEFILTGAUSSIAN_RESET(H) sets the state of a filtered Gaussian source
%   object to a random vector. The seed can be controlled by the property
%   WGNState.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2009/05/23 07:48:51 $

% Number of channels.
M = h.NumChannels;

% Use V5 generator for legacy mode and default generator for PCT
% Set white Gaussian noise source state if specified only in legacy mode.
if ~(legacychannelsim || h.PrivLegacyMode)
    if nargin==2
        error(generatemsgid('StateSetNotAllowed'), ...
              ['Setting the state of the random number generator is only '...
               'allowed in legacy mode. Use LEGACYCHANNELSIM to switch '...
               'to legacy mode. For more details see Release Notes.']);
    else
        stream = RandStream.getDefaultStream;
    end
else
    if nargin==2
        h.WGNState = WGNState;
    else
        WGNState = h.WGNState;
    end
    % Create a local random number stream using either the seed or
    % the full state stored in source object.
    if isscalar(WGNState)
        stream = RandStream('shr3cong','seed',WGNState);
    else
        stream = RandStream('shr3cong');
        if ~isempty(WGNState)
            stream.State = WGNState;
        end
    end
end


% Initialize source output (M channels => M outputs).
if ~h.QuasiStatic
    
    % Impulse response of filter (same for all channels)
    IR = h.PrivateData.ImpulseResponse;
    [N, L] = size(IR);
    
    % Generate initial input vector for filter.
    % Generated as 2*M x L to handle state correctly.
    w2 = 1/sqrt(2) * randn(stream, 2*M, L);
    wgnoise = w2(1:M,:) + 1i*w2(M+1:end,:);
    
    % LastOutputs is Mx2 vector, i.e., storing last *two* outputs for each
    % channel. Needed for interpolation in parent objects.
    if N == 1
        h.LastOutputs = [zeros(M,1) sum(repmat(fliplr(IR), [M 1]).*wgnoise, 2)];
    else
        h.LastOutputs = [zeros(M,1) sum(fliplr(IR).*wgnoise, 2)];
    end
    
    % Initialize state.
    h.State = wgnoise(:, 2:end);

else
    
    % Quasi-static.
    h.LastOutputs = 1/sqrt(2) * (randn(stream, M, 1) + 1i*randn(stream, M, 1));
    h.State = zeros(M, 0);

end

h.NumSampOutput = 0;

% Save random number stream state to source object.
if legacychannelsim || h.PrivLegacyMode
    h.WGNState = stream.State;
end
