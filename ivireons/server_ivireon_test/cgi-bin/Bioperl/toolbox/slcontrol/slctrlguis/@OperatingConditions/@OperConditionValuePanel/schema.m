function schema
%%  SCHEMA  Defines properties for OperConditionValuePanel class

%%  Author(s): John Glass
%%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
%	$Revision: 1.1.6.10 $  $Date: 2008/03/13 17:40:21 $

%% Find parent package
pkg = findpackage('explorer');

%% Find parent class (superclass)
supclass = findclass(pkg, 'node');

%% Register class (subclass) in package
inpkg = findpackage('OperatingConditions');
c = schema.class(inpkg, 'OperConditionValuePanel', supclass);

%% Properties
schema.prop(c, 'Model', 'string');
schema.prop(c, 'OpPoint', 'MATLAB array');
schema.prop(c, 'StateIndices', 'MATLAB array');
schema.prop(c, 'StateTableData', 'MATLAB array');
schema.prop(c, 'InputIndices', 'MATLAB array');
schema.prop(c, 'InputTableData', 'MATLAB array');
p = schema.prop(c, 'Version', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 0;
