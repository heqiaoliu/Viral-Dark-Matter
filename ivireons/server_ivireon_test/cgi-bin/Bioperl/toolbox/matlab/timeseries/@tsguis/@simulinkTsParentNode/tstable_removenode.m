function tstable_removenode(h,Node)
%Callback to a single node (timeseries or logs obj) being deleted from the
%Simulink Time Series Parent node.
% Node: handle to the node that is being deleted. 

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2008/12/29 02:11:31 $

import javax.swing.*;
import com.mathworks.toolbox.timeseries.*

if isempty(h.Handles) || isempty(h.Handles.PNLTsOuter) || ...
        ~ishghandle(h.Handles.PNLTsOuter) 
    return % No panel
end

if ~isfield(h.Handles,'SimTable') || isempty(h.Handles.SimTable) ||...
        ~ishandle(h.Handles.SimTable)
    h.tstable; %create table afresh
    return
end

if isa(Node,'tsguis.simulinkTsNode')
    % an unpacked timeseries node has been deleted
     awtinvoke(h.Handles.SimTable,'removeRowFromTable(Ljava/lang/String;)',...
        java.lang.String(Node.Label));
else
     awtinvoke(h.Handles.SimTable,'removeTable(Ljava/lang/String;)',...
        java.lang.String(Node.Label));
end
h.Handles.ModelTables = h.Handles.SimTable.getTables.toArray;      