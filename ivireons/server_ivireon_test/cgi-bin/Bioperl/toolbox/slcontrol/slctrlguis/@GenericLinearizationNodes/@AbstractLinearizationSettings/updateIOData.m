function updateIOData(this,EventData)
% UPDATEIODATA Update the IO Data object given a set of event data.
%
 
% Author(s): John W. Glass 05-Mar-2007
%   Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/06/13 15:31:15 $

% Get the selected node and walk up to see if the user is in the specific
% linearization task
FRAME = slctrlexplorer;
SelectedNode = handle(getObject(FRAME.getSelected));
taskselected = true;
while (SelectedNode ~= this)
    SelectedNode = SelectedNode.up;
    if isa(SelectedNode,'explorer.Project')
        taskselected = false;
    end
end

% Look for normal mode model references
[normalblks,normalrefs] = getNormalModeBlocks(slcontrol.Utilities,this.Model);
models = [this.Model;normalrefs];

if any(strcmp(models,EventData.Data.Model)) && taskselected
    this.SyncSimulinkIO;
    % Set the table data for the linearization ios
    updateIOTables(this);
end
