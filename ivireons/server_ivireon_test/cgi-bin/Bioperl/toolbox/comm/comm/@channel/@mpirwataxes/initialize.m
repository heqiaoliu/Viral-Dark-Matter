function initialize(h);
%INITIALIZE  Initialize multipath impulse response waterfall axes object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:20:37 $

h.Title = 'Bandlimited impulse response';
h.Tag = 'Impulse response';
h.XLabel = 'Delay (s)';
h.YLabel = 'Time offset (s)';

% Initialize base class.
h.mpanimateaxes_initialize;
