function schema
%SCHEMA  Defines properties for @TimeEvent class

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2010/05/20 03:26:03 $

% Find the package
pkg = findpackage('LinearizationObjects');

% Register class
c = schema.class(pkg, 'TimeEvent');

% Public attributes
schema.prop(c, 'SimulinkSnapshotBlock', 'MATLAB array');
schema.prop(c, 'ModelParameterMgr', 'MATLAB array');
schema.prop(c, 'SnapShotTimes', 'MATLAB array');
schema.prop(c, 'TopBlockHandle', 'MATLAB array');
schema.prop(c, 'IOSpec', 'MATLAB array');
