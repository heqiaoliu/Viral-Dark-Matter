function h2 = copy(h)
%COPY  Make a copy of a Rayleigh or Rician channel object.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2009/10/16 04:46:50 $

% This copy function does not work for class channel.multipath.
% It works only for child classes, i.e., rayleigh and rician.
if ~ismember(class(h), {'channel.rayleigh', 'channel.rician'})
    error('comm:channel_multipath_copy:class', ...
        'Object must be a rayleigh or rician channel.');
end

% Construct new object.
Ts = h.InputSamplePeriod;
fd = h.MaxDopplerShift;
K = h.KFactor;
tau = h.PathDelays;
PdB = h.AvgPathGaindB;
fdLOS = h.DirectPathDopplerShift;
if isequal(class(h), 'channel.rayleigh')
    h2 = channel.rayleigh(Ts, fd, tau, PdB);
    h2.KFactor = K;
elseif isequal(class(h), 'channel.rician')
    h2 = channel.rician(Ts, fd, K, tau, PdB, fdLOS);    
end

% Copy Doppler specrum object using overloaded copy method of doppler
% baseclass
h2.DopplerSpectrum = copy(h.DopplerSpectrum);

% % Copy rayleighfading and channelfilter objects.
h2.RayleighFading = intfiltgaussian_copy(h.RayleighFading);
h2.ChannelFilter = channelfilter_copy(h.ChannelFilter);

% Set other input properties.
h2.NormalizePathGains = h.NormalizePathGains;
h2.KFactor = h.KFactor;
h2.DirectPathDopplerShift = h.DirectPathDopplerShift;
h2.DirectPathInitPhase = h.DirectPathInitPhase;
h2.StoreHistory = h.StoreHistory;
h2.StorePathGains = h.StorePathGains;
h2.OptimizationMode = h.OptimizationMode;
h2.ResetBeforeFiltering = h.ResetBeforeFiltering;

% Set state-related properties.
h2.PathGains = h.PathGains;
h2.NumSamplesProcessed = h.NumSamplesProcessed;
h2.NumFramesProcessed = h.NumFramesProcessed;
h2.HistoryStored = h.HistoryStored;
h2.LastThetaLOS = h.LastThetaLOS;

% Set miscellaneous properties.
h2.HistoryLength = h.HistoryLength;
h2.PlotWhileFiltering = h.PlotWhileFiltering;
h2.ProbeFcn = h.ProbeFcn;

% Copy path gain history property.  
% This is class channel.buffer, which is flat.
h2.PathGainHistory = copy(h.PathGainHistory);
h2.PathGainHistory.PrivateData = h.PathGainHistory.PrivateData;

% Note that we do NOT copy the multipathfigure object because we want only
% one figure associated with each multipath object.

% Note that property 'SimulinkBlock' is NOT set because we don't want more
% than one object associated with a Simulink block.

% DopplerSpectrumPropertiesListener gets updated in
% @multipath\schema->setDopplerSpectrum when DopplerSpectrum is copied

% AvgPathGainVector is computed in @multipath\schema->setAvgPathGaindB and
% @multipath\@schema->setNormalizePathGains

% KFactorListener gets updated in @multipath\construct when object is
% constructed

% PathGainsPrivate is computed in @multipath\schema->setStoreHistory

% ChannelFilterDelay is computed in
% @multipath\schema->getChannelFilterDelay

% PGAndTGBufferSizes is computed in @multipath\schema->setHistoryLength

% PathGainHistoryTimeStep is recomputed each time in
% @multipath\schema->getPathGainHistoryTimeStep

% FigNeedsToBeInitialized is related to the multipathfigure object 

% FigNeedsToBeReset is related to the multipathfigure object