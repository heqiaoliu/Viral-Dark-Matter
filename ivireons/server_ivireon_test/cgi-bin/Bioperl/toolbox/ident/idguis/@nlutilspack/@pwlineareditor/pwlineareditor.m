function this = pwlineareditor(isInput,Index,Panel)
% pwlineareditor constructor
% isInput: TRUE if nonlinearity is at an input channel
% Index: index of the input (output) channel where this nonlinearity exists
% Panel: handle to the GUI's NLHWPANEL.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/06/07 14:42:16 $

this = nlutilspack.pwlineareditor;
this.Parameters.isInput = isInput;

this.Parameters.Panel = Panel;

nlgui = nlutilspack.getNLBBGUIInstance;
this.Handles.Owner = nlgui.jGuiFrame; %Panel.jMainPanel.getParent;

%{
this.Parameters.Index = Index;
if isInput
    nlobj = Panel.NlhwModel.InputNonlinearity(Index);
else
    nlobj = Panel.NlhwModel.OutputNonlinearity(Index);
end
BP = nlobj.BreakPoints;
if size(BP,1)==1
    this.Parameters.x = BP;
elseif size(BP,1)==2
    this.Parameters.x = BP(1,:);
    this.Parameters.y = BP(2,:);
end
this.NumUnits = nlobj.NumberOfUnits;
%}

this.createLayout;
this.attachListeners;
this.refresh(isInput, Index);
