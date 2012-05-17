function schema
%SCHEMA  Defines properties for @ComputeLoopSnapShotEvent class

%  Author(s): John Glass
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/10/31 07:33:55 $

%% Find the package
pkg = findpackage('LinearizationObjects');

% Find parent class (superclass)
supclass = findclass(pkg, 'OperPointSnapShotEvent');

% Register class
c = schema.class(pkg, 'ComputeLoopSnapShotEvent', supclass);

%% Public attributes
schema.prop(c, 'linopts', 'MATLAB array');
schema.prop(c, 'TunedBlocks', 'MATLAB array');
schema.prop(c, 'IOSettings', 'MATLAB array');