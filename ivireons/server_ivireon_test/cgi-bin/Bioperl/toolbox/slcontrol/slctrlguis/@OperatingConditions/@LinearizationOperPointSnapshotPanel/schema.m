function schema
%%  SCHEMA  Defines properties for LinearizationOperPointSnapshotPanel class

%   Author(s): John Glass
%   Revised:
%   Copyright 1986-2005 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2006/11/17 14:04:32 $

%% Find parent package
pkg = findpackage('OperatingConditions');

%% Find parent class (superclass)
supclass = findclass(pkg, 'OperConditionValuePanel');

%% Register class (subclass) in package
inpkg = findpackage('OperatingConditions');
c = schema.class(inpkg, 'LinearizationOperPointSnapshotPanel', supclass);