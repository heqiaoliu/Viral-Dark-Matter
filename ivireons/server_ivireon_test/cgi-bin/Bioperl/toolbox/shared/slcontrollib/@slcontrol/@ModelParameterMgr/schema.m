function schema
% SCHEMA Defines class properties

% Author(s): John Glass
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/08/08 01:18:25 $

% Construct class
c = schema.class(findpackage('slcontrol'), 'ModelParameterMgr');

% Class properties
schema.prop(c, 'Model', 'string');
schema.prop(c, 'NormalRefModels', 'MATLAB array');
schema.prop(c, 'NormalRefParentBlocks', 'MATLAB array');
schema.prop(c, 'EngineInterface', 'MATLAB array');
schema.prop(c, 'OrigDirty', 'MATLAB array');
schema.prop(c, 'OrigPreloaded', 'MATLAB array');
schema.prop(c, 'OrigConfigSet', 'MATLAB array');
schema.prop(c, 'OrigModelParams', 'MATLAB array');
schema.prop(c, 'OrigAutoSave', 'MATLAB array');
schema.prop(c, 'TunableParametersAdded', 'MATLAB array');
p = schema.prop(c, 'OrigLinIO','MATLAB array');
p.FactoryValue = NaN;
