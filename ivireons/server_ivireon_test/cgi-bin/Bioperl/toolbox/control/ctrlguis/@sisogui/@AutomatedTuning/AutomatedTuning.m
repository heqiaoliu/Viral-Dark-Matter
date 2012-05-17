function h = AutomatedTuning(LoopData,Parent)
%AUTOMATEDTUNING  Constructor
%
% Tuning methods that are currently available
% --------------------------------------------
%   name        description
% --------------------------------------------
%   SRO         Optimization based tuning
%   PID         PID tuning
%   IMC         Internal Model Control (IMC) tuning
%   LQG         LQG synthesis
%   LoopSyn     LoopSyn design
% --------------------------------------------

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/11/17 13:24:42 $

% Create class instance
h = sisogui.AutomatedTuning;
% Populate properties
h.Parent = Parent;
PrecisionFormat = '%0.5g';
Preference = Parent.Preferences;
% Add automated tuning methods (sub-classes of @AutomatedTuningPanel)
h.MethodManagers = [...
    sisogui.SROTuning(h);
    sisogui.PIDTuning(LoopData, h, PrecisionFormat, Preference);
    sisogui.IMCTuning(LoopData, h, PrecisionFormat, Preference);
    sisogui.LQGTuning(LoopData, h, PrecisionFormat, Preference);
    sisogui.LoopsynTuning(LoopData, h, PrecisionFormat, Preference);
    ];
% Build the panel 
h.buildPanel;
% Initialize the selection
h.IdxMethod = 1;



