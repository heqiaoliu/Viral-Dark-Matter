function cm = getcontextmenu_enabled(h)
%GETCONTEXTMENU_ENABLED returns structure indicating which context menu
%actions are enabled
%
%   Author : V.Srinivasan
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/13 17:57:25 $

cm.VIEW_AUTOSCALEINFO = 'On';
cm.VIEW_TSINFIGURE = 'Off';
cm.VIEW_HISTINFIGURE = 'Off';
cm.VIEW_DIFFINFIGURE = 'Off';
cm.HILITE_BLOCK = 'Off';
cm.HILITE_CONNECTED_BLOCKS = 'On';
if ~isempty(h.DTGroup)
    cm.HILITE_DTGROUP = 'On';
else
    cm.HILITE_DTGROUP = 'Off';
end
cm.HILITE_CLEAR = 'On';
if h.isvalid
    cm.OPEN_BLOCKDIALOG = 'On';
else
    cm.OPEN_BLOCKDIALOG = 'Off';
end
cm.OPEN_SIGNALDIALOG = 'Off';

