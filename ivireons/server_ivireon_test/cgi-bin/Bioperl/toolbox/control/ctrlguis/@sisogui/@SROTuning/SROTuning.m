function h = SROTuning(Parent)
% Constructor

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/12/27 20:34:24 $

% Create class instance
h = sisogui.SROTuning;
% Populate properties
h.Parent = Parent;
h.Name = 'SRO';
h.Desc = xlate('Optimization Based Tuning');
h.MessageDialogTitle = xlate('Optimization Based Tuning');

% build all the panels
h.buildPanel;
% add visibility listener
h.addVisibilityListener;