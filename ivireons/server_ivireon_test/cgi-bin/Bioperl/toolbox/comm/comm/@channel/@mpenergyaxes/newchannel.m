function newchannel(h, chan);
%NEWCHANNEL  Store new multipath channel data in multipath axes object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:20:24 $

% Base class newchannel.
h.mpanimateaxes_newchannel(chan);

% Get path and tap gain history buffers.
z = chan.PathGainHistory.Buffer;   % numSamples x numChannels
g = chan.ChannelFilter.TapGainsHistory.Buffer; % numSamples x numt

% Compute energy for three cases:
% (1) Total energy of components;
% (2) Energy of bandlimited impulse response;
% (3) Narrowband energy (energy of phasor sum)
E = 10*log10( [...
        sum(abs(z).^2, 2) ...
        sum(abs(g).^2, 2) ...
        abs(sum(z, 2)).^2 ...
] );

% Set new channel data.
setchanneldata(h, E);

% Set time domain.
h.TimeDomain = (0:size(z, 1)-1)*chan.PathGainHistoryTimeStep;
