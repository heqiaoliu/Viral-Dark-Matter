function [menubar, toolbar] = getMenuToolBarSchema(this, manager)
% GETMENUTOOLBARSCHEMA Set the callbacks for the menu items and toolbar buttons.

% Author(s): John Glass, Bora Eryilmaz
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2007/02/06 20:00:26 $

% Create menubar & toolbar
menubar = manager.getMenuBar( this.getGUIResources );
toolbar = manager.getToolBar( this.getGUIResources );

% New Project Menu
h = handle( menubar.getMenuItem('project'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalNewProject, this };

% New Task Menu
h = handle( menubar.getMenuItem('task'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalNewTask, this };

% Open Menu
h = handle( menubar.getMenuItem('open'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalOpen, this, manager };

% Save Menu
h = handle( menubar.getMenuItem('save'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalSave, this, manager };

% Close Menu
h = handle( menubar.getMenuItem('close'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalClose, this, manager };

% About menu
h = handle( menubar.getMenuItem('about'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalAbout, this, manager };

% New Project Button
h = handle( toolbar.getToolbarButton('project'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalNewProject, this };

% New Task Button
h = handle( toolbar.getToolbarButton('task'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalNewTask, this };

% Open Button
h = handle( toolbar.getToolbarButton('open'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalOpen, this, manager };

% Save Button
h = handle( toolbar.getToolbarButton('save'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalSave, this, manager };

% --------------------------------------------------------------------------
%% LocalNewProject
function LocalNewProject(es,ed,this)
%% Create the new task dialog and let it handle the rest
newdlg = explorer.NewProjectDialog(this);
awtinvoke(newdlg.Dialog, 'setVisible', true)

% --------------------------------------------------------------------------
%% LocalNewTask
function LocalNewTask(es,ed,this)
%% Create the new task dialog and let it handle the rest
% Find non-MPC projects
theseChildren = setdiff(this.getChildren, ...
    [this.find('-class','mpcnodes.MPCGUI','-depth',1);...
     this.find('-class','controlnodes.SISODesignTask','-depth',1);]);
if isempty(theseChildren)
  newdlg = explorer.NewProjectDialog(this);
else
  newdlg = explorer.NewTaskDialog(this);
end
awtinvoke(newdlg.Dialog, 'setVisible', true)

% --------------------------------------------------------------------------
function LocalOpen(es, ed, this, manager)
manager.loadfrom(this.getChildren);

% --------------------------------------------------------------------------
function LocalSave(es, ed, this, manager)
manager.saveas(this.getChildren)

% --------------------------------------------------------------------------
function LocalClose(es, ed, this, manager)
manager.Explorer.doClose;

% ----------------------------------------------------------------------------- %
function LocalAbout(es,ed,this,manager)
s = struct( 'Name', 'Control and Estimation Tools Manager', ...
            'Version', '1.0', ...
            'Date', datestr(now, 1) );
message = sprintf( '%s %s\nCopyright 2002-%s, The MathWorks, Inc.', ...
                   s.Name, s.Version, s.Date(end-3:end) );

% Thread-safe message dialog.
awtinvoke( 'javax.swing.JOptionPane', ...
           'showMessageDialog(Ljava/awt/Component;Ljava/lang/Object;Ljava/lang/String;I)', ...
           manager.Explorer, message, ...
           xlate('About Control and Estimation Tools Manager'), ...
           javax.swing.JOptionPane.PLAIN_MESSAGE );
