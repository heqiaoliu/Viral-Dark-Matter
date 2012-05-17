function schema
%%  SCHEMA  Defines properties for OperConditionResult class

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2008/03/13 17:40:17 $

%% Find parent package
pkg = findpackage('explorer');

%% Find parent class (superclass)
supclass = findclass(pkg, 'node');

%% Register class (subclass) in package
inpkg = findpackage('OperatingConditions');
c = schema.class(inpkg, 'OperConditionResultPanel', supclass);

%% Properties
schema.prop(c, 'OpPoint', 'MATLAB array');
schema.prop(c, 'OpReport', 'MATLAB array');
schema.prop(c, 'OperatingConditionSummary', 'MATLAB array');

schema.prop(c, 'StateIndices', 'MATLAB array');
schema.prop(c, 'InputIndices', 'MATLAB array');
schema.prop(c, 'OutputIndices', 'MATLAB array');
p = schema.prop(c, 'Version', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 0;
