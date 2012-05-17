function schema
%SCHEMA  Automated Compensator Tuning Panel parent class

%   Author(s): R. Chen
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/04/21 03:07:37 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'AutomatedCompensatorTuning',findclass(sisopack,'AutomatedTuningPanel'));

% Public Properties
schema.prop(c,'Preference','handle');                       % handle to preference
schema.prop(c,'PrecisionFormat','string');                  % default format string for sprintf
schema.prop(c,'LoopData','handle');                         % central data repository
schema.prop(c,'TunedCompList','MATLAB array');              % handles to @TunedZPK list excluding pure gain block
schema.prop(c,'TunedLoopList','MATLAB array');              % handles to @TunedLoop list excluding pure gain block
schema.prop(c,'IdxC','double');                             % index of the selected compensator
schema.prop(c,'OpenLoopPlant','MATLAB array');              % open loop model corresponding to current compensator

schema.prop(c,'IsConfigChanged','bool');            
schema.prop(c,'IsOpenLoopPlantDirty','bool');           

schema.prop(c,'CompSelectPanelHandles','MATLAB array');     % handle to CompSelectPanel objects
schema.prop(c,'SpecPanelHandles','MATLAB array');           % handle to SpecPanelHandles objects
schema.prop(c,'DesignButton','MATLAB array');               % handle to the design button
schema.prop(c,'MessagePanel','MATLAB array');               % handle to the message panel
% Private properties
p = schema.prop(c,'Listeners','handle vector'); % Listeners
set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');
