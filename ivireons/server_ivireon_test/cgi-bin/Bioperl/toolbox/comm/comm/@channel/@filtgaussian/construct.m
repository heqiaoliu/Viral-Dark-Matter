function construct(h, varargin);
%CONSTRUCT  Construct filtered Gaussian source object.
%
%   Inputs:
%     Ts - Output sample period (s)
%     fc - Cutoff frequency (Hz)
%     M  - Number of channels
%     NF - Number of frequencies for power spectra

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:07 $

error(nargchk(1, 5, nargin,'struct'));
numParams = length(varargin);
if (numParams==1)
    error('comm:channel:filtgaussian_construct:CutOffFreqReqd',['If you specify the output sample period, ' ...
           'you must also specify the cutoff frequency.']);
end

% Initialize private data.
h.initprivatedata;

% Initialize Statistics property.
% This needs to be done first because set_numchannels uses it.
h.Statistics = channel.sigstatistics;

% Set properties if specified.
if (numParams>=2)
    setrates(h, varargin{1}, varargin{2});
end
p = {'NumChannels'
     'NumFrequencies'};
numExtraParams = numParams - 2;
set(h, {p{1:numExtraParams}}, {varargin{3:end}});

% Initialize sigresponse objects.
h.PowerSpectrum = channel.sigresponse;
h.Autocorrelation = channel.sigresponse;
    
h.initialize;

h.Constructed = true;
