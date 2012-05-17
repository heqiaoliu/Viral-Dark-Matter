function reset(h)
%RESET  Reset signal statistics object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:55:19 $

% Initialize buffer contents to NaN so we can identify how full it is,
% e.g., for plotting.
uNaN = NaN;
h.Buffer = uNaN(ones(h.PrivateData.BufferSize, h.PrivateData.NumChannels));
h.IdxNext = 1;

h.NumNewSamples = 0;
h.NumSamplesProcessed = 0;
h.Count = 0;
h.Ready = 0;
h.Autocorrelation.Values = 0;
h.PowerSpectrum.Domain = 0;
h.PowerSpectrum.Values = 0;
