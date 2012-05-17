function h = IMCTuning(LoopData,Parent,PrecisionFormat,Preference)
% Constructor

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/12/27 20:34:02 $

% Create class instance
h = sisogui.IMCTuning;
% Populate properties
h.MessageDialogTitle = xlate('Automated Tuning: Internal Model Controller');
h.LoopData = LoopData;
h.Parent = Parent;
h.PrecisionFormat = PrecisionFormat;
h.Preference = Preference;
h.Name = 'IMC';
h.Desc = xlate('Internal Model Control (IMC) Tuning');
h.IsConfigChanged = false;
h.IsOpenLoopPlantDirty = false;
% build all the panels
h.buildPanel;
% update compensator list
h.utSyncCompList;    
% Add listeners
h.addListeners;

