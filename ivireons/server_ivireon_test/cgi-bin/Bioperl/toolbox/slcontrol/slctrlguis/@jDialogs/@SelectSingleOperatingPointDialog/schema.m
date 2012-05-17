function schema
% Defines properties for @SelectBlockDialog class

%   Authors: John Glass
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 14:04:50 $

% Register class (subclass) in package
inpkg = findpackage('jDialogs');
c = schema.class(inpkg, 'SelectSingleOperatingPointDialog');

% Store the listeners
schema.prop(c, 'Listeners', 'MATLAB array');
schema.prop(c, 'Handles', 'MATLAB array');
p = schema.prop(c, 'SelectedIndex', 'MATLAB array');
p.FactoryValue = NaN;