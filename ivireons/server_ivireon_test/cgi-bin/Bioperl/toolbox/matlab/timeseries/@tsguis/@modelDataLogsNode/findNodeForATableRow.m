function node = findNodeForATableRow(this,Table,selRow)
%return the node corresponding to a selected row "selRow" in
%"Table".
% For parent node, this method should return a data node
% (class: simulinkTsNode).


%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/06/27 22:58:06 $

node = [];

%Get name of the chosen timeseries
tsname = Table.getValueAt(selRow,0);


%myModelNode = myModelNode.toString;

blkpathhtm = Table.getModel.getValueAt(selRow,2);
potential_nodes = this.find('Label',tsname,'-depth',1);
if isempty(potential_nodes)
    disp(sprintf('No object with name %s was located. No action taken.',tsname))
    return
else
    for n = 1:length(potential_nodes)
        pn = potential_nodes(n);
        if isa(pn,'tsguis.simulinkTsNode')
            thisblkpathstr = this.getBlockPathString(pn.Timeseries.BlockPath);
            flg = strcmp(blkpathhtm,thisblkpathstr);
        else
            % model node was found.

            % Note:
            % Since a deep copy og logged data doesn't work, you can
            % copy/extract only those simulink timeseries and tsarray
            % objects. But exporting may still work. The caller of this
            % method should work around (if necessary) this limitation.
            % See G265742.
            try
                % Workaround: Block Path for *log objects, such as
                % SubsysDataLogs, is not available yet. Assuming unique
                % names of immediate "container" children (should be true),
                % this should not be an issue.

                thisblkpathstr = this.getBlockPathString(pn.SimModelhandle.BlockPath);
                flg = strcmp(blkpathhtm,thisblkpathstr);
            catch
                flg = true;
            end
        end
        if flg
            %found the right node (there can be only one)
            node = pn;
            break;
        end
    end
end