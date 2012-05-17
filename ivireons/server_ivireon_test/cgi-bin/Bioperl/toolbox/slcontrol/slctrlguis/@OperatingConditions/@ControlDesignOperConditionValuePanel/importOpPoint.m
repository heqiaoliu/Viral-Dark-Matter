function importOpPoint(this) 
% IMPORTOPPOINT  Import a new operating point into the task
%
 
% Author(s): John W. Glass 21-Aug-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/31 07:36:15 $

% Get the workspace
[Explorer,Workspace]=slctrlexplorer;

% Throw up a question dialog explaining the implication of importing a new
% operating point.
msg = sprintf(['By selecting a new operating point your model will be analyzed to ',...
       'compute the open and closed-loop responses that have been configured. ',...
       'Continue?']);
   
pane = com.mathworks.mwswing.MJOptionPane.showConfirmDialog(Explorer,msg,...
    xlate('Import New Operating Point'),com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);

% If pane == 0 then the user has selected yes, else return.
if pane == 0
    % Get the valid projects to import from
    openprojects = Workspace.getChildren;
    ind = openprojects == this.getRoot.up;
    openprojects(ind) = [];

    names = get(openprojects,'Model');
    indvalid = strcmp(names,this.Model);
    pvalid = openprojects(indvalid);
   
    % Create the dialog and show it
    dlg = jDialogs.OpcondImport(this.OpPoint,pvalid,Explorer);
    
    % Specify the import function 
    dlg.importfcn = {@ImportOperPointData,this,dlg};
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ImportOperPointData - Callback to import an operating point to the GUI
function ImportOperPointData(this,dlg)

% Get the operating point from the dialog
[op, names] = getSelectedOperatingPoints(dlg);
if ~isempty(op)
    try
        sisotask = this.getRoot;
        sisotask.updateDesign(op);
    catch Ex
        if strcmp(Ex.identifier,'slcontrollib:operpoint:NeedsUpdate')
            errmsg = ctrlMsgUtils.message('Slcontrol:operpointtask:OperSpecOutOfSyncInstruct',this.Model);
        else
            errmsg = ltipack.utStripErrorHeader(Ex.message);
        end
        errordlg(errmsg,xlate('Simulink Control Design'))
        return
    end
    this.OpPoint = op;
    % Set the dirty flag
    this.getRoot.setDirty

    % Refresh the tables
    % Get the state and input table data
    [this.StateTableData,this.StateIndices] = this.getStateTableData;
    [this.InputTableData,this.InputIndices] = this.getInputTableData;
    refreshTables(this);
    
    % Update the summary table
    this.SourceOpPointDescription = sprintf('of the operating point - <B>%s</B>',names{1}); 
    this.updateSummary(this.Dialog);
end



