function construct(h, varargin)
%CONSTRUCT  Construct multipath channel object.
%
%  Inputs:
%    h      - Channel object
%    Ts     - Input sample period
%    fd     - Maximum Diffuse Doppler shift
%    (K     - Rician K-factor)
%    tau    - Path delay vector
%    PdB    - Average path gain vector (dB).
%    (fdLOS - Direct Path Doppler shift)

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/03/09 19:06:04 $

error(nargchk(1, 7, nargin,'struct'));
 
numParam = length(varargin);

if numParam==1
    error('comm:channel_multipath_initialize:numargs', ...
        'Invalid number of arguments.');
end

% Error checking on InputSamplePeriod and MaxDopplerShift
if numParam>=2
    ts = cell2mat(varargin(1));
    if ( ~isnumeric(ts) || ~isscalar(ts) || ~isreal(ts) || ts<=0 ...
            || isinf(ts) || isnan(ts) )
        error('comm:channel_multipath_construct:ts', ...
            'InputSamplePeriod must be a strictly positive real finite scalar.');
    end  
    fd = cell2mat(varargin(2));
    if ( ~isnumeric(fd) || ~isscalar(fd) || ~isreal(fd) || fd<0 ...
            || isinf(fd) || isnan(fd) )
        error('comm:channel_multipath_construct:fd', ...
            'MaxDopplerShift must be a non-negative real finite scalar.');
    end
end

% Error checking on PathDelays
if numParam>=4
    size_PathDelays = size(varargin{4});
    if size_PathDelays(1) ~= 1
        error('comm:channel_multipath_construct:sizePathDelays', ...
            'PathDelays must be a row vector.');
    end
    if ~isreal(cell2mat(varargin(4)))
        error('comm:channel_multipath_construct:typePathDelays', ...
            'PathDelays must be real.');
    end    
    if any(isinf(cell2mat(varargin(4)))) || any(isnan(cell2mat(varargin(4))))
        error('comm:channel_multipath_construct:infNanPathDelays', ...
            'Elements of PathDelays cannot be Inf or NaN.');
    end
end

% Initialize private data for base signal processing.
h.basesigproc_initprivatedata;

% Create structure storing argument values and default values.
p = {'InputSamplePeriod'
     'MaxDopplerShift'
     'KFactor'
     'PathDelays'
     'AvgPathGaindB'
     'DirectPathDopplerShift'};
v = {1, 0, 0, 0, [], 0};  % Default values
v(1:numParam) = varargin;  % Assign argument values.
s = cell2struct(v, p, 2);
numPaths = length(s.PathDelays);

% Rayleigh fading object
h.RayleighFading = channel.rayleighfading(...
    s.InputSamplePeriod, ...
    s.MaxDopplerShift, ...
    numPaths, ...
    'Maximum Doppler shift');
% Ensures that upon initialization MaxDopplerShift is fd
h.RayleighFading.MaxDopplerShift = s.MaxDopplerShift;
df = h.RayleighFading.FiltGaussian;
defaultNF = 1024;  % Number of frequencies.
df.NumFrequencies = defaultNF;

% Default buffer size for path gain and tap gain history
defaultHistoryLength = 0;

% Channel filter object
h.ChannelFilter = channel.channelfilter(...
    s.InputSamplePeriod, ...
    s.PathDelays);

% Path gain history
defaultDownSampleFactor = 1;  % Not supported yet.
h.PathGainHistory = channel.slidebuffer(...
    defaultHistoryLength, numPaths, defaultDownSampleFactor);

% Multipath figure object.
% Note that the multipath figure object is uninitialized.
h.MultipathFigure = channel.multipathfig;

% Set other object properties.

if isa(h, 'channel.rician')
    h.KFactor = s.KFactor;
end

% Setup listener for Rician K factor
l = handle.listener(h, ...
    h.findprop('KFactor'), ...
    'PropertyPostSet', @(hSrc, eData) react2kfactor(h));
set(h, 'KFactorListener', l);

h.DirectPathDopplerShift = s.DirectPathDopplerShift;
if ( (h.MaxDopplerShift == 0) && any(h.DirectPathDopplerShift) )
    warning('comm:channel_multipath:FDLOS_fdIs0', ...
        ['When the maximum Doppler shift FD is zero, using a non-zero value' ...
        ' for the Doppler shift of the line-of-sight component, FDLOS,' ...
        ' has no effect on the channel. FDLOS should also be zero.']);
end      
if  ( length(h.DirectPathDopplerShift) ~= length(h.KFactor) )
    % The size of DirectPathDopplerShift must match the size of KFactor,
    % since a line-of-sight component must exist for the corresponding
    % line-of-sight Doppler shift to exist.
    h.DirectPathDopplerShift = [h.DirectPathDopplerShift zeros(1,length(h.KFactor)-1)];
end    

h.DirectPathInitPhase = zeros(1, length(h.KFactor));

pd = h.PrivateData;
pd.LastThetaLOS = zeros(length(h.DirectPathInitPhase), 1); 
h.PrivateData = pd;

if (~isempty(s.AvgPathGaindB))
    h.AvgPathGaindB = s.AvgPathGaindB; 
else
    h.AvgPathGaindB = zeros(1, numPaths);
end

% Default Doppler spectrum
h.DopplerSpectrum = doppler.jakes;

h.ProbeFcn = [];

h.initialize;

h.Constructed = true;


%------------------------
function react2kfactor(h)

if h.Constructed
    % If the size of KFactor changes, the size of DirectPathDopplerShift
    % must change accordingly, since a line-of-sight component must exist
    % for the corresponding line-of-sight Doppler shift to exist.
    DirectPathDopplerShiftOld = h.DirectPathDopplerShift;
    h.DirectPathDopplerShift = tailorVector(DirectPathDopplerShiftOld, h.KFactor);
    DirectPathInitPhaseOld = h.DirectPathInitPhase;
    h.DirectPathInitPhase = tailorVector(DirectPathInitPhaseOld, h.KFactor);
end

%------------------------
function v = tailorVector(v, ref)
Lref = length(ref);
Lv = length(v);
if Lv<Lref
    v = [v zeros(1, Lref-Lv)];
elseif Lv>Lref
    v = v(1:Lref);
end

