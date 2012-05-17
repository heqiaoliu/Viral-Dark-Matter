function schema
%  SCHEMA  Defines properties for SimulinkSISOTOOLTaskOptionsDialog class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:45:52 $

% Find parent package
pkg = findpackage('jDialogs');

% Register class (subclass) in package
c = schema.class(pkg, 'SimulinkSISOTOOLTaskOptionsDialog');

% Properties
schema.prop(c, 'JavaHandles', 'MATLAB array');
schema.prop(c, 'JavaPanel', 'MATLAB array');
schema.prop(c, 'TaskNode', 'MATLAB array');