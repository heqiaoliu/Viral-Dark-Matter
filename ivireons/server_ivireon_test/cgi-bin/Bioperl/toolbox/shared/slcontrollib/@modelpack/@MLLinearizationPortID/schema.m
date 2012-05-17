function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:37:26 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass1  = findclass(hDeriveFromPackage, 'MLPortID');
% Should also implement LinearizationIO class methods.  But multiple
% inheritance is not supported in UDD.
hDeriveFromClass2  = findclass(hDeriveFromPackage, 'LinearizationIO');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'MLLinearizationPortID', hDeriveFromClass1);

% ----------------------------------------------------------------------------
