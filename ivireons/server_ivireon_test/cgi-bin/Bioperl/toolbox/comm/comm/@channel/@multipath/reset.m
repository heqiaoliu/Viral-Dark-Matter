function reset(chan, WGNState)
%RESET  Reset multipath channel object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/05/09 23:06:42 $

% Reset Rayleigh fading source.  For zero Doppler shift, this is an
% efficient refresh operation.
if nargin==2
    reset(chan.RayleighFading, WGNState);
else
    reset(chan.RayleighFading);
end
    
if chan.MaxDopplerShift>0
    % Path gains corresponding to Rayleigh fading source outputs.
    z = chan.RayleighFading.InterpFilter.LastFilterOutputs(:, end);
         
else
    % For efficiency, handle zero Doppler shift in a specialized way.
    % No need to use interpolating filter.
    % Simply use last outputs from Doppler-filtered Gaussian source.
    z = chan.RayleighFading.FiltGaussian.LastOutputs(:, end);
end

% Scale path gains.
z = scalepathgains(chan, z);    
chan.PathGains = z.';
    
% Reset channel filter.
reset(chan.ChannelFilter, z);

% Path gain history.
reset(chan.PathGainHistory);

% Reset history logged flag.
chan.HistoryStored = false;

% Make sure multipath figure object is reset next plot.
chan.FigNeedsToBeReset = true;

% Reset number of samples and frames processed.
chan.NumSamplesProcessed = 0;
chan.NumFramesProcessed = 0;
