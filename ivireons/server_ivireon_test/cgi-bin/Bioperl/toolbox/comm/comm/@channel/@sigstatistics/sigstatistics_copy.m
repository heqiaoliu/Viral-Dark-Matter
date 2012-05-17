function h2 = sigstatistics_copy(h);
%COPY  Make a copy of a sigstatistics object.

%   Copyright 1996-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:22:10 $

% Copy statistics object.
h2 = copy(h);

% Copy buffer objects.
h2.Autocorrelation = copy(h.Autocorrelation);
h2.PowerSpectrum = copy(h.PowerSpectrum);
