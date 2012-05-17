function schema
%SCHEMA
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/20 20:29:09 $

% Register class (subclass)
c = schema.class(findpackage('preprocessgui'), 'preprocess');

% Public attributes

% Data objects
schema.prop(c, 'Datasets', 'MATLAB array');
schema.prop(c, 'Newdatasets', 'handle');
schema.prop(c, 'ManExcludedpts', 'MATLAB array');

% Preprocessing rule objects
schema.prop(c, 'Exclusion', 'handle');
schema.prop(c, 'Filtering', 'handle');
schema.prop(c, 'Interp', 'handle');

% GUI state
schema.prop(c, 'TargetNode', 'string');
p = schema.prop(c, 'Column', 'double');
p.FactoryValue = 1;
p = schema.prop(c, 'Position', 'double');
p.FactoryValue = 0;
schema.prop(c, 'Window', 'MATLAB array');
p = schema.prop(c, 'Visible', 'on/off');
p.FactoryValue = 'on';

% Graphical objects
schema.prop(c, 'Lines', 'MATLAB array');
schema.prop(c, 'Controls', 'MATLAB array');
schema.prop(c, 'Handles', 'MATLAB array');
schema.prop(c, 'javaframe', 'com.mathworks.toolbox.control.preprocess.Preprocess');

% Listeners
p = schema.prop(c, 'Listeners', 'MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';