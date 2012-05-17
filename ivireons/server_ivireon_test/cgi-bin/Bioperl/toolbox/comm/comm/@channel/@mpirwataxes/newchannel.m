function newchannel(h, chan)
%NEWCHANNEL  Store new multipath channel data in multipath axes object.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/23 07:48:57 $

% Base class newchannel.
h.mpanimateaxes_newchannel(chan);

% Channel filter.
cf = chan.ChannelFilter;

% Parameters for smooth impulse response computation.
Ts = cf.InputSamplePeriod;
tSmooth = cf.TapIndicesSmooth;

% Time domain for channel filter response
h.ChannelSmoothIRTimeDomain = tSmooth * Ts;

% Get path and tap gain history buffers.
gS = cf.SmoothIRHistory.Buffer; % numSamples x numt2

% Set time domain (snapshots).
h.TimeDomain = (0:size(gS, 1)-1)*chan.PathGainHistoryTimeStep;

% Set old channel data.
if (h.FirstPlot)
    uNaN = NaN;
    h.OldChannelData = uNaN(ones(size(gS.')));
else
    h.OldChannelData = h.NewChannelData;
end

% Set new channel data.
h.NewChannelData = abs(gS.');


