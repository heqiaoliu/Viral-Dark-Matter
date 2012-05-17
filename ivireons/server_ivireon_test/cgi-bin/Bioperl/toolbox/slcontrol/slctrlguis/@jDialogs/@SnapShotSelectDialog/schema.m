function schema
% Defines properties for @SelectBlockDialog class

%   Authors: John Glass
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2009/05/23 08:21:51 $

% Register class (subclass) in package
inpkg = findpackage('jDialogs');
c = schema.class(inpkg, 'SnapShotSelectDialog');

% Store the listeners
schema.prop(c, 'Listeners', 'MATLAB array');
schema.prop(c, 'Handles', 'MATLAB array');
p = schema.prop(c, 'SelectedSnapshot', 'MATLAB array');
p.FactoryValue = NaN;
schema.prop(c, 'Snapshots', 'MATLAB array');
schema.prop(c, 'task', 'MATLAB array');
schema.prop(c, 'opnode', 'MATLAB array');
