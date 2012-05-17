function this = poly1deditor(isInput,Index,Panel)
% poly1deditor constructor
% isInput: TRUE if nonlinearity is at an input channel
% Index: index of the input (output) channel where this nonlinearity exists
% Panel: handle to the GUI's NLHWPANEL.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/05/19 23:05:04 $

this = nlutilspack.poly1deditor;
this.Parameters.isInput = isInput;

this.Parameters.Panel = Panel;

nlgui = nlutilspack.getNLBBGUIInstance;
this.Handles.Owner = nlgui.jGuiFrame; %Panel.jMainPanel.getParent;

this.createLayout;
this.attachListeners;
this.refresh(isInput, Index);
