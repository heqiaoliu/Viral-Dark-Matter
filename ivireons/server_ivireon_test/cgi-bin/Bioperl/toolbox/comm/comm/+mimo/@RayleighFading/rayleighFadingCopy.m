function h2 = rayleighFadingCopy(h)
%rayleighFadingCopy  Copy properties from another object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:55:12 $

% Copy rayleighfading object.
h2 = copy(h);

% Copy filtgaussian object.
h2.FiltGaussian = filtGaussianCopy(h.FiltGaussian);

% Copy interpfilter object.
h2.InterpFilter = copy(h.InterpFilter);
    