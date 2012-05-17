function schema
%SCHEMA  Schema for abstract graphical editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.12.4.4 $ $Date: 2009/04/21 03:08:14 $

% Register class 
c = schema.class(findpackage('sisogui'), 'grapheditor');

% Data.
schema.prop(c,'LoopData','handle');           % Handle to @loopdata repository
schema.prop(c,'EditedLoop','double');         % Edited Loop (index into LoopData.L)
schema.prop(c,'EditedBlock','handle');        % Edited TunedZPK 
schema.prop(c,'GainTargetBlock','handle');    % TunedZPK for modifying gain

% REVISIT: should be handle matrix
schema.prop(c,'EditedPZ','MATLAB array');     % Edited poles and zeros (@pzview objects)
schema.prop(c,'Dependency','MATLAB array');   % Tuned models this editor depends on (indices into LoopData.C)
schema.prop(c,'GainTunable','MATLAB array');  % Boolean: True if gain of loop is tunable

% Modes.  Possible mode values are
%     Enabled:      [true|false]
%     EditMode:     [{off}|idle|addpz|deletepz|zoom]
%     EditModeData: addpz --> Root   = [pole|zero]
%                             Group  = [real|complex|lead|lag|notch]
%                    zoom --> Type   = [in-x|in-y|x-y]
%     RefreshMode:  [{normal}|quick]
p = schema.prop(c,'Enabled','bool');        % Editor Enabled Flag 
set(p,'FactoryValue',true);
p = schema.prop(c,'EditMode','string');             % Edit mode 
set(p,'AccessFlags.Init','on','FactoryValue','off');     
schema.prop(c,'EditModeData','MATLAB array');       % Edit mode data & submodes
p = schema.prop(c,'RefreshMode','string');          % Refresh mode
set(p,'AccessFlags.Init','on','FactoryValue','normal');  
schema.prop(c,'Visible','on/off');                  % Editor visibility
p = schema.prop(c,'SingularLoop','bool');           % Flags singular loop 
p.AccessFlags.PublicSet = 'off';                    % allow get for qe testing

% Graphical components
schema.prop(c,'Axes','handle vector');        % Host axes (@axesgroup object)
schema.prop(c,'ConstraintEditor','handle');   % Design constraint editor (@tooldlg instance)
schema.prop(c,'EventManager','handle');       % Event coordinator (@framemgr object)
schema.prop(c,'TextEditor','handle');         % Text editor for edited model

% Style parameters
schema.prop(c,'LabelColor','MATLAB array');      % Label, ruler, and grid color
schema.prop(c,'LineStyle','MATLAB array');       % Style parameters

% Private properties
p(1) = schema.prop(c,'HG','MATLAB array');          % HG objects (struct)
p(2) = schema.prop(c,'Listeners','handle vector');  % Listeners
p(3) = schema.prop(c,'XLabelVisible','on/off');     % Visibility of X labels
p(4) = schema.prop(c,'YLabelVisible','on/off');     % Visibility of Y labels
% ATTN: Temporary fix. Revert back when properties can be changed in local
% functions within the class methods of bodeditorF 
set(p(2:4),'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');

% Event
schema.event(c,'RequirementAdded');