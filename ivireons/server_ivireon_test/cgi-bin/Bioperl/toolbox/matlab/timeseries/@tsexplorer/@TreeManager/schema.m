function schema
% SCHEMA Defines properties for @TreeManager class

% Copyright 2004-2008 The MathWorks, Inc.


%% Get handles of associated packages and classes
hCreateInPackage = findpackage('tsexplorer');

%% Construct class
c = schema.class( hCreateInPackage, 'TreeManager' );

%% Properties
%% Root node of the tree managed by this class
p = schema.prop(c, 'Root', 'handle');
set(p, 'AccessFlags.PublicSet', 'on');

%% Component handles
schema.prop(c, 'Tree', 'MATLAB array');
schema.prop(c, 'Treepanel', 'MATLAB array');

%% Dialog posistions
schema.prop(c, 'DialogPosition', 'MATLAB array');
schema.prop(c, 'HelpDialogPosition', 'MATLAB array');

%% Context menu
schema.prop(c, 'Cmenulistener', 'MATLAB array');

%% Handle of Figure frame
p = schema.prop(c, 'Figure', 'MATLAB array');
set(p, 'AccessFlags.PublicSet', 'on', ...
       'AccessFlags.Serialize', 'off');

%% Handle of Java Tree Explorer panel
schema.prop(c, 'Panel', 'MATLAB array');
schema.prop(c, 'HelpPanel', 'MATLAB array');
p = schema.prop(c, 'HelpShowing', 'on/off');
p.FactoryValue = 'on';
schema.prop(c, 'HelpListener', 'MATLAB array');

%% Partition panel
schema.prop(c, 'Margin', 'MATLAB array');

%% Partition panel drag images
schema.prop(c, 'DragMargin', 'MATLAB array');

%% Structure for storing node specific Java handles.
p = schema.prop(c, 'Handles', 'MATLAB array');
set(p, 'AccessFlags.PublicSet', 'off', ...
       'AccessFlags.Serialize', 'off');

%% Handles of permanent listeners.
p = schema.prop(c, 'ListenersData', 'MATLAB array'); % ListenerManager Class
p = schema.prop(c, 'Listeners', 'MATLAB array');
p.GetFunction = @LocalGetListenersValue;
set(p, 'AccessFlags.PublicSet', 'off',...
    'AccessFlags.PrivateSet', 'off','AccessFlags.Serialize','off');


%% Mapping from node classes to help panels
schema.prop(c,'NodeHelpPanelCache','MATLAB array');

%% Menu/toolvar button handles
schema.prop(c,'Menus','MATLAB array');
schema.prop(c,'ToolbarButtons','MATLAB array');

%% Visibility
schema.prop(c, 'Visible', 'on/off');

%% Minimum sizes
p = schema.prop(c,'Minwidth','MATLAB array');
p.FactoryValue = 80;
p = schema.prop(c,'Minheight','MATLAB array');
p.FactoryValue = 40;
p = schema.prop(c,'Minmarginwidth','MATLAB array');
p.FactoryValue = 25;


function StoredValue = LocalGetListenersValue(this,StoredValue)
if isempty(this.ListenersData)
    this.ListenersData = controllibutils.ListenerManager;
end
StoredValue = this.ListenersData;


