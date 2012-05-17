function cm = getcontextmenu_enabled(h)
%GETCONTEXTMENU_ENABLED returns structure indicating which context menu
%actions are enabled
%
%   Author : V.Srinivasan
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/13 17:57:09 $

cm.VIEW_AUTOSCALEINFO = 'On';
cm.VIEW_TSINFIGURE = 'On';
cm.VIEW_HISTINFIGURE = 'On';
cm.VIEW_DIFFINFIGURE = 'On';
cm.HILITE_BLOCK = h.ishighliteenabled;
if ~isempty(h.DTGroup)
    cm.HILITE_DTGROUP = 'On';
else
    cm.HILITE_DTGROUP = 'Off';
end
cm.HILITE_CONNECTED_BLOCKS = 'Off';
cm.HILITE_CLEAR = 'on';
if h.isvalid
    cm.OPEN_BLOCKDIALOG = 'On';
else
    cm.OPEN_BLOCKDIALOG = 'Off';
end
if ~isempty(h.outport)
    cm.OPEN_SIGNALDIALOG = 'On';
else
    cm.OPEN_SIGNALDIALOG = 'Off';
end



