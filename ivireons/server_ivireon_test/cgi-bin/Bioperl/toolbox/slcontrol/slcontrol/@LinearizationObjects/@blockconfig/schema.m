function schema
% SCHEMA Defines class properties

% Author(s): John Glass
% Revised:
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:42:55 $

% Get handles of associated packages and classes
hCreateInPackage = findpackage('LinearizationObjects');

% Construct class
c = schema.class( hCreateInPackage, 'blockconfig' );