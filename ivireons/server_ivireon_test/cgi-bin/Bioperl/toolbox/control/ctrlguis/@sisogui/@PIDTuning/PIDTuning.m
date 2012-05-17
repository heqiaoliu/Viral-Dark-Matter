function h = PIDTuning(LoopData,Parent,PrecisionFormat,Preference)
% Constructor

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2010/03/08 21:28:07 $

% Create class instance
h = sisogui.PIDTuning;
% Populate properties
h.LoopData = LoopData;
h.Parent = Parent;
h.PrecisionFormat = PrecisionFormat;
h.Preference = Preference;
h.Name = 'PID';
h.Desc = ctrlMsgUtils.message('Control:compDesignTask:strDesignMethodPID');
h.IsConfigChanged = false;
h.IsOpenLoopPlantDirty = false;
% PID types
h.ControllerTypesRRT = {'p','i','pi','pd','pid','pdf','pidf'};
h.ControllerTypesRule = {'p','pi','pid','pidf'};
% methods
Methods = [ {'fastdesign',ctrlMsgUtils.message('Control:compDesignTask:strPIDTuningMethod1')};...
            {'rule',ctrlMsgUtils.message('Control:compDesignTask:strPIDTuningMethod2')}];
h.TuningMethods = cell2struct(Methods,{'Name','Desc'},2);
% formula
h.Formula = {'amigocl','amigool','chr','simc','zncl','znol'};
% title
h.MessageDialogTitle = ctrlMsgUtils.message('Control:compDesignTask:strPIDMessageDialogTitle');
% build all the panels
h.buildPanel;
% update compensator list
h.utSyncCompList;    
% Add listeners
h.addListeners;
% Add deletion listener
h.DeleteListener = handle.listener(h,'ObjectBeingDestroyed',{@LocalBeingDeleted, h});

function LocalBeingDeleted(~,~,h)
delete(h.DesignObjRRT);
