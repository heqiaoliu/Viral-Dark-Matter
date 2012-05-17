function DialogPanel = getDialogSchema(this, manager)
% GETDIALOGSCHEMA Construct the dialog panel

% Author(s): Bora Eryilmaz, John Glass
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2007/02/06 20:00:25 $

% First create the GUI panel
DialogPanel = awtcreate( 'com.mathworks.toolbox.control.workspace.Workspace' );

% Get the handles
Handles   = this.Handles;
buttons   = DialogPanel.getButtons;
menuitems = DialogPanel.getMenuItems;

% Add the handle
Handles.PanelManager = explorer.DefaultFolderPanel(DialogPanel, this, manager);

% New button callback
h = handle( buttons(1),   'callbackproperties' );
h.ActionPerformedCallback = { @LocalNewProject, this };
h = handle( menuitems(1), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalNewProject, this };
h = handle( menuitems(4), 'callbackproperties' ); % Scroll right-click new
h.ActionPerformedCallback = { @LocalNewProject, this };

% Store the handles
this.Handles = Handles;

% ----------------------------------------------------------------------------
% Local Functions
% ----------------------------------------------------------------------------

% ----------------------------------------------------------------------------
% LocalNewProject - Callback to launch the new project dialog
function LocalNewProject(hSrc, hData, this)
% Create the new task dialog and let it handle the rest
newdlg = explorer.NewProjectDialog(this);
awtinvoke( newdlg.Dialog, 'setVisible', true )
