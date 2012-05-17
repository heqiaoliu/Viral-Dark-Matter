function schema
%SCHEMA  Defines properties for @BlockExploreSubsystemMarker class

%  Author(s): John Glass
%  Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/06/07 14:52:50 $

% Find parent package
pkg = findpackage('explorer');

% Find parent class (superclass)
supclass = findclass(pkg, 'tasknode');

% Register class (subclass) in package
inpkg = findpackage('ControlDesignNodes');
c = schema.class(inpkg, 'BlockExploreSubsystemMarker', supclass);

%%% User storable description of the state object
schema.prop(c, 'Name', 'string');             % User description
schema.prop(c, 'Blocks', 'MATLAB array');
schema.prop(c, 'ListData', 'MATLAB array');
p = schema.prop(c, 'TableListener', 'MATLAB array');
p.AccessFlags.Serialize = 'off';     
schema.prop(c, 'UnappliedSelectedElements', 'MATLAB array');
