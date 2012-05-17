function schema
% SCHEMA Defines properties for @excelImportdlg class.
%
%   Author(s): Rong Chen
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2004/12/26 21:36:38 $

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'ImportWizard');

%% Public properties

%% Visibility
p = schema.prop(c,'Visible','on/off');

%% Handles
p = schema.prop(c,'Handles','MATLAB array');

%% Figures
p = schema.prop(c,'Figure','MATLAB array');

%% Parent
p = schema.prop(c,'Parent','handle');

%% Listeners
p = schema.prop(c,'Listeners','MATLAB array');

%% Parameters for determine the positions of all the GUI components 
p = schema.prop(c,'DefaultPos','MATLAB array');

%% storing the size of the monitor screen 
p = schema.prop(c,'ScreenSize','MATLAB array');

%% storing the current step number 1~3 
p = schema.prop(c,'Step','double');

p = schema.prop(c, 'DestroyListener', 'handle');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';




