function y = filterblock(chan, x)
% Multipath channel filtering for single block.
%
% Inputs:
%   x    - Input signal.
%   chan - Channel object.  
%   y    - Output signal.
%
% The sample period of the input signal must be consistent with that
% specified for the channel.

% If zero Doppler shift, z is channel "snapshot."
% Otherwise, it represents an evolution of gains.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/05/14 15:01:20 $

% Colored Gaussian noise source object.
cgn = chan.RayleighFading;

% Access cutoff frequency directly for speed (chan.MaxDopplerShift get is
% too slow).
fd = cgn.FiltGaussian.PrivateData.CutoffFrequency;   

if fd>0

    % Number of samples in generated fading signal vector.
    blockLength = length(x);  

    % Generate fading processes (interpolated).
    z = generateoutput(cgn, blockLength);
    
    % Scale using average path gains and K-factor.
    z = scalepathgains(chan, z);
     
    % Channel filter output and tap gains
    y = filter(chan.ChannelFilter, x, z);

else
    
    % Zero Doppler shift.
    % For efficiency, use previous values.
    
    z = chan.PathGains(end, :).';
    y = filter(chan.ChannelFilter, x);
    
end

% Update path gain history.
if chan.PathGainHistory.Enable
    update(chan.PathGainHistory, z.');
end

if (chan.StoreHistory)
    % Store all path gain vectors.
    chan.PathGains = z.';
    chan.HistoryStored = true;
elseif (chan.StorePathGains)
    % Store all path gain vectors.
    chan.PathGains = z.';
else
    % Store last path gain vector.
    chan.PathGains = z(:, end).';
end
