function schema
% SCHEMA  Defines properties for @TimeEventStorage class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 14:03:33 $

%% Register class
pkg = findpackage('LinearizationObjects');
c = schema.class(pkg, 'TimeEventStorage');

%% Public attributes

%% Property store the object to execute the snapshot method
schema.prop(c, 'TimeEventObj', 'MATLAB array');

%% Property for the data structure
schema.prop(c, 'Data', 'MATLAB array');