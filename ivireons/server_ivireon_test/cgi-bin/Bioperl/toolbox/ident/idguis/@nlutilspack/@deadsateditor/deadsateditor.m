function this = deadsateditor(isInput,isSat,Index,Panel)
% deadzone/saturation editor constructor
% isInput: TRUE if nonlinearity is at an input channel
% isSat: TRUE if nonlinearity is saturation
% Index: index of the input (output) channel where this nonlinearity exists
% Panel: handle to the GUI's NLHWPANEL.


% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/06/07 14:42:06 $

this = nlutilspack.deadsateditor;
this.Parameters.isInput = isInput;
this.isSat = isSat;

this.Panel = Panel;
nlgui = nlutilspack.getNLBBGUIInstance;
this.Handles.Owner = nlgui.jGuiFrame; %Panel.jMainPanel.getParent;

% initialization
this.isTwo = true;
this.isUp = true;

%{
this.Parameters.Index = Index;
if isInput
    nlobj = Panel.NlhwModel.InputNonlinearity(Index);
else
    nlobj = Panel.NlhwModel.OutputNonlinearity(Index);
end
if isSat
    LI = nlobj.LinearInterval;
else
    LI = nlobj.ZeroInterval;
end
this.Parameters.low = LI(1);
this.Parameters.up = LI(2);
%}


this.createLayout;
this.attachListeners;
this.refresh( isInput, Index );
