function schema
% SCHEMA Defines class properties

% Author(s): A. Stothert
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:40:43 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'STPortID');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'STLinearizationID', hDeriveFromClass);

% ----------------------------------------------------------------------------
p = schema.prop(c, 'isOpenLoop', 'bool');
p.FactoryValue           = false;
p.AccessFlags.PublicSet  = 'off';
p.AccessFlags.PublicGet  = 'on';
p.AccessFlags.PrivateSet = 'off';



