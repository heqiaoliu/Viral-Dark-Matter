function initialize(h)
%INITIALIZE  Initialize multipath scattering function axes object.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:01:11 $

h.Title = 'Scattering Function';
h.Tag = 'Scattering function';
h.XLabel = 'Frequency (Hz)';
h.YLabel = 'Delay (s)';

% Initialize base class.
h.multipathaxes_initialize;
