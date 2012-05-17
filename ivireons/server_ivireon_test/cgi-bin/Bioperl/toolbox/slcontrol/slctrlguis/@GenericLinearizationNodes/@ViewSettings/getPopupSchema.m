function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): John Glass
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2008/12/04 23:27:09 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import com.mathworks.mwswing.*;

Menu = javaObjectEDT('com.mathworks.mwswing.MJPopupMenu',sprintf('Custom View'));
item1 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',sprintf('Delete View'));

Menu.add(item1);
Handles.PopupMenuItems = item1;
h = handle(item1, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalAction, this};
h.MouseClickedCallback = {@LocalAction, this};

% --------------------------------------------------------------------------- %
function LocalAction(eventSrc, eventData, this)

% Get the parent
parent = this.up;

% Make the parent node the selected node
F = slctrlexplorer;
F.setSelected(parent.getTreeNodeInterface);

% Delete the ltiviewer if needed
if isa(this.LTIViewer,'viewgui.ltiviewer')
    close(this.LTIViewer.Figure);
end

% Remove the node
parent.removeNode(this);
