function schema
%  SCHEMA  Defines properties for ModelLinearizationSettings class

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.10 $ $Date: 2008/10/31 07:36:14 $

% Find parent package
pkg = findpackage('GenericLinearizationNodes');

% Find parent class (superclass)
supclass = findclass(pkg, 'AbstractLinearizationSettings');

% Register class (subclass) in package
inpkg = findpackage('ModelLinearizationNodes');
c = schema.class(inpkg, 'ModelLinearizationSettings', supclass);

% Properties
schema.prop(c, 'Model', 'string');
schema.prop(c, 'IOData', 'MATLAB array');
p = schema.prop(c, 'LTIPlotType', 'MATLAB array');
p.FactoryValue = 'step';
p = schema.prop(c, 'LTIViewer', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'IOListener','MATLAB array');
p.AccessFlags.Serialize = 'off';
