function initialize(h)
%INITIALIZE  Initialize multipath phasor trajectory axes object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/05/09 23:06:39 $

h.Title = 'Narrowband phasor trajectory';
h.Tag = 'Phasor Trajectory';
h.XLabel = 'Re';
h.YLabel = 'Im';

% Initialize base class.
h.mpanimateaxes_initialize;
