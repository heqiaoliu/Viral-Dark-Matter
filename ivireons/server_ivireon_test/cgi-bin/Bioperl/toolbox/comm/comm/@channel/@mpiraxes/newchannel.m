function newchannel(h, chan);
%NEWCHANNEL  Store new multipath channel data in multipath axes object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:20:34 $

% Base class newchannel.
h.mpanimateaxes_newchannel(chan);

% Delays of underlying multipath components
tz = chan.PathDelays;
h.PathDelays = tz;  

% Channel filter.
cf = chan.ChannelFilter;

% Time domain for channel filter response
h.ChannelIRTimeDomain = cf.TapGains.Domain;

% Get path and tap gain history buffers.
z = chan.PathGainHistory.Buffer;   % numSamples x numPaths
g = cf.TapGainsHistory.Buffer; % numSamples x numt
gS = cf.SmoothIRHistory.Buffer; % numSamples x numt2

% Set magnitude responses.  Note: no old data needs to be stored.
tzp = repmat(tz, [3 1]);
h.NewChannelData.tzp = tzp(:).';
h.NewChannelData.Magz = abs(z);
h.NewChannelData.Magg = abs(g);
h.NewChannelData.MaggS = abs(gS);

% Parameters for smooth impulse response computation.
Ts = cf.InputSamplePeriod;
tSmooth = cf.TapIndicesSmooth;

% Time domain for channel filter response
h.ChannelSmoothIRTimeDomain = tSmooth * Ts;

% Discrete IR samples not captured by channel filter response.
t = cf.TapIndices;
ii = ((tSmooth>t(end) | tSmooth<t(1)) & tSmooth-floor(tSmooth)<eps);
h.NewChannelData.tgOut = h.ChannelSmoothIRTimeDomain(ii);
h.NewChannelData.MaggOut = h.NewChannelData.MaggS(:, ii);
