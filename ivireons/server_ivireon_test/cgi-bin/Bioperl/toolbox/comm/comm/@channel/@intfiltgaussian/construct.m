function construct(h, varargin)
%CONSTRUCT  Construct interpolating-filtered Gaussian source object.
%
%  Inputs:
%     h     - Interpolating-filtered Gaussian source object
%     Ts    - Output sampling period (s)
%     fc    - Cutoff frequency (Hz)
%     NC    - Number of channels
%     fcStr - Cutoff frequency name (string)

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/23 07:48:54 $

error(nargchk(1, 5, nargin,'struct'));

numParam = length(varargin);

if (numParam==1)
    error('comm:channel_intfiltgaussian_initialize:numargs', ...
        'Invalid number of arguments.');
end

% Initialize private data.
h.initprivatedata;

% Create structure storing argument values and default values.
p = {'OutputSamplePeriod', 'CutoffFrequency', 'NumChannels', ...
    'CutoffFrequencyName'};
v = {1, 0, 1, 'Cutoff frequency'};  % Default values
v(1:numParam) = varargin;  % Assign argument values.
s = cell2struct(v, p, 2);

% Sample period and cutoff frequency.
Ts = s.OutputSamplePeriod;
fc = s.CutoffFrequency;
fcStr = s.CutoffFrequencyName;

% Calculate interpolating factors.
[KI, N] = intfiltgaussian_intfactor(Ts, fc, h.TargetFGOversampleFactor, ...
    fcStr);

% Sample period for filtgaussian source.
if (fc>0)
    fgTs = 1/(N*fc);
else
    fgTs = Ts;
end

% Cutoff frequency name
h.CutoffFrequencyName = fcStr;

% Filtered Gaussian and interpolating filter objects
h.FiltGaussian = channel.filtgaussian(fgTs, fc, s.NumChannels);
h.InterpFilter = channel.interpfilter(KI(2), KI(3), s.NumChannels);

h.initialize;

h.Constructed = true;
