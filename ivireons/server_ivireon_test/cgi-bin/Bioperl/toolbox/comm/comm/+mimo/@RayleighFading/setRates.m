function setRates(h, Ts, fc)
%SETRATES  Set sample period and cutoff frequency for source.
%  SETRATES(H, TS, FC) sets the output sample period and cutoff frequency
%  of intfiltgaussian object H to TS and FC, respectively.  TS is in
%  seconds and FC is in Hertz.  1/TS must be smaller than 100*FC to avoid
%  an overly long filter impulse response.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:55:14 $

if (Ts<=0.0)
    error('comm:mimo:rayleighfading_setrates:ts', ...
        'Output sample period must be greater than zero.');
end

if (fc<0.0)
    error('comm:mimo:rayleighfading_setrates:fc', ...
        [h.CutoffFrequencyName{find(fc<0,1)} ...
        ' must be greater than or equal to zero.']);
end

% Compute oversampling and interpolation factors.
NTarget = h.TargetFGOversampleFactor;
N = zeros(length(fc),1);
KI = zeros(length(fc),3);
for i_fc = 1:length(fc)
    [KI(i_fc,:), N(i_fc,1)] = intfiltgaussian_intfactor(Ts, fc(i_fc), NTarget,...
                                 h.CutoffFrequencyName{i_fc});
end

% Set sample period and cutoff frequency for filtgaussian source.
if (fc>0)
    fgTs = 1./(N'.*fc);
else
    fgTs = Ts * ones(1,length(fc));
end
setRates(h.FiltGaussian, fgTs, fc);

% Set filtered-Gaussian polyphase/linear interpolation factors,
% corresponding to the fading process with the highest bandwidth.
[fcmax, ifcmax] = max(fc);
h.InterpFilter.PolyphaseInterpFactor = KI(ifcmax,2);
h.InterpFilter.LinearInterpFactor = KI(ifcmax,3);

if h.Constructed, initialize(h); end
