function reset(chan, WGNState)
%RESET  Reset the MIMO channel
%  RESET(CHAN) resets the MIMO channel CHAN, initializing the PathGains and
%  NumSamplesProcessed properties as well as internal filter states. This syntax
%  is useful when you want the effect of creating a new channel.
%
%  RESET(CHAN, RANDSTATE) resets the channel object CHAN and initializes the
%  state of the random number generator that the channel uses. RANDSTATE is a
%  two-element column vector or a scalar integer.  This syntax is useful when
%  you want to repeat previous numerical results that started from a particular
%  state. RESET(CHAN, RANDSTATE) will not accept RANDSTATE in a future release.
%  See LEGACYCHANNELSIM function for more information.
%
%   Example:
%   % Create a 2x2 MIMO Rayleigh block fading MIMO channel, i.e. maximum Doppler
%   % shift is 0.  The input signal has a sample period of 1 us. 
%   chan = mimochan(2, 2, 1e-6, 0);
%   % Create a new set of channel parameters
%   reset(chan)
%   % Note that if ResetBeforeFiltering is set to 1, reset is done automatically
%   % after each filter operation.
%
%   See also MIMOCHAN, MIMO.CHANNEL/FILTER.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/07/14 03:52:15 $

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
z = scalePathGains(chan, z);

L = length(chan.ChannelFilter.PrivateData.PathDelays);
Nt = chan.ChannelFilter.NumTxAntennas;
Nr = chan.ChannelFilter.NumRxAntennas;
NL = Nt * Nr;

chan.PathGains = zeros(1,L,Nt,Nr);
for il = 1:L
    for it = 1:Nt
        for ir = 1:Nr
            idx = (il-1)*NL + (it-1)*Nr + ir;
            chan.PathGains(:,il,it,ir) = z(idx,end);
        end
    end
end
chan.PathGains = chan.PathGains/sqrt(Nr);
    
% Reset channel filter.
reset(chan.ChannelFilter, z);

% Reset number of samples and frames processed.
chan.NumSamplesProcessed = 0;
chan.NumFramesProcessed = 0;
