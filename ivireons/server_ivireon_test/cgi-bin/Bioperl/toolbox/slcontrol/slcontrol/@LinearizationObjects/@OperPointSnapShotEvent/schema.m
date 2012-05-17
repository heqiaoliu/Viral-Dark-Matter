function schema
%SCHEMA  Defines properties for @OperPointSnapShotEvent class

% Author(s): John Glass
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 14:03:25 $

%% Find the package
pkg = findpackage('LinearizationObjects');

% Find parent class (superclass)
supclass = findclass(pkg, 'TimeEvent');

% Register class
c = schema.class(pkg, 'OperPointSnapShotEvent', supclass);

%% Public attributes
schema.prop(c, 'EmptyOpCond', 'MATLAB array');