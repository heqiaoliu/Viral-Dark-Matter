function h = LoopsynTuning(LoopData,Parent,PrecisionFormat,Preference)
% Constructor

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/12/27 20:34:13 $

% Create class instance
h = sisogui.LoopsynTuning;

% Populate properties
h.LoopData = LoopData;
h.Parent = Parent;
h.PrecisionFormat = PrecisionFormat;
h.Preference = Preference;
h.Name = 'Loopsyn';
h.Desc = xlate('Loop Shaping');
h.IsConfigChanged = false;
h.IsOpenLoopPlantDirty = false;
% build all the panels
h.buildPanel;
% update compensator list
h.utSyncCompList;    
% Add listeners
h.addListeners;

