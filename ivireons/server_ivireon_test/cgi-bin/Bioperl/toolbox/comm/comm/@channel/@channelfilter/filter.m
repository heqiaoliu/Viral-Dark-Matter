function y = filter(cf, x, z)
% Channel filtering.
% The current implementaion is for multipath fading channels.
%
%    cf - Channel filter object
%    x  - Input signal
%    z  - Evolution of path gains (optional)
%    y  - Output signal

%   Copyright 1996-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/01/25 21:28:25 $

% Starting state.  Use PrivateData for speed.
u = cf.PrivateData.State.';

% Signal length.
N = length(x);

% If z not specified, use current tap gains of channel filter.
% Perform channel filtering using MATLAB code.
if nargin==2
    
    g = cf.TapGains.Values.';
    L = size(g, 1);
    
    if L==1
        y = (g.*x).';  % Frequency-flat fading
    else
        
        i1 = 1:L-1;
        i2 = i1+1;
        y = zeros(1, N);

        for n = 1:N
            u(i2) = u(i1);
            u(1) = x(n);
            y(n) = g.'*u;
        end

    end

    updatetapgains(cf);

else

    if ~cf.UseCMEX

        if size(z, 2)~=N
            error('comm:channel_channelfilter_filter:lengthPathGains', ...
                'Length of z must be the same as length of x.');
        end

        g = cf.AlphaMatrix.' * z;
        L = size(g, 1);

        % Use evolution of g over block.
        if L==1
            y = (g.*x).';  % Frequency-flat fading
        else
            U = toeplitz([x(1); u(1:L-1)], x);
            u = U(:, end);
            y = sum(g.*U, 1).';
        end
        cf.TapGains.Values = g(:, N).';

        updatetapgains(cf, z);

    else

        % C-MEX
        xx = x.';
        if isreal(xx)
            xx = complex(xx);
        end
        if isreal(u)
            u = complex(u);
        end
        y = chanfilt(xx, z.', cf.AlphaMatrix, cf.AlphaIndices, u);
        
        updatetapgains(cf, z);

    end
    
end

% End state.  Use PrivateData for speed.
cf.PrivateData.State = u.';
