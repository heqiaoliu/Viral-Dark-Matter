function initialize(h)
%INITIALIZE  Initialize multipath impulse response axes object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/05/09 23:06:37 $

h.Title = 'Bandlimited impulse response';
h.Tag = 'Impulse response';
h.XLabel = 'Delay (s)';
h.YLabel = 'Magnitude';

% Initialize base class.
% This calls reset method, which is overridden by mpiraxes class.
h.mpanimateaxes_initialize;
