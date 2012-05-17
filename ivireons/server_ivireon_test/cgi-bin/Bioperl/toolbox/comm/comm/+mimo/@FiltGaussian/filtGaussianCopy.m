function h2 = filtGaussianCopy(h)
%COPY  Make a copy of a filtgaussian object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:54:53 $

% Copy filtgaussian object.
h2 = copy(h);

h2.DopplerSpectrum = copy(h.DopplerSpectrum);

% Copy SigStatistics object.
for i = 1:length(h2.Statistics)
    h2.Statistics(i) = sigStatisticsCopy(h.Statistics(i));
end

% Copy buffer objects.
h2.Autocorrelation = copy(h.Autocorrelation);
h2.PowerSpectrum = copy(h.PowerSpectrum);
