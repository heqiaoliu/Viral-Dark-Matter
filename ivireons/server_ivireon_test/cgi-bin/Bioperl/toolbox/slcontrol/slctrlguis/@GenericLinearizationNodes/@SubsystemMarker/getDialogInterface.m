function DialogPanel = getDialogInterface(this, manager)
%  GETDIALOGINTERFACE  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%   Copyright 2003-2008 The MathWorks, Inc.
% $Revision: 1.1.6.18 $ $Date: 2009/03/31 00:23:04 $

% If the selected node is not a linear analysis result node don't
% bother getting the linear result node since the user has already
% selected a new node in the explorer.
frame=slctrlexplorer;
model = handle(getObject(getSelected(frame)));
if ~isa(model,'GenericLinearizationNodes.LinearAnalysisResultNode')
    % If the tree exploration for the CETM has gone past a linearization
    % result node then return the panel.
    hout = slctrlguis.linearizationpanels.getBlockExplorePanel;
    DialogPanel = hout.getPanel;
    return
end

% Get the operating point combobox element
if length(model.getChildren) == 1;
    combo_index = 1;
else
    combo_index = model.Dialog.getSelectedModelIndex;
end

% Check for corrupted DefaultListModels that did not load with the JVM 1.5
nblocks = length(this.Blocks);
if ~iscell(this.ListData)
    ListData = cell(nblocks,1);
    util = slcontrol.Utilities;
    for ct = 1:nblocks
        elementdata = uniqname(util,{this.Blocks(ct).FullBlockName},true);
        %% This method uniqname returns the data as a cell array
        ListData{ct} = elementdata{1};
    end
    this.ListData = ListData;
end

% Update the block information depending on the linearization combo box
for ct = 1:numel(this.Blocks)
    updateData(this.Blocks(ct),model.ModelJacobian(combo_index));
end

% Get the handle to the panel
hout = slctrlguis.linearizationpanels.getBlockExplorePanel(this.ListData,this.Blocks);
DialogPanel = hout.getPanel;