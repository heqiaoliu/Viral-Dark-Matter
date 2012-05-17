function schema
% SCHEMA  Defines properties for @signalgenerator class

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2005/12/22 17:38:52 $

% Register class 
c = schema.class(findpackage('lsimgui'), 'signalgenerator');

% Properties

% Parent siminputtable
schema.prop(c,'importtable','handle');
% Selected signal type
schema.prop(c, 'type','string');
% Array of panel structures containing the java handles
% describing the signal generator GUI frame for each type
schema.prop(c, 'panels', 'MATLAB array');
% Java handles
schema.prop(c, 'jhandles', 'MATLAB array');
% Visibility
schema.prop(c, 'Visible',    'on/off');  
% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off');

