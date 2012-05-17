function h = LQGTuning(LoopData,Parent,PrecisionFormat,Preference)
% Constructor

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/12/27 20:34:09 $

% Create class instance
h = sisogui.LQGTuning;
% Populate properties
h.LoopData = LoopData;
h.Parent = Parent;
h.PrecisionFormat = PrecisionFormat;
h.Preference = Preference;
h.Name = 'LQG';
h.Desc = xlate('LQG Synthesis');
h.IsConfigChanged = false;
h.IsOpenLoopPlantDirty = false;
h.MessageDialogTitle = xlate('Automated Tuning: LQG Controller');
% build all the panels
h.buildPanel;
% update compensator list
h.utSyncCompList;    
% Add listeners
h.addListeners;