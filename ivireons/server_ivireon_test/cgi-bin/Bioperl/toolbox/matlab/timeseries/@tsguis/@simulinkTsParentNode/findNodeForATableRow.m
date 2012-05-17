function node = findNodeForATableRow(this,Table,selRow)
%return a cell array of nodes corresponding to a selected row "selRow" in
%"Table".
% For parent node, this method should return a unique (single) data node
% (class: simulinkTsNode).

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/06/27 22:59:44 $

node = [];

%Get name of the chosen timeseries
tsname = Table.getValueAt(selRow,0);

%determine the name of the model by looking up the "tag" of the
%corresponding table
modelName = Table.getModel.TableModelNameTag;
myModelNode = this.search(char(modelName));

%myModelNode = myModelNode.toString;
if ~isempty(myModelNode)
    blkpathhtm = Table.getModel.getValueAt(selRow,2);
    potential_nodes = myModelNode.find('Label',tsname,'-depth',inf);
    if isempty(potential_nodes)
        disp(sprintf('No object with name %s was located. No action taken.',tsname))
        return
    else
        for n = 1:length(potential_nodes)
            pn = potential_nodes(n);
            if isa(pn,'tsguis.simulinkTsNode')
                thisblkpathstr = this.getBlockPathString(pn.Timeseries.BlockPath);
                if strcmp(thisblkpathstr,blkpathhtm)
                    %found the node for timeseries to be copied
                    node = pn;
                    break;
                end
            end
        end
    end
else
    return
end

%Note:
%Alternative search method:
%{
c = this.getRoot.TSPathCache;
S = strfind(c,char(thisTable.getModel.TableModelNameTag));
S1 = c(~cellfun('isempty',S));
r = regexp(S1,['/',tsName,'$']);
this.search(S1{3});
%}
