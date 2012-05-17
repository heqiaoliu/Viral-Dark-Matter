function addCallbacks(this)
% ADDCALLBACKS Add Java related callbacks

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2008 The MathWorks, Inc.
% $Revision: 1.1.6.11 $ $Date: 2008/07/14 17:12:01 $

% Add event listeners
h = handle( this.Explorer, 'callbackproperties' );
h.WindowClosingCallback = { @LocalWindowClosing, this };

h = handle( this.ExplorerPanel.getSelector, 'callbackproperties' );
h.SelectionChangedCallback = { @LocalSelectionChanged, this };
h.PopupTriggeredCallback   = { @LocalPopupTriggered, this };

% ---------------------------------------------------------------------------- %
function LocalWindowClosing(hSrc, hData, this)
% Do not allow closing the Explorer when the manager is busy; for example,
% when an estimation is running.
if this.isBusy
  msg = sprintf('Application is currently busy. Please stop before exiting.');
  dlg = errordlg( msg, char(this.Explorer.getTitle), 'modal' );
  % In case the dialog is closed before uiwait blocks MATLAB.
  if ishandle(dlg)
    uiwait(dlg)
  end
  return
end

% Force the focus to the frame so that ant focusloast events are processed
% before the save and none of the focuslost callbacks will fire after nodes
% have been deleted
this.Explorer.requestFocus
drawnow

% Get the children of the workspace
children = this.Root.getChildren;
for k = 1:length(children)
  abortFlag = LocalSaveProject(this, children(k));
  if abortFlag
    return;
  end
end

% Remove all children
for k = length(children):-1:1
  this.Root.removeNode( children(k) );
end

% Clean up
drawnow
this.delete;

% ---------------------------------------------------------------------------- %
function abortFlag = LocalSaveProject(this, node)
abortFlag = false;
if node.Dirty
  message   = sprintf('Do you want to save the changes to %s?', node.Label);
  selection = questdlg(message, 'Save Project', 'Yes', 'No', 'Cancel', 'Yes');

  switch selection
  case 'Yes',
    this.saveas(node, true)
  case 'No',
    % no action
  case 'Cancel'
    abortFlag = true;
  end
end

% ---------------------------------------------------------------------------- %
function LocalPopupTriggered(hSrc, hData, this)
h = handle( hData.getNode.getObject );
e = hData.getEvent;

popup = h.getPopupInterface( this );
if ~isempty(popup) && ~this.Explorer.getGlassPane.isVisible
  awtinvoke( popup, 'show(Ljava/awt/Component;II)', ...
	     hData.getSource, e.getX, e.getY );
  popup.repaint;
end

% ---------------------------------------------------------------------------- %
function LocalSelectionChanged(hSrc, hData, this)
h = handle( hData.getNode.getObject );
ExplorerPanel = this.ExplorerPanel;
Explorer      = this.Explorer;

% Set explorer components
[menubar, toolbar] = getMenuToolBarInterface( h.getRoot, this );
Explorer.setExplorerComponents( menubar, toolbar, h.Status );

% Block all inputs (mouse & keyboard) to CETM GUI. No active component is set.
Explorer.setBlocked(true, []);

try
  % Get the panel
  Panel = getDialogInterface( h, this );
catch E
  util = slcontrol.Utilities;
  beep;

  % Thread-safe message dialog.
  awtinvoke('javax.swing.JOptionPane', ...
	    'showMessageDialog(Ljava/awt/Component;Ljava/lang/Object;Ljava/lang/String;I)', ...
	    Explorer, util.getLastError(E), ...
	    'Tools Manager Error', javax.swing.JOptionPane.WARNING_MESSAGE);
  Panel = com.mathworks.mwswing.MJPanel;
end

% Set the panel
ExplorerPanel.getDisplayer.setDialog( Panel );

% Allow all inputs (mouse & keyboard) to CETM GUI.
Explorer.setBlocked(false, []);
