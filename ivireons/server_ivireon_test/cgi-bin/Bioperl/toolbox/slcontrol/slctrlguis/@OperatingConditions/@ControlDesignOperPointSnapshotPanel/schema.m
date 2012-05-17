function schema
%%  SCHEMA  Defines properties for ControlDesignOperPointSnapshotPanel class

%   Author(s): John Glass
%   Revised:
%   Copyright 1986-2005 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2006/11/17 14:04:28 $

%% Find parent package
pkg = findpackage('OperatingConditions');

%% Find parent class (superclass)
supclass = findclass(pkg, 'OperConditionValuePanel');

%% Register class (subclass) in package
c = schema.class(pkg, 'ControlDesignOperPointSnapshotPanel', supclass);

%% Store the loopdata object for the operating point
schema.prop(c, 'design', 'MATLAB array');