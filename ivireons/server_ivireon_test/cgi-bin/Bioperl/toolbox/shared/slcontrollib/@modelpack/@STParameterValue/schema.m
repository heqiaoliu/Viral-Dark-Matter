function schema
% SCHEMA Defines class properties

% Author(s): A. Stothert
% Revised:
% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/05/18 05:52:41 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'ParameterValue');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'STParameterValue', hDeriveFromClass);

% ----------------------------------------------------------------------------
p = schema.prop(c, 'Format', 'double');
p.FactoryValue = 1;
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.PublicGet = 'on';


