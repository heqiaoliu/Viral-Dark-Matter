function schema
%%  SCHEMA  Defines properties for LinearizationOperConditionValuePanel class

%%  Author(s): John Glass
%%  Revised:
%   Copyright 1986-2005 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2005/11/15 01:45:14 $

%% Find parent package
pkg = findpackage('OperatingConditions');

%% Find parent class (superclass)
supclass = findclass(pkg, 'OperConditionValuePanel');

%% Register class (subclass) in package
inpkg = findpackage('OperatingConditions');
c = schema.class(inpkg, 'LinearizationOperConditionValuePanel', supclass);