function schema
% Defines properties for @SelectBlockDialog class

%   Authors: John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2007/02/06 20:03:02 $

% Register class (subclass) in package
inpkg = findpackage('jDialogs');
c = schema.class(inpkg, 'SelectBlockDialog');

% Store the listeners
schema.prop(c, 'Listeners', 'MATLAB array');
schema.prop(c, 'ExplorerPanelTreeManager', 'MATLAB array');
schema.prop(c, 'Dialog', 'MATLAB array');
schema.prop(c, 'BlockInspectPanel', 'MATLAB array');
schema.prop(c, 'SplitPanel', 'MATLAB array');
schema.prop(c, 'HelpPanel', 'MATLAB array');