function tscollectionMembersTable(h,varargin)
%% Method which builds/populates the tscollection table on the viewcontainer
%% panel

%   Author(s): Rajiv Singh
%   Copyright 2005-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.7 $ $Date: 2008/12/29 02:11:48 $

import javax.swing.*;
import com.mathworks.toolbox.timeseries.*;
import com.mathworks.mwswing.*;

if isempty(h.Handles) || isempty(h.Handles.PNLTsOuter) || ...
        ~ishghandle(h.Handles.PNLTsOuter)
    return % No panel
end

%% Get the valid nodes - if necessary excluding the node being deleted
% valid nodes type(s): @tsnode
tsnodes = h.getChildren;
if nargin>=2 && ~isempty(varargin{1})
    tsnodes = setdiff(tsnodes,varargin{1});
end

tableData = cell([length(tsnodes),3]);
for k=1:length(tsnodes)
    thisnode = tsnodes(k);
    ts = thisnode.Timeseries; %%%%%%
    Name = ts.Name;
    if ts.isTimeFirst
        DataCols = size(ts.Data,2);
    else
        DataCols = size(ts.Data,1);
    end
    DataUnits = ts.DataInfo.Units;
    if isempty(DataUnits)
        DataUnits = '-';
    end
    tableData(k,:) = {Name, DataCols, DataUnits};
end

headings = {xlate('Name'),xlate('Data Cols'),xlate('Data Units')};
if ~isfield(h.Handles,'membersTable') || isempty(h.Handles.membersTable)   
    % Parent figure passed as the first argument until uitables can
    % be parented directly to uipanels
    h.Handles.tableModel = tsMatlabCallbackTableModel(tableData,headings,[],[]);
    h.Handles.tableModel.setEditable(false);
    drawnow
    h.Handles.membersTable = javaObjectEDT('com.mathworks.mwswing.MJTable',...
        h.Handles.tableModel);
    h.Handles.membersTable.setName('tscollectionnode:memberstable');
    javaMethod('setAutoResizeMode',h.Handles.membersTable,...
        JTable.AUTO_RESIZE_ALL_COLUMNS);
    javaMethod('setSelectionMode',h.Handles.membersTable,...
        ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
    javaMethod('setCellSelectionEnabled',h.Handles.membersTable,false);
    javaMethod('setRowSelectionAllowed',h.Handles.membersTable,true);
    sPanel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',...
        h.Handles.membersTable);
    [junk, h.Handles.membersTableContainer] = ...
       javacomponent(sPanel,[0 0 1 1],ancestor(h.Handles.pnlMembers,'figure'));
    set(h.Handles.membersTableContainer,'Units','Characters','parent',h.Handles.pnlMembers);
    h.setHTMTableColumn(h.Handles.membersTable,1,1);
else
    javaMethod('setDataVector',h.Handles.membersTable.getModel,tableData,...
        headings,h.Handles.membersTable);
end
