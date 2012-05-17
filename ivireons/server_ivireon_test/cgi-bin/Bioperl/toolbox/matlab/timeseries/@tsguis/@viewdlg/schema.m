function schema
% Defines properties for @mergedlg class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 23:05:04 $

%% Parent class for view dialogs. Abstracts listeners for time series
%% being added or deleted from the view and the view list being changed

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'viewdlg');

%% Public properties

%% Parent ViewNode
schema.prop(c,'Parentviewnode','handle');

%% Selected target view node
schema.prop(c,'Viewnode','handle');

%% Visibility
schema.prop(c,'Visible','on/off');

%% Handles
schema.prop(c,'Handles','MATLAB array');

%% Handles
schema.prop(c,'Figure','MATLAB array');

%% Node class - limits the scope of the dialog to the defined class
%% of nodes
p = schema.prop(c,'Nodeclass','string');
p.FactoryValue = 'tsguis.viewnode';

%% Listeners
p = schema.prop(c,'Statelisteners','MATLAB array');
p.FactoryValue = struct('ViewNodeAdded',[],'ViewNodeRemoved',[],'ViewNode',...
    [],'ParentViewNode',[],'Members',[],'Timeseries',[]);
p = schema.prop(c,'Listeners','MATLAB array');



