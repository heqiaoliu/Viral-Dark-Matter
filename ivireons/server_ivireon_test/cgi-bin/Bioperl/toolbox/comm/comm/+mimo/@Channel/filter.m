function y = filter(chan, x)
%FILTER  Multipath MIMO channel filtering.
%	Y = FILTER(CHAN, X) passes signal X through the multipath MIMO channel CHAN
%	to obtain the channel impaired signal Y.
%
%   CHAN is a MIMO channel generated using the MIMOCHAN function.  X is the
%   input signal of size Ns x Nt, where Ns is the number of samples and Nt is
%   the number of transmit antennas.  Y is the output signal of size Ns x Nr,
%   where Nr is the number of received antennas.  Nt, Nr, and sample period of
%   the input signal must match the MIMO channel CHAN's parameters.  
%
%   Example:
%   % Create a 2x2 MIMO Rayleigh fading MIMO channel with maximum Doppler shift
%   % of 10 Hz.  The input signal has a sample period of 1 us.
%   chan = mimochan(2, 2, 1e-6, 10);
%   % Create a BPSK modulator
%   hMod = modem.pskmod(2);
%   % Generate random data and modulate
%   txSyms = randi([0 hMod.M-1], 1000, 2);
%   txSig = modulate(hMod, txSyms);
%   % Pass the modulated signal through the MIMO channel
%   rxSig = filter(chan, txSig);
%
%   See also MIMOCHAN, MIMO.CHANNEL/RESET.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 17:45:26 $

% Check number of arguments.
error(nargchk(2, 2, nargin));

if isempty(x) || ~isnumeric(x)
    error('comm:mimo:channel_filter:inputNumeric', ...
        'Input signal must be numeric.');
end

ndimsx = ndims(x);
if ndimsx > 2
    error('comm:mimo:channel_filter:inputVectorDims', ...
        'Input signal must be a vector or matrix.');
end

[Ns Nt] = size(x);
if Nt ~= chan.NumTxAntennas
    error('comm:mimo:channel_filter:inputVectorNt', ...
        ['The number of columns of the input signal must' ...
        ' be equal to the number of transmit antennas.']);
end

%--------------------------------------------------------------------------
% Filtering
%--------------------------------------------------------------------------

% Reset channel if required.
if chan.ResetBeforeFiltering
    reset(chan);
end

% Colored Gaussian noise source object.
cgn = chan.RayleighFading;
% Access cutoff frequency directly for speed (chan.MaxDopplerShift get is
% too slow).
fd = cgn.FiltGaussian.PrivateData.CutoffFrequency;   

L = length(chan.ChannelFilter.PrivateData.PathDelays);

Nr = chan.NumRxAntennas;
NL = Nt * Nr;

if fd>0
    % Generate fading processes (interpolated).
    z = generateOutput(cgn, Ns);
    
    % Scale using average path gains and K-factor.
    z = scalePathGains(chan, z);
    
    % Channel filter output and tap gains
    yf = filter(chan.ChannelFilter, x, z);
    
else
    % Zero Doppler shift. For efficiency, use previous values.
    z = zeros(L*NL,1);
    for il = 1:L
        for it = 1:Nt
            for ir = 1:Nr                
                idx = (il-1)*NL + (it-1)*Nr + ir;
                z(idx,1) = chan.PathGains(end,il,it,ir);
            end
        end
    end
    z = z * sqrt(Nr);
        
    yf = filter(chan.ChannelFilter, x);
end

% Summation of contributions from different transmit antennas
y = zeros(Ns, Nr);
for ir = 1:Nr
    for it = 1:Nt
        idx = (it-1)*Nr + ir;
        y(:,ir) = y(:,ir) + yf(:,idx);
    end
end
% Normalize by number of receive antennas so that the total output power is
% equal to the total input power
y = y/sqrt(Nr);
    
%--------------------------------------------------------------------------
% Postprocessing
%--------------------------------------------------------------------------

if (chan.StorePathGains)
    % Store all path gains.
    chan.PathGains = zeros(Ns,L,Nt,Nr);
    for il = 1:L
        for it = 1:Nt
            for ir = 1:Nr
                idx = (il-1)*NL + (it-1)*Nr + ir;
                chan.PathGains(:,il,it,ir) = z(idx,:);
            end
        end
    end    
    
else
    % Store last path gains.
    for il = 1:L
        for it = 1:Nt
            for ir = 1:Nr
                idx = (il-1)*NL + (it-1)*Nr + ir;
                chan.PathGains(:,il,it,ir) = z(idx,end);
            end
        end
    end
    
end
chan.PathGains = chan.PathGains/sqrt(Nr);

% Increment number of samples and frames processed.
chan.NumSamplesProcessed = chan.NumSamplesProcessed + Ns;
chan.NumFramesProcessed = chan.NumFramesProcessed + 1;
