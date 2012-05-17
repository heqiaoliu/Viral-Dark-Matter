function addGeneralMenuToolbarListeners(node,menubar,toolbar,manager)
% ADDGENERALMENUTOOLBARLISTENERS  Add generic menus and toolbars to CETM
% node menu/toolbar items
%
 
% Author(s): John W. Glass 11-Oct-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/11/09 16:35:51 $

% New Project Menu
h1 = handle( menubar.getMenuItem('project'), 'callbackproperties' );
h2 = handle( toolbar.getToolbarButton('project'), 'callbackproperties' );
node.addListeners(handle.listener([h1;h2], 'actionPerformed', {@(es,ed) LocalNewProject()}));

% New Task Menu
h1 = handle( menubar.getMenuItem('task'), 'callbackproperties' );
h2 = handle( toolbar.getToolbarButton('task'), 'callbackproperties' );
node.addListeners(handle.listener([h1;h2], 'actionPerformed', {@(es,ed) LocalNewTask(node)}));

% Load Menu
h1 = handle( menubar.getMenuItem('load'), 'callbackproperties' );
h2 = handle( toolbar.getToolbarButton('load'), 'callbackproperties' );
node.addListeners(handle.listener([h1;h2], 'actionPerformed', {@(es,ed) LocalLoad(node,manager)}));

% Save Menu and toolbar
h1 = handle( menubar.getMenuItem('save'), 'callbackproperties' );
h2 = handle( toolbar.getToolbarButton('save'), 'callbackproperties' );
node.addListeners(handle.listener([h1;h2], 'actionPerformed', {@(es,ed) LocalSave(node,manager)}));

% Close Menu
h = handle( menubar.getMenuItem('close'), 'callbackproperties' );
node.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) LocalClose(manager)}));

% About Help Menu
h = handle( menubar.getMenuItem('about'), 'callbackproperties' );
node.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) LocalAboutSCD(manager)}));

% Simulink Control Design Help
h = handle( menubar.getMenuItem('scdhelp'), 'callbackproperties' );
node.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) scdguihelp('scd_product_page','HelpBrowser')}));

% Demos Menu
h = handle( menubar.getMenuItem('demos'), 'callbackproperties' );
node.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) LocalSCDDemos()}));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalNewTask
function LocalNewTask(node)

% Create the new task dialog and let it handle the rest
newdlg = explorer.NewTaskDialog(node.up);
javaMethodEDT('setVisible',newdlg.Dialog,true);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalNewProject
function LocalNewProject()

% Create the new project dialog and let it handle the rest
[FRAME,WSHANDLE] = slctrlexplorer;
newdlg = explorer.NewProjectDialog(WSHANDLE);
javaMethodEDT('setVisible',newdlg.Dialog,true);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalLoad
function LocalLoad(node, manager)
manager.loadfrom(node.up);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalSave
function LocalSave(node, manager)
manager.saveas(node.up)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalClose
function LocalClose(manager)
manager.Explorer.doClose;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalAboutSCD
function LocalAboutSCD(manager)

LinAnalysisTask.aboutSCD(manager.Explorer)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalSCDDemos
function LocalSCDDemos()

demo('simulink','Simulink Control Design')