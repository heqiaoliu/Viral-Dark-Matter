function schema
%  SCHEMA  Defines properties for LinOptionsDialog class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 19:09:25 $

% Find parent package
pkg = findpackage('jDialogs');

% Register class (subclass) in package
c = schema.class(pkg, 'ControlDesignOptionsDialog');

% Properties
schema.prop(c, 'JavaHandles', 'MATLAB array');
schema.prop(c, 'JavaPanel', 'MATLAB array');
schema.prop(c, 'TaskNode', 'MATLAB array');
schema.prop(c, 'sisodb', 'handle');
schema.prop(c, 'Design', 'MATLAB array');