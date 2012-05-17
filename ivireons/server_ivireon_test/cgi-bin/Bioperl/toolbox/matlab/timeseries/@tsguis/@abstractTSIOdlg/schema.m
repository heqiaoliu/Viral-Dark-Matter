function schema
%Defines properties for the children dialogs.
%
%   Parent class for timeseries import/export dialogs, which includes: 
%       Visiblity
%       Handles array
%       Figures array
%       Abstract listeners for XXXXXX
%
%   Author(s): Rong Chen
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2004/12/26 21:36:41 $

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'abstractTSIOdlg');

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
p.AccessFlags.PublicSet = 'off';




