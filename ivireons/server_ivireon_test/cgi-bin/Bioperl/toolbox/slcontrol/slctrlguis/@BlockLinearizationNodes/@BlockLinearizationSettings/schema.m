function schema
%  SCHEMA  Defines properties for BlockLinearizationSettings class

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2008/10/31 07:35:48 $

% Find parent package
pkg = findpackage('GenericLinearizationNodes');

% Find parent class (superclass)
supclass = findclass(pkg, 'AbstractLinearizationSettings');

% Register class (subclass) in package
inpkg = findpackage('BlockLinearizationNodes');
c = schema.class(inpkg, 'BlockLinearizationSettings', supclass);

% Properties
schema.prop(c, 'Model', 'string');
schema.prop(c, 'Block', 'MATLAB array');
p = schema.prop(c, 'LTIPlotType', 'MATLAB array');
p.FactoryValue = 'step';
p = schema.prop(c, 'LTIViewer', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
