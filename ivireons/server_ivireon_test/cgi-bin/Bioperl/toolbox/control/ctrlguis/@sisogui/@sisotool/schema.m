function schema
%SCHEMA  Schema for SISO Tool GUI database.

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.7.4.2 $ $Date: 2008/12/29 01:47:15 $

% Register class 
c = schema.class(findpackage('sisogui'),'sisotool');

% Define public properties
schema.prop(c,'Figure','MATLAB array');               % Handle of host figure
schema.prop(c,'DesignTask','handle');           % SISODesignTask object
schema.prop(c,'RespDialog','handle');           % Response configuration dialog
schema.prop(c,'EventManager','handle');         % Event coordinator (@framemgr object)
schema.prop(c,'Preferences','handle');          % Tool-wide preferences
schema.prop(c,'ResponseOptimization','handle'); % Response optimization dialog

schema.prop(c,'LoopData','handle');             % Model database
schema.prop(c,'AnalysisView','handle');         % LTI Viewer handle
p = schema.prop(c,'DataViews','MATLAB array');  % Data views 
p.FactoryValue = struct(...
   'Dynamics', [],...   % closed-loop poles
   'Systems', []);      % system view
schema.prop(c,'PlotEditors','handle vector');   % Graphical editor handles
schema.prop(c,'TextEditors','handle vector');   % Text editor handles

schema.prop(c,'SISOTaskNode','MATLAB array');   % Node for explorer

% Define private properties 
p = schema.prop(c,'GlobalMode','string');        % Global edit mode
p.FactoryValue = 'off';
p = schema.prop(c,'HG','MATLAB array');          % HG objects (struct)
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'Listeners','handle vector');  % Listeners
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'EditorListeners','handle vector');  % Listeners to graphical editor properties
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'SISOTaskNode','MATLAB array');   % Node for explorer
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
