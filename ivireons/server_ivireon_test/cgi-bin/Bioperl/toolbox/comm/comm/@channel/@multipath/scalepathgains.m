function z = scalepathgains(chan, z)

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/02/18 01:29:13 $

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

z1 = exp(j*2*pi*z1);

K = chan.Kfactor;
if isscalar(K)
% Rician K-factor bias for first path.
% Retained for backwards compatibility (no scalar expansion)
    z1 = z1 * sqrt(K);
    z(1, :) = (z(1, :) + z1) / sqrt(K+1);
else
    z1 = z1 .* repmat( sqrt(K).', 1, frmSize );
    z = (z + z1) ./ repmat( sqrt(K+1).', 1, frmSize );
end

% Apply path gain factors.
z = applyavgepathgains(chan,z);

% [EOF]
