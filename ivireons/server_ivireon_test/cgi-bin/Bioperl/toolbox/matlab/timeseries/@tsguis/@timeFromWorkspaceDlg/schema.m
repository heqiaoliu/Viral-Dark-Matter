function schema
% Defines properties for @timeFromWorkspaceDlg class.
%
%   Author(s): Rong Chen
%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
p = findpackage('tsguis');

% Register class 
c = schema.class(p,'timeFromWorkspaceDlg');

% Public properties
schema.prop(c,'Figure','MATLAB array');
schema.prop(c,'Handles','MATLAB array');
schema.prop(c,'Parent','MATLAB array');
schema.prop(c,'OutputValue','MATLAB array');
schema.prop(c,'OutputValueFormat','MATLAB array');
schema.prop(c,'OutputString','MATLAB array');

p = schema.prop(c,'Visible','on/off');
p.FactoryValue = 'off';

schema.prop(c,'Listeners','MATLAB array');
schema.prop(c,'TargetListeners','MATLAB array');





