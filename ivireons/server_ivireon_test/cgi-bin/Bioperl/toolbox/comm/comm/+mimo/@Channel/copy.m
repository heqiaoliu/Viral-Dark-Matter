function h = copy(this)
%COPY  Make a copy of a MIMO channel object.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/02/13 15:10:58 $

error(generatemsgid('NoCopy'), ['copy method is not supported by this '...
    'version of MIMO channels.']);

% Construct new object.
Nt = this.NumTxAntennas;
Nr = this.NumRxAntennas;
Ts = this.InputSamplePeriod;
fd = this.MaxDopplerShift;
tau = this.PathDelays;
PdB = this.AvgPathGaindB;

h = mimo.Channel(Nt, Nr, Ts, fd, tau, PdB);

mc = metaclass(h);
props = mc.Properties;

for p=1:length(props)
    pr = props{p};
    if (~pr.Dependent && ~pr.Transient)
        h.(pr.Name) = this.(pr.Name);
    end
end

% Make copies of objects
h.PrivDopplerSpectrum = copy(this.DopplerSpectrum);
h.RayleighFading = copy(this.RayleighFading);
h.ChannelFilter = copy(this.ChannelFilter);

% Setup listener for Rician K factor
h.KFactorListener = addlistener(h, ...
    'KFactor', ...
    'PostSet', ...
    @(hSrc, eData) react2kfactor(h));

% Setup listener for NumTxAntennas
h.NumTxAntennasListener = addlistener(h, ...
    'NumTxAntennas', ...
    'PostSet', ...
    @(hSrc, eData) react2NumTxAntennas(h));

% Setup listener for NumRxAntennas
h.NumRxAntennasListener = addlistener(h, ...
    'NumRxAntennas', ...
    'PostSet', ...
    @(hSrc, eData) react2NumRxAntennas(h));

