function updateCurrentModel(this)
% update the current model (idnlarx or idnlhw) with the data entered by the
% user in the GUI.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:31:11 $

this.ModelTypePanel.getCurrentModelPanel.updateModelforActiveOutput;

%{
if this.StructureIndex==1
    % idnlarx model
    Ind = Panel.getCurrentOutputIndex;
    Panel.updateModelforActiveOutput;
    Panel.ActiveOutputIndex = Ind;
else
    % todo
end
%}