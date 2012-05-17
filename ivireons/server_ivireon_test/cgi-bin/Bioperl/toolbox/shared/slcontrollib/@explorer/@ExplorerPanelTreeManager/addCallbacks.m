function addCallbacks( this )
% ADDCALLBACKS Add Java related callbacks

% Author(s): Bora Eryilmaz
% Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2008/04/03 03:17:09 $

% Add event listener
h = handle( this.ExplorerPanel.getSelector, 'callbackproperties' );
h.SelectionChangedCallback = { @LocalSelectionChanged, this };
h.PopupTriggeredCallback   = { @LocalPopupTriggered, this };

% ---------------------------------------------------------------------------- %
function LocalSelectionChanged(hSrc, hData, this)

h = handle( hData.getNode.getObject );
ExplorerPanel = this.ExplorerPanel;

try
    % Get the panel
    Panel = getDialogInterface( h, this );

    % Set the panel
    ExplorerPanel.getDisplayer.setDialog( Panel );

catch Ex %#ok<NASGU>
  import javax.swing.JOptionPane;
  util = slcontrol.Utilities;
  beep;
  JOptionPane.showMessageDialog( this.Explorer, util.getLastError, ...
                                 'Tools Manager Error', ...
                                 JOptionPane.WARNING_MESSAGE );
  Panel = com.mathworks.mwswing.MJPanel;
  % Set the panel
  ExplorerPanel.getDisplayer.setDialog( Panel );
end

% ---------------------------------------------------------------------------- %
function LocalPopupTriggered(hSrc, hData, this)
h = handle( hData.getNode.getObject );
e = hData.getEvent;

popup = h.getPopupInterface( this );
Explorer = slctrlexplorer;
if ~isempty(popup) && ~Explorer.getGlassPane.isVisible
  awtinvoke( popup, 'show(Ljava/awt/Component;II)', ...
             hData.getSource, e.getX, e.getY );
  popup.repaint;
end
