function schema
%  SCHEMA  Defines properties for SISODesignTask class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:38:05 $

% Find parent package
pkg = findpackage('explorer');

% Find parent class (superclass)
supclass = findclass(pkg, 'projectnode');

% Register class (subclass) in package
inpkg = findpackage('controlnodes');
c = schema.class(inpkg, 'SISODesignTask', supclass);

% Properties
schema.prop(c, 'Model', 'string');

% SISOTool Database
p = schema.prop(c, 'sisodb', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

% Data used to load sisotool database
schema.prop(c, 'SaveData', 'MATLAB array');

% Dirty Listeners
p = schema.prop(c, 'DirtyListener', 'MATLAB array');
p.AccessFlags.Serialize = 'off';