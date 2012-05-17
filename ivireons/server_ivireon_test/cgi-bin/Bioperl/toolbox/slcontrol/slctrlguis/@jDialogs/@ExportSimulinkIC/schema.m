function schema
%  SCHEMA  Defines properties for ExportSimulinkIC class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/04/18 22:19:33 $

% Find parent package
pkg = findpackage('jDialogs');

% Register class (subclass) in package
c = schema.class(pkg, 'ExportSimulinkIC');

% Properties
schema.prop(c, 'Handles', 'MATLAB array');
schema.prop(c, 'Model', 'MATLAB array');
schema.prop(c, 'OperatingPoint', 'MATLAB array');
