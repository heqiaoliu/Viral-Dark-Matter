function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:54:27 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass1  = findclass(hDeriveFromPackage, 'SLPortID');
% Should also implement LinearizationIO class methods.  But multiple
% inheritance is not supported in UDD.
hDeriveFromClass2  = findclass(hDeriveFromPackage, 'LinearizationIO');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'SLLinearizationPortID', hDeriveFromClass1);

% ----------------------------------------------------------------------------
p = schema.prop(c, 'OpenLoop', 'bool');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
