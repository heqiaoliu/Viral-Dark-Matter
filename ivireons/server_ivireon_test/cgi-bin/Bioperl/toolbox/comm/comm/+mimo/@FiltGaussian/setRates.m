function setRates(h, Ts, fc)
%SETRATES  Set sample period and cutoff frequency for source.
%  SETRATES(H, TS, FC) sets the output sample period and cutoff frequency
%  of filtgaussian object H to TS and FC, respectively.  TS is in seconds
%  and FC is in Hertz.  1/TS must be smaller than 100*FC to avoid an overly
%  long filter impulse response.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:55:02 $

if (Ts<=0.0)
    error('comm:mimo:filtgaussian_setrates:ts', ...
        'Output sample period must be greater than zero.');
end

if (fc<0.0)
    error('comm:mimo:filtgaussian_setrates:fc', ...
        'Cutoff frequency must be greater than or equal to zero.');
end

h.QuasiStatic = any(fc==0);

h.PrivateData.OutputSamplePeriod = Ts;
h.PrivateData.CutoffFrequency = fc;

if ~(h.QuasiStatic)
    N = 1./(Ts.*fc);
    if any(N>100)
        error('comm:mimo:filtgaussian_setrates:N', ...
                ['Oversampling factor too large.  ' ...
               'Use setRates(h, Ts, fc) with 1/Ts < 100*fc.']);
    end
    h.PrivateData.OversamplingFactor = N;
else
    h.PrivateData.OversamplingFactor = NaN * ones(1,length(fc));
end

if h.Constructed, initialize(h); end
