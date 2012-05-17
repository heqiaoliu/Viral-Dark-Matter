function z = scalePathGains(chan, z)

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:54:42 $

K = chan.KFactor;

NL = chan.RayleighFading.NumLinks;

if any(K)

    ts      = chan.InputSamplePeriod;
    fdLOS   = chan.DirectPathDopplerShift;
    theta   = ts*fdLOS;
    frmSize = size(z(1,:),2);

    % Compute phase offset vector

    if chan.NumSamplesProcessed == 0
        % The fading process has been (re-)initialized: the starting phase is
        % equal to the specified initial phase.
        thetaInitLOS = (chan.DirectPathInitPhase/(2*pi)).';
    else
        % The fading process for the current frame is continued from the
        % previous frame: the starting phase is equal to the phase at the end
        % of the last frame plus a phase increment of theta.
        thetaInitLOS = chan.LastThetaLOS + theta.';
    end
    % z1 is the temporary variable that stores phase offsets for the line
    % of sight path(s)
    z1 = [thetaInitLOS repmat(theta.', 1, frmSize-1)];

    % No offset for first sample: start at time t = 0, i.e. exp(jw0) = 1
    z1 = cumsum(z1(:,1:frmSize),2);

    % Store last values of phase offsets for next iteration
    chan.LastThetaLOS = z1(:, end);

    z1 = exp(sqrt(-1)*2*pi*z1);

    if isscalar(K)
        % Rician K-factor bias for first path.
        % Retained for backwards compatibility (no scalar expansion)
        z1 = z1 * sqrt(K);
        z(1:NL, :) = (z(1:NL, :) + repmat(z1,[NL 1])) / sqrt(K+1);
    else
        z1 = z1 .* repmat( sqrt(K).', 1, frmSize );
        z = (z + kron(z1, ones(NL,1))) ./ repmat( kron(sqrt(K+1).', ones(NL,1)), 1, frmSize );
    end

end

% Apply path gain factors.
APG = chan.AvgPathGainVector;
z = repmat(kron(APG, ones(NL,1)), [1 size(z, 2)]) .* z;


