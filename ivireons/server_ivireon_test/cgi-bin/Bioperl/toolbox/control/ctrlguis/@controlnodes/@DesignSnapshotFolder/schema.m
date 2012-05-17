function schema
% SCHEMA Defines properties for @TunedBlockSnapshotFolder class

% Author(s): John Glass
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 17:38:29 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('explorer');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'node');
hCreateInPackage   = findpackage('controlnodes');

% Construct class
c = schema.class(hCreateInPackage, 'DesignSnapshotFolder', hDeriveFromClass);

p = schema.prop(c, 'ChildListListeners', 'MATLAB array');
p.AccessFlags.Serialize  = 'off';

% Events
schema.event(c,'DesignLabelChanged'); 
