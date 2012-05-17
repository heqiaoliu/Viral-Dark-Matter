function extractTsToTree(this)
%extract the selected objects to the tree as a new node under the parent
%simulinkTsParentNode.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2005/11/27 22:42:47 $

if isempty(this.Handles.SelectedTable) && this.Handles.ModelTables.length>0
    this.Handles.SelectedTable = this.Handles.ModelTables(1);
elseif isempty(this.Handles.SelectedTable)
    return
end

thisTable = this.Handles.SelectedTable;

selectedRows = thisTable.getSelectedRows;
for k = 1:length(selectedRows)
    selRow = selectedRows(k);
    if selRow>=0
        myDataNode = this.findNodeForATableRow(thisTable,selRow);
        if isa(myDataNode,'tsguis.simulinkTsNode')
            ts = myDataNode.Timeseries.copy;
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
            end
        elseif isa(myDataNode,'tsguis.simulinkTsArrayNode')
            Mod = myDataNode.SimModelhandle.copy;
            if ~isempty(Mod)
                newname = sprintf('Copy_of_%s', Mod.Name);
                k = 2;
                G = this.getParentNode.getChildren;
                for n = 1:length(G)
                    if isa(G(n),'tsguis.simulinkTsArrayNode') && strcmp(newname,G(n).Label)
                        newname = sprintf('Copy_%d_of_%s',k,...
                            Mod.Name);
                        k = k+1;
                    end
                end
                Mod.Name = newname;
                childnode = createTstoolNode(Mod,this.getParentNode);
            end
        else
            if ~isempty(myDataNode)
                msg = xlate('Object or objects of this type cannot be extracted.'); 
                errordlg(msg,'Time Series Tools','modal')
            end
            continue;
        end
        if ~isempty(childnode)
            childnode = this.getParentNode.addNode(childnode);            
            tsViewer = this.getRoot.TsViewer;
            tsViewer.TreeManager.reset
            tsViewer.TreeManager.Tree.setSelectedNode(tsViewer.SimulinkTSnode.getTreeNodeInterface);
            drawnow % Force the node to show seelcted
            tsViewer.TreeManager.Tree.repaint
        end
    end
end