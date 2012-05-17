function schema
%Defines properties for the children dialogs.
%
%   class for timeseries export dialog, which includes: 
%       Visiblity
%       Handles array
%       Figures array
%       Listener
%       Screensize
%
%   Author(s): Rong Chen
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2004/12/26 21:36:52 $

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'allExportdlg');

%% Public properties

%% Visibility
p = schema.prop(c,'Visible','on/off');

%% Handles
p = schema.prop(c,'Handles','MATLAB array');

%% Figures
p = schema.prop(c,'Figure','MATLAB array');

%% Listeners
p = schema.prop(c,'Listeners','MATLAB array');

%% storing the size of the monitor screen 
p = schema.prop(c,'ScreenSize','MATLAB array');
p.AccessFlags.PublicSet = 'off';




