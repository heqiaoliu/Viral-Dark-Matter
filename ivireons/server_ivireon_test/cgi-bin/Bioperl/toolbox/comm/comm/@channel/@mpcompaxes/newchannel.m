function newchannel(h, chan);
%NEWCHANNEL  Store new multipath channel data in multipath axes object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:20:14 $

% Base class newchannel.
h.mpanimateaxes_newchannel(chan);

% Get path gain history buffer.
z = chan.PathGainHistory.Buffer;   % numSamples x numChannels

% Set new channel data.
y = 10*log10(abs(z.').^2);  % Convert to dB
setchanneldata(h, y);

% Set time domain.
h.TimeDomain = (0:size(z, 1)-1)*chan.PathGainHistoryTimeStep;
