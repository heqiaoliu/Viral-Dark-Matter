function newchannel(h, chan);
%NEWCHANNEL  Store new multipath channel data in multipath axes object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:20:44 $

% Base class newchannel.
h.mpanimateaxes_newchannel(chan);

% Get path gain history buffer.
z = chan.PathGainHistory.Buffer;   % numSamples x numChannels
Lz = size(z, 1);

% Compute cumulative phasors.
v = [zeros(1, Lz); cumsum(z.', 1)];

% Set old channel data.
if (h.FirstPlot)
    uNaN = NaN;
    h.OldChannelData = uNaN(ones(1, Lz));
else
    h.OldChannelData = h.NewChannelData(end, :);
end

% Set new channel data.
h.NewChannelData = v;

