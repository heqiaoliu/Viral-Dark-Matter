function initialize(h)
%INITIALIZE  Initialize multipath impulse response axes object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/05/09 23:06:35 $

h.Title = 'Frequency response';
h.Tag = 'Frequency response';
h.XLabel = 'Frequency (Hz)';
h.YLabel = 'Magnitude (dB)';

% Initialize base class.
h.mpanimateaxes_initialize;
