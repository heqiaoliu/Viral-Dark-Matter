function schema
%  SCHEMA  Defines properties for SISODesignConfiguration class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 19:05:01 $

% Find parent package
pkg = findpackage('explorer');

% Find parent class (superclass)
supclass = findclass(pkg, 'tasknode');

% Register class (subclass) in package
inpkg = findpackage('ControlDesignNodes');
c = schema.class(inpkg, 'SISODesignConfiguration', supclass);

% Properties
% Simulink Control Design Task Object object
schema.prop(c, 'SimulinkControlDesignTask', 'MATLAB array');

% SISOTool Database
p = schema.prop(c, 'sisodb', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

% Structure containing extra information about the blocks being tuned
schema.prop(c, 'ValidBlockStruct', 'MATLAB array');

% Closed loop IO that are being used in the design
schema.prop(c, 'ClosedLoopIO', 'MATLAB array');

% Store the options specified in the Simulink Control Design task
schema.prop(c, 'SCDTaskOptions', 'MATLAB array');

% Store the options specified in this specific task
p = schema.prop(c, 'TaskOptions', 'MATLAB array');
p.FactoryValue = struct('UseFullPrecision',true,'CustomPrecision','10');

% Store the flag whether the autoupdate is checked
p = schema.prop(c, 'AutoUpdateEnabled', 'on/off');
p.FactoryValue = 'off';

% Listener to loopdata to automatically update the parameters of the
% tunedblocks
p = schema.prop(c, 'AutoUpdateListener', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

% Store of SISOTOOL Data
p = schema.prop(c, 'SaveData', 'MATLAB array');

% Dirty Listeners
p = schema.prop(c, 'DirtyListener', 'MATLAB array');
p.AccessFlags.Serialize = 'off';