function schema
% Defines properties for @uitspanel subclass of uipanel.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 22:59:02 $

%% Package and class info
c = schema.class(findpackage('tsguis'),'propeditor');

%% Java handles (including MJTabbedPane for panels)
schema.prop(c,'Handles','MATLAB array');

%% Tabs structure 
schema.prop(c,'Tabs','MATLAB array');

%% @resplot host
%schema.prop(c,'Target','MATLAB array');

%% Listeners
schema.prop(c,'Listeners','MATLAB array');

%% Calendar
schema.prop(c,'Calendar','MATLAB array');


