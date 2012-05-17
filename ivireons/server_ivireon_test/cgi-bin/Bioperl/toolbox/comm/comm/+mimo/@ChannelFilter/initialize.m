function initialize(h)
%INITIALIZE  Initialize channel filter object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:54:47 $

if h.AutoComputeTapIndices
    computetapindices(h);
end

% Use private data for speed.
pd = h.PrivateData;

Ts = pd.InputSamplePeriod;
tau = pd.PathDelays;
Nt = pd.NumTxAntennas;
Nr = pd.NumRxAntennas;
tapidx = pd.TapIndices;
nTaps = length(tapidx);

h.TapGains = zeros(1, nTaps*Nt*Nr);  

h.State = complex(zeros(1, nTaps*Nt));

h.AlphaMatrix = sinc(rowcolSubtract(tau.'/Ts, tapidx));

computealphaindices(h);

%--------------------------------------------------------------------------
function computetapindices(h)

% Use private data for speed.
pd = h.PrivateData;
 
% Normalize path delays.
tRatio = pd.PathDelays/pd.InputSamplePeriod;

% Initial estimate of tapidx range.
% Minimum value of range is 0.
err = 0.1;  % Small value.
c = 1/(pi*err);  % Based on bound sinc(x) < 1/(pi*x).

tapidx = min(floor(min(tRatio) - c), 0) : ceil(max(tRatio) + c);

% Alternative: tapidx = min(min(tiRange(:,1)), 0) : max(tiRange(:,2));

% Pre-compute AlphaMatrix.
A = sinc(rowcolSubtract(tRatio.', tapidx));

% The following steps ensure that the tap index vector is shortened when
% tau/T values are close to integer values.

% For each path delay, determine significant values of abs(AlphaMatrix).
maxA = max(abs(A), [], 1);
err2 = 0.01; % Small value.
significantA = (maxA > err2*max(maxA));

% Determine significant range of tapidx values.
t1 = min(tapidx(find(cumsum(significantA)==1, 1)), 0);
t2 = tapidx(find(fliplr(cumsum(fliplr(significantA)))==1, 1, 'last'));
if t2-t1>100
    warning('comm:mimo_channelfilter_initialize:channeltaps', ...
        ['Some path delay values are much larger ', ...
        'than the input sample period, resulting in a long ', ...
        'channel filter response.']);
end
tapidx = t1:t2;

% Set tap indices.
pd.TapIndices = tapidx;

h.PrivateData = pd;

%--------------------------------------------------------------------------
function computealphaindices(h)

absA = abs(h.AlphaMatrix);
err = h.PrivateData.AlphaTol;
significantA = (absA >= err);

h.AlphaIndices = zeros(size(significantA, 1),2);
for n = 1:size(significantA, 1)
    h.AlphaIndices(n, :) = ...
        [find(significantA(n, :), 1) find(significantA(n, :), 1, 'last')];
end

%--------------------------------------------------------------------------
function y = rowcolSubtract(x1, x2)
    
y = repmat(x1, size(x2)) - repmat(x2, size(x1));
