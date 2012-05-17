function panel = getDialogInterface(this, manager)
% GETDIALOGINTERFACE

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.15 $ $Date: 2008/04/28 03:29:04 $

% Make sure the model and its references are open
ensureOpenModel(slcontrol.Utilities,this.Model)

if isempty(this.Dialog)
    this.Dialog = getDialogSchema(this);
else
    % Do a try catch to make sure that each block exists in the model.
    % If it does not remove it from the list.
    BlockDeletedFlag = false;
    for ct = length(this.IOData):-1:1
        try
            get_param(this.IOData(ct).Block,'Name');
        catch Ex %#ok<NASGU>
            this.IOData(ct) = [];
            BlockDeletedFlag = true;
        end
    end
    % Update the model with the settings
    setlinio(this.Model,this.IOData);
    if BlockDeletedFlag
        AnalysisIOTableModel = this.Handles.AnalysisIOTableModel;

        % Set the table data for the linearization ios
        table_data = this.getIOTableData;
        if ~isempty(table_data)
            AnalysisIOTableModel.setData(table_data);
        else
            AnalysisIOTableModel.clearRows;
        end
    end
end

panel = this.Dialog;
