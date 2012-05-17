function setrates(h, Ts, fc)
%SETRATES  Set sample period and cutoff frequency for source.
%  SETRATES(H, TS, FC) sets the output sample period and cutoff frequency
%  of filtgaussian object H to TS and FC, respectively.  TS is in seconds
%  and FC is in Hertz.  1/TS must be smaller than 100*FC to avoid an overly
%  long filter impulse response.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/06/08 15:52:00 $

if (Ts<=0.0)
    error('comm:channel_filtgaussian_setrates:ts', ...
        'Output sample period must be greater than zero.');
end

if (fc<0.0)
    error('comm:channel_filtgaussian_setrates:fc', ...
        'Cutoff frequency must be greater than or equal to zero.');
end

h.QuasiStatic = any(fc==0);

h.PrivateData.OutputSamplePeriod = Ts;
h.PrivateData.CutoffFrequency = fc;

if ~(h.QuasiStatic)
    N = 1./(Ts.*fc);
    if any(N>100)
        error('comm:channel_filtgaussian_setrates:N', ...
                ['Oversampling factor too large.  ' ...
               'Use setrates(h, Ts, fc) with 1/Ts < 100*fc.']);
    end
    h.PrivateData.OversamplingFactor = N;
else
    h.PrivateData.OversamplingFactor = NaN * ones(1,length(fc));
end

if h.Constructed, initialize(h); end
