function h2 = sigStatisticsCopy(h)
%sigStatisticsCopy  Make a copy of a SigStatistics object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:55:20 $

% Copy statistics object.
h2 = copy(h);

% Copy buffer objects.
h2.Autocorrelation = copy(h.Autocorrelation);
h2.PowerSpectrum = copy(h.PowerSpectrum);
