function initialize(h)
%INITIALIZE  Initialize multipath energy axes object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/05/09 23:06:33 $

h.Title = 'Multipath gain';
h.Tag = 'Multipath gain';
h.XLabel = 'Time offset (s)';
h.YLabel = 'Gain (dB)';

% Initialize base class.
h.mpanimateaxes_initialize;
