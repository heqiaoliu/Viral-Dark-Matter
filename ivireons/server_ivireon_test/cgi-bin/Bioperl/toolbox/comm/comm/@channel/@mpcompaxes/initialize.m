function initialize(h)
%INITIALIZE  Initialize multipath components axes object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/05/09 23:06:29 $

h.Title = 'Multipath fading components';
h.Tag = 'Multipath components';
h.XLabel = '';
h.YLabel = 'Components (dB)';

% Initialize base class.
h.mpanimateaxes_initialize;
