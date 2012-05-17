function schema
%  SCHEMA  Defines properties for LinearAnalysisResultNode class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.12 $ $Date: 2007/10/15 23:32:16 $

% Find parent package
pkg = findpackage('explorer');

% Find parent class (superclass)
supclass = findclass(pkg, 'node');

% Register class (subclass) in package
inpkg = findpackage('GenericLinearizationNodes');
c = schema.class(inpkg, 'LinearAnalysisResultNode', supclass);

% Properties
schema.prop(c, 'LinearizedModel', 'MATLAB array');    % LTI Object
schema.prop(c, 'Model', 'MATLAB array');    % Simulink Model
schema.prop(c, 'ModelJacobian', 'MATLAB array');    
schema.prop(c, 'IOStructure', 'MATLAB array');
schema.prop(c, 'LinearizationOptions', 'MATLAB array');
schema.prop(c, 'InspectorNode', 'MATLAB array');
schema.prop(c, 'BlocksInPathByName', 'MATLAB array');
schema.prop(c, 'DiagnosticMessages', 'MATLAB array');