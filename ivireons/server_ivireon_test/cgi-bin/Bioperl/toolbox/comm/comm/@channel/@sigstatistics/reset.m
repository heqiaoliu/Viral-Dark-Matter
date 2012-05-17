function reset(h);
%RESET  Reset signal statistics object.

%   Copyright 1996-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/12 23:12:27 $

% Can't use buffer's reset because it calls flush, which is overloaded.
buffer_flush(h);
h.NumNewSamples = 0;
h.NumSamplesProcessed = 0;
h.Count = 0;
h.Ready = 0;
h.Autocorrelation.Values = 0;
h.PowerSpectrum.Domain = 0;
h.PowerSpectrum.Values = 0;
