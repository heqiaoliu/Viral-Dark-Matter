function tstable_renamenode(h,Node,oldname,newname)
%Callback to a single node (timeseries or logs obj) being added to the
%Simulink Time Series Parent node.
%Node: node renamed

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2008/12/29 02:11:32 $

import javax.swing.*;
import com.mathworks.toolbox.timeseries.*

if isempty(h.Handles) || isempty(h.Handles.PNLTsOuter) || ...
        ~ishghandle(h.Handles.PNLTsOuter)
    return % No panel
end

if isa(Node,'tsguis.simulinkTsNode')
    %locate row in the "Unpacked Time Series" table
    M = h.Handles.ModelTables(end).getModel;
    if ~strcmp(char(M.TableModelNameTag),h.constructNodePath)
        %return if "Unpacked Time Series" table is not located
        return;
    end
    for ii = 1:h.Handles.ModelTables(end).getRowCount
        thisname = M.getValueAt(ii-1,0);
        if strcmp(thisname,oldname)
            %located the timeseries for the node being renamed; now rename
            %the name in the row:
            awtinvoke(M,'setValueAt(Ljava/lang/Object;II)',...
                java.lang.String(newname),ii-1,0);
            break;
        end
    end
    
else
    %locate table
    for k = 1:length(h.Handles.ModelTables)
        if strcmp(char(h.Handles.SimTable.getTableName(k-1)),oldname)
            %located the table; now update its name:
            awtinvoke(h.Handles.SimTable,'setPageTitle(ILjava/lang/String;)',...
                k-1,java.lang.String(newname));
            break;
        end
    end
end
