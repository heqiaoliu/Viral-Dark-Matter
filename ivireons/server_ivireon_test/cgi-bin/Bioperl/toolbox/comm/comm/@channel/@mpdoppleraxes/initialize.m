function initialize(h)
%INITIALIZE  Initialize multipath doppler spectrum axes object.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/05/14 15:01:06 $

h.Title = 'Doppler spectrum';
h.Tag = 'Doppler spectrum';
h.XLabel = 'Frequency (Hz)';
h.YLabel = '';

h.PathNumberPlotted = 1;

% Initialize base class.
h.multipathaxes_initialize;
