function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2006/09/30 00:23:45 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'VariableID');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'PortID', hDeriveFromClass);

% ----------------------------------------------------------------------------
