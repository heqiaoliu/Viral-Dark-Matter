function tstable(h,varargin)

%   Copyright 2005-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.9 $ $Date: 2008/12/29 02:11:52 $

import javax.swing.*;
import com.mathworks.toolbox.timeseries.*;
import com.mathworks.mwswing.*;

%% Method which builds/populates the timeseries table on the viewcontainer panel

if isempty(h.Handles) || isempty(h.Handles.PNLTs) || ...
        ~ishghandle(h.Handles.PNLTs)
    return % No panel
end


%% Get the valid nodes - if necessary excluding the node being deleted
% valid nodes could be @tsnode or @tscollection node
tsnodes = h.getChildren;
if nargin>=2 && ~isempty(varargin{1})
    tsnodes = setdiff(tsnodes,varargin{1});
end

%% Assemble the timeseries table data by traversing each member timeseries
tableData = cell([length(tsnodes),4]);
for k=1:length(tsnodes)
    thisnode = tsnodes(k);
    %thisClass = class(thisnode);
    if isa(thisnode,'tsguis.tsnode')
        tinfo = thisnode.Timeseries.TimeInfo;  
        %addedInfo = '';
        thistype = 'Timeseries';
    elseif isa(thisnode,'tsguis.tscollectionNode')
        tinfo = thisnode.Tscollection.TimeInfo;
        addedInfo = sprintf('%d members',length(gettimeseriesnames(thisnode.Tscollection)));
        thistype = sprintf('Tscollection (%s)',addedInfo);
    else
        error('tsparentnode:tstable:invNode',...
            'Unknown node %s found. Please provide details for it to render information properly.',thisClass);
    end
    if isempty(tinfo)
        thisDesc = '';
    elseif isnan(tinfo.Increment)
        thisDesc = sprintf('Non uniformly sampled');
    else
        thisDesc = sprintf('Uniformly sampled with Increment = %0.3g',tinfo.Increment);
    end
    if isempty(tinfo)
        time_str = '';
    else
        time_str = sprintf('%0.3g - %0.3g %s',tinfo.Start, tinfo.End,tinfo.Units);
    end
        
    tableData(k,:) = {thisnode.Label,thistype,time_str,thisDesc};
end
    
%% Populate the table - if necessary creating it
headings = {xlate('Name'),xlate('Type'),xlate('Time Vector'),xlate('Description')};
if ~isfield(h.Handles,'tsTable') || isempty(h.Handles.tsTable)  
    % Parent figure passed as the first argument until uitables can
    % be parented directly to uipanels
    h.Handles.tableModel = tsMatlabCallbackTableModel(tableData,headings,[],[]);
    h.Handles.tableModel.setEditable(false);
    drawnow
    h.Handles.tsTable = javaObjectEDT('com.mathworks.mwswing.MJTable',...
        h.Handles.tableModel);
    h.Handles.tsTable.setName('tstable:parentts');
    javaMethod('setSelectionMode',h.Handles.tsTable,...
        ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
    javaMethod('setCellSelectionEnabled',h.Handles.tsTable,false);
    javaMethod('setRowSelectionAllowed',h.Handles.tsTable,true);   
    javaMethod('setAutoResizeMode',h.Handles.tsTable,...
        MJTable.AUTO_RESIZE_ALL_COLUMNS);   
    sPanel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',h.Handles.tsTable);
    [junk, h.Handles.PNLtsTable] = ...
        javacomponent(sPanel,[0 0 0.95 1],ancestor(h.Handles.PNLTs,'figure')); %#ok<NASGU>
else
    drawnow %importing multiple objects (with at least one requiring name change) throws ArrayIndexOutOfBoundsException. 
    javaMethod('setDataVector',h.Handles.tableModel,...
        tableData,headings,h.Handles.tsTable);
end
