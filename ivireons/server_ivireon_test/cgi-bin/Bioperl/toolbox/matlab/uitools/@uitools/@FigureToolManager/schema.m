function schema

% Copyright 2002-2009 The MathWorks, Inc.

pk = findpackage('uitools');
c = schema.class(pk,'FigureToolManager');

% Public 
p(1) = schema.prop(c,'CommandManager','handle');
p(2) = schema.prop(c,'Figure','MATLAB array');
schema.prop(c,'UndoUIMenu','MATLAB array');
schema.prop(c,'RedoUIMenu','MATLAB array');


% Private
private_prop(1) = schema.prop(c,'CommandManagerListeners','handle vector');
set(private_prop,'AccessFlags.PublicSet','off','AccessFlags.PublicGet','off');








