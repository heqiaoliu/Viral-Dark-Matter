function initChannel(h, varargin)

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/02/13 15:10:59 $

numParam = length(varargin);

% Error checking on NumTxAntennas and NumRxAntennas
Nt = cell2mat(varargin(1));
if ( ~isnumeric(Nt) || ~isscalar(Nt) || ~isreal(Nt) || (floor(Nt) ~= Nt) ...
            || isinf(Nt) || isnan(Nt) || (Nt<1) || (Nt>8))
        error('comm:mimo:channel_construct:Nt', ...
            'NT must be an integer between 1 and 8.');
end
Nr = cell2mat(varargin(2));
if ( ~isnumeric(Nr) || ~isscalar(Nr) || ~isreal(Nr) || (floor(Nr) ~= Nr) ...
            || isinf(Nr) || isnan(Nr) || (Nr<1) || (Nr>8))
        error('comm:mimo:channel_construct:Nr', ...
            'NR must be an integer between 1 and 8.');
end

% Error checking on InputSamplePeriod and MaxDopplerShift
ts = cell2mat(varargin(3));
if ( ~isnumeric(ts) || ~isscalar(ts) || ~isreal(ts) || ts<=0 ...
        || isinf(ts) || isnan(ts) )
    error('comm:mimo:channel_construct:ts', ...
        'TS must be a strictly positive real finite scalar.');
end
fd = cell2mat(varargin(4));
if ( ~isnumeric(fd) || ~isscalar(fd) || ~isreal(fd) || fd<0 ...
        || isinf(fd) || isnan(fd) )
    error('comm:mimo:channel_construct:fd', ...
        'FD must be a non-negative real finite scalar.');
end

% Error checking on PathDelays
if numParam>=5
    tau = cell2mat(varargin(5));
    size_tau = size(tau);
    if size_tau(1) ~= 1
        error('comm:mimo:channel_construct:sizeTau', ...
            'TAU must be a row vector.');
    end
    if ~isreal(tau)
        error('comm:mimo:channel_construct:typeTau', ...
            'TAU must be real.');
    end    
    if any(isinf(tau)) || any(isnan(tau))
        error('comm:mimo:channel_construct:infNanTau', ...
            'Elements of TAU cannot be Inf or NaN.');
    end
end

% Error checking on AvgPathGaindB
if numParam==6
    pdb = cell2mat(varargin(6));
    size_pdb = size(pdb);
    if size_pdb(1) ~= 1
        error('comm:mimo:channel_construct:sizePdb', ...
            'PDB must be a row vector.');
    end
    if ~isreal(pdb)
        error('comm:mimo:channel_construct:typePdb', ...
            'PDB must be real.');
    end    
    if any(isinf(pdb)) || any(isnan(pdb))
        error('comm:mimo:channel_construct:infNanPdb', ...
            'Elements of PDB cannot be Inf or NaN.');
    end
    if ~isequal(size_pdb, size_tau)
        error('comm:mimo:channel_construct:PdbTau', ...
            'PDB must be the same size as TAU.');
    end
end

% Initialize private data for base signal processing.
h.basesigproc_initprivatedata;

% Create structure storing argument values and default values.
p = {'NumTxAntennas'
     'NumRxAntennas'
     'InputSamplePeriod'
     'MaxDopplerShift'
     'PathDelays'
     'AvgPathGaindB'};
v = {2, 2, 1, 0, 0, []};  % Default values
v(1:numParam) = varargin;  % Assign argument values.
s = cell2struct(v, p, 2);

numPaths = length(s.PathDelays);
numLinks = Nt*Nr;

% Rayleigh fading object
h.RayleighFading = mimo.RayleighFading(...
                                        s.InputSamplePeriod, ...
                                        s.MaxDopplerShift, ...
                                        numPaths, ...
                                        numLinks, ...
                                        'Maximum Doppler shift');
h.RayleighFading.MaxDopplerShift = fd;
                                    
df = h.RayleighFading.FiltGaussian;
defaultNF = 1024;  % Number of frequencies.
df.NumFrequencies = defaultNF;

% Channel filter object
h.ChannelFilter = mimo.ChannelFilter(s.InputSamplePeriod, s.PathDelays, numLinks, Nt, Nr);

% Set other object properties.

h.KFactor = 0;

% Setup listener for Rician K factor
h.KFactorListener = addlistener(h, ...
    'KFactor', ...
    'PostSet', ...
    @(hSrc, eData) react2kfactor(h));

h.DirectPathDopplerShift = 0;
h.DirectPathInitPhase = 0;

pd = h.PrivateData;
pd.LastThetaLOS = 0; 
h.PrivateData = pd;

if (~isempty(s.AvgPathGaindB))
    h.AvgPathGaindB = s.AvgPathGaindB; 
else
    h.AvgPathGaindB = zeros(1, numPaths);
end

% Default Doppler spectrum
h.DopplerSpectrum = doppler.jakes;

% Correlation matrices
h.NumTxAntennas = Nt;
h.NumRxAntennas = Nr;
h.TxCorrelationMatrix = eye(Nt);
h.RxCorrelationMatrix = eye(Nr);

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

h.initialize;

h.Constructed = true;

%------------------------
