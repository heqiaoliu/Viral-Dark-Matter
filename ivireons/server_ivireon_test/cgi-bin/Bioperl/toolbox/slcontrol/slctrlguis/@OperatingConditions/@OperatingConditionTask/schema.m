function schema
%%  SCHEMA  Defines properties for OperatingConditionTask class

%   Author(s): John Glass
%   Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.13 $ $Date: 2008/12/04 23:27:41 $

%% Find parent package
pkg = findpackage('explorer');

%% Find parent class (superclass)
supclass = findclass(pkg, 'tasknode');

%% Register class (subclass) in package
inpkg = findpackage('OperatingConditions');
c = schema.class(inpkg, 'OperatingConditionTask', supclass);

%% Properties
schema.prop(c, 'StateIndices', 'MATLAB array');
schema.prop(c, 'InputIndices', 'MATLAB array');
schema.prop(c, 'OutputIndices', 'MATLAB array');

schema.prop(c,'Model', 'string');
schema.prop(c,'OpSpecData', 'MATLAB array');
schema.prop(c,'StateOrderList', 'MATLAB array');
p = schema.prop(c,'EnableStateOrdering', 'MATLAB array');
p.FactoryValue = false;
schema.prop(c,'Options','MATLAB array');
schema.prop(c,'OptimChars','MATLAB array');
schema.prop(c,'StoreDiagnosticsInspectorInfo','MATLAB array');

%% Table data
schema.prop(c, 'StateSpecTableData', 'MATLAB array');
schema.prop(c, 'InputSpecTableData', 'MATLAB array');
schema.prop(c, 'OutputSpecTableData', 'MATLAB array');
schema.prop(c, 'SimulationTimesData', 'MATLAB array');
schema.prop(c, 'StatusAreaText', 'MATLAB array');

%% Versioning
p = schema.prop(c, 'Version', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 0;

%% Events
schema.event(c,'OpPointDataChanged');
schema.event(c,'LinearizationIOChanged'); 
