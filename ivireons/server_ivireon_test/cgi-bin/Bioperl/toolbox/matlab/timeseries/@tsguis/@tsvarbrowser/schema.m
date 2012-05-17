% Register class (subclass)

% Copyright 2005-2006 The MathWorks, Inc.

p = findpackage('tsguis');
c = schema.class(p, 'tsvarbrowser');

% Table model
schema.prop(c,'Model','MATLAB array');
% Path and file name. Empty will be inerpreted as workspace
schema.prop(c, 'filename','string');
% Structure array containing displayed information on variables
schema.prop(c, 'variables','MATLAB array');
% Cell array to filter the data types to be displayed (empty => no filter)
schema.prop(c, 'typesallowed','MATLAB array');
% ImportView Java handle
schema.prop(c, 'javahandle','MATLAB array');
% List selection mode
schema.prop(c, 'ListSelectionMode','MATLAB array');

% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'on', 'AccessFlags.PublicSet', 'on');
