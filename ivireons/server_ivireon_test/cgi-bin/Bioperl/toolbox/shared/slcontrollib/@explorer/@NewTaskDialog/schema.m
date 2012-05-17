function schema
% SCHEMA  Class definition 

% Author(s): John Glass
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2.54.1 $ $Date: 2010/07/23 15:43:04 $

%% Get handles of associated packages and classes
pkg   = findpackage('explorer');

%% Construct class
c = schema.class(pkg, 'NewTaskDialog');

%% Define properties
schema.prop(c, 'Projects', 'MATLAB array');
schema.prop(c, 'CurrentProject', 'MATLAB array');
schema.prop(c, 'JavaHandles', 'MATLAB array');
schema.prop(c, 'Dialog', 'MATLAB array');
schema.prop(c, 'CurrentWorkspace', 'MATLAB array');
schema.prop(c, 'CreateNewProject', 'MATLAB array');

% Cell array of {task name identifier, task type key; ...}
schema.prop(c, 'TaskConfig', 'MATLAB array');
