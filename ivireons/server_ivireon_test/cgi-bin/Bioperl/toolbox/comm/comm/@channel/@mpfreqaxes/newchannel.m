function newchannel(h, chan);
%NEWCHANNEL  Store new multipath channel data in multipath axes object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:20:29 $

% Base class newchannel.
h.mpanimateaxes_newchannel(chan);

% Delays of underlying multipath components
tau = chan.PathDelays;

% Sample period
Ts = chan.InputSamplePeriod;

% Path gain history
z = chan.PathGainHistory.Buffer;   % numSamples x numPaths

% Compute frequency response using DFT.
fmax = 1/(2*Ts); 
tauMax = max(tau);
if (tauMax==0)
    fs = fmax/10;
else
    fs = min(0.1/tauMax, fmax/100); 
end
f = -fmax+fs:fs:fmax; 
H = z * exp(-j*2*pi*tau.'*f);

newData.fmax = fmax;
newData.f = f;
newData.MagHdB = 20*log10(abs(H));

h.NewChannelData = newData;

