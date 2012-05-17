function schema
% Defines properties for @timeFromWorkspaceDlg class.
%
%   Author(s): Rong Chen
%   Copyright 1986-2005 The MathWorks, Inc.

% Register class 
p = findpackage('tsguis');

% Register class 
c = schema.class(p,'tsImportdlg');

% Public properties
schema.prop(c,'Figure','MATLAB array');
schema.prop(c,'Handles','MATLAB array');
schema.prop(c,'OutputValue','MATLAB array');
schema.prop(c,'Title','string');
schema.prop(c,'HelpFile','string');
schema.prop(c,'Typesallowed','MATLAB array');

p = schema.prop(c,'Visible','on/off');
p.FactoryValue = 'off';

schema.prop(c,'Listeners','MATLAB array');
schema.prop(c,'TargetListeners','MATLAB array');





