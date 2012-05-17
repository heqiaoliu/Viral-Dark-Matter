function schema
%SCHEMA  Defines properties for @BlockExploreSubsystemMarker class

%  Author(s): John Glass
%  Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 19:08:19 $

% Find parent package
pkg = findpackage('explorer');

% Find parent class (superclass)
supclass = findclass(pkg, 'tasknode');

% Register class (subclass) in package
inpkg = findpackage('ControlDesignNodes');
c = schema.class(inpkg, 'SignalExploreSubsystemMarker', supclass);

%%% User storable description of the state object
schema.prop(c, 'Name', 'string');             % User description
schema.prop(c, 'Signals', 'MATLAB array');
schema.prop(c, 'ListData', 'MATLAB array');
