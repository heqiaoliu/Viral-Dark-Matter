function extractTsToTree(this)
%extract the selected timeseries to the tree as a new node under the parent
%simulinkTsParentNode.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/06/27 22:59:43 $

thisTable = this.Handles.SelectedTable;

if isempty(thisTable)
    return
end

selectedRows = thisTable.getSelectedRows;
for k = 1:length(selectedRows)
    selRow = selectedRows(k);
    if selRow>=0
        myTsNode = this.findNodeForATableRow(thisTable,selRow);
        if isempty(myTsNode)
            return
        end
        ts = myTsNode.Timeseries.copy;
        if ~isempty(ts)
            newname = sprintf('Copy_of_%s', ts.Name);
            k = 2;
            G = this.getParentNode.getChildren;
            for n = 1:length(G)
                if isa(G(n),'tsguis.simulinkTsNode') && strcmp(newname,G(n).Label)
                    newname = sprintf('Copy_%d_of_%s',k,...
                        ts.Name);
                    k = k+1;
                end
            end
            ts.Name = newname;
            childnode = createTstoolNode(ts,this.getParentNode);
            if ~isempty(childnode)
                childnode = this.getParentNode.addNode(childnode);
            end
        end
    end
end