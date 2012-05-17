function reset(h, WGNState)
%RESET  Reset filtered Gaussian source object.
%   RESET(H) sets the state of a filtered Gaussian source object to a
%   random vector. The seed can be controlled by the property WGNState.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 03:05:11 $

% Number of paths
NC = h.NumChannels;

% Number of links
NL = h.NumLinks;

M = NC * NL;

% Use V5 generator for legacy mode and default generator for PCT
% Set white Gaussian noise source state if specified only in legacy mode.
if ~legacychannelsim
    if nargin==2
        error(generatemsgid('StateSetNotAllowed'), ...
              ['Setting the state of the random number generator is only allowed '...
               'in legacy mode.  Use LEGACYCHANNELSIM to switch to legacy mode.']);
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

% Initialize source output.
if ~h.QuasiStatic
    
    % Impulse response of filter
    IR = h.PrivateData.ImpulseResponse;
    [N, L] = size(IR);
    
    % Generate initial input vector for filter.
    % Generated as 2*M x L to handle state correctly.
    w2 = 1/sqrt(2) * randn(stream, 2*M, L);
    wgnoise = w2(1:M,:) + 1i*w2(M+1:end,:);
    
    % LastOutputs is Mx2 vector, i.e., storing last *two* outputs for each
    % channel. Needed for interpolation in parent objects.
    
    % One impulse response vector for all channels
    if N == 1
        h.LastOutputs = [zeros(M,1) sum(repmat(fliplr(IR), [M 1]).*wgnoise, 2)];
    else
        % Matrix of impulse responses (one per channel)
        h.LastOutputs = zeros(M,2);
        m = 0;
        n = 0;
        for ic = 1:NC
            n = n+1;
            for il = 1:NL
                m = m+1;
                h.LastOutputs(m,2) = sum( fliplr(IR(n,:)).*wgnoise(m,:), 2 );
            end
        end    
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
if legacychannelsim
    h.WGNState = stream.State;
end

for i = 1:length(h.CutoffFrequency)
    reset(h.Statistics(i));
end
