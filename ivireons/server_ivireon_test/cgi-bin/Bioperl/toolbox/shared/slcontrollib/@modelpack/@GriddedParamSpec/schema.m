function schema
% SCHEMA Defines class properties

% Author(s): A. Stothert
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:37:18 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'UncertainSpec');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'GriddedParamSpec', hDeriveFromClass);

% ----------------------------------------------------------------------------



 
