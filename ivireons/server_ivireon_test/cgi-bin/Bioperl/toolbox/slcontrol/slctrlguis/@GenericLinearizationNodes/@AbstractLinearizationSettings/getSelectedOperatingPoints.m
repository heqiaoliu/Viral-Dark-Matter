function op_nodes = getSelectedOperatingPoints(this) 
% GETSELECTEDOPERATINGPOINTS  Get the selected operating points.
%
 
% Author(s): John W. Glass 15-Aug-2006
%   Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2008/12/04 23:27:02 $

% Get the settings node and its dialog interface
Dialog = this.Dialog;

% Get the selected rows for the operating point
if ~isempty(Dialog)
    indices = Dialog.OpCondPanel.getOpCondSelectPanel.OpCondTable.getSelectedRows + 1;
else
    indices = 1;
end

% Error out if the user has not selected an operating condition
if ((isempty(indices)) || (~any(indices))) 
    ctrlMsgUtils.error('Slcontrol:linutil:NoOperatingPointSelected')
end

% Get the handle to the operating conditions object
OpCondNode = getOpCondNode(this);

% Get the selected operating point nodes
OpNodes = OpCondNode.getChildren;
OpNodes = OpNodes(indices);

% Get the selected operating points
for ct = numel(indices):-1:1
    % Update the linoptions
    try
        op = EvalOperPointForms(OpNodes(ct));
    catch OperpointSearchException
        if strcmp(OperpointSearchException.identifier,'SLControllib:opcond:OperatingPointNeedsUpdate')
            if isa(OpNodes(ct),'OperatingConditions.OperConditionValuePanel')
                ctrlMsgUtils.error('Slcontrol:linutil:OperatingValueNeedToClickSyncModelButton',this.Model,OpNodes(ct).Label)
            elseif isa(OpNodes(ct),'OperatingConditions.OperConditionResultPanel')
                ctrlMsgUtils.error('Slcontrol:linutil:OperatingResultOutOfSync',this.Model,OpNodes(ct).Label)
            end
        else
            throwAsCaller(OperpointSearchException)
        end
    end
    
    % Create the operating point nodes
    if isa(OpNodes(ct),'OperatingConditions.OperConditionValuePanel')
        % Create the new operating conditions node
        node = OperatingConditions.LinearizationOperConditionValuePanel(op,OpNodes(ct).Label);        
    else
        % Create the new operating conditions node
        node = OperatingConditions.OperConditionResultPanel(OpNodes(ct).Label);

        % Store the linearization operating condition results and settings
        node.OpPoint = op;
        node.OpReport = copy(OpNodes(ct).OpReport);

        % Store the operating condition constraints if we are trimming
        if isa(OpCondNode,'OperatingConditions.OperConditionResultPanel')
            node.OpConstrData = OpNodes(ct).OpConstrData;
            node.OperatingConditionSummary(ct) = OpNodes.OperatingConditionSummary;
        end
    end
    node.Editable = 0;
    op_nodes(ct) = node; %#ok<AGROW>
end
