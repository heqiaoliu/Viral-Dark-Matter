function tstable(h,varargin)
%Render a table for the ModelDataLogs object.
%It contains a list of immediate children of the ModelDataLogs. These could
%be of the type: Simulink.Timeseries, Simulink.TsArray, SubsysDataLogs,
%StateflowDataLogs.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2008/12/29 02:11:17 $

import javax.swing.*;
import com.mathworks.toolbox.timeseries.*

%% Method which builds/populates the timeseries table on the viewcontainer panel

if isempty(h.Handles) || isempty(h.Handles.PNLTsOuter) || ...
        ~ishghandle(h.Handles.PNLTsOuter)
    return % No panel
end

%% Get the valid nodes - if necessary excluding the node being deleted
% valid nodes could be @tsnode or @tscollection node
simnodes = h.getChildren;
if nargin>=2 && ~isempty(varargin{1})
    simnodes = setdiff(simnodes,varargin{1});
end

if isempty(simnodes)
    return;
end

% %quick return if table already exists, since it is read-only
% if isfield(h.Handles,'PNLModelTables') && ~isempty(h.Handles.PNLModelTables)
%     return
% end

%% Assemble the container table by traversing each node child
Name = h.Label; Data = {};
nodepath = h.constructNodePath;
% it is a cell array of cell arrays (one cell array for each table)
for k = 1:length(simnodes)
    thisnode = simnodes(k);
    if thisnode.AllowsChildren %this is a DataLogs object or a TsArray
        %tableData = cell(0,3);
        time_str = '-';
        try
            blk_path = thisnode.SimModelhandle.BlockPath;
            str = sprintf('<font size=3><a href="%s">%s</font></a>',...
                blk_path,blk_path);
        catch
            %blk_path = '' ; %unavailable (geck  260239)
            str = '-';
        end

    else % thisnode is a Timeseries data node
        tinfo = thisnode.Timeseries.TimeInfo;
        if isnan(tinfo.Increment)
            samplingBehav = 'non-uniform';
        else
            samplingBehav = 'uniform';
        end
        time_str = sprintf('%0.3g - %0.3g %s (%s)',tinfo.Start, tinfo.End,...
            tinfo.Units, xlate(samplingBehav));
        blk_path = thisnode.Timeseries.BlockPath;
        str = sprintf('<font size=3><a href="%s">%s</font></a>',...
            blk_path,blk_path);
    end
    tableData(k,:) = {thisnode.Label,time_str,str};
end

if ~isempty(tableData)
    Data = {tableData};
else
    return
end

DataArray = javaArray('java.lang.Object',1);
S = javaArray('java.lang.String',1,3);
for k = 1:size(Data{1},1)
    for n=1:3
        S(k,n) = java.lang.String(Data{1}{k,n});
    end
end
DataArray(1) = S;

%% Now create and render the tables
%jName = java.lang.String(Name);
jName = javaArray('java.lang.String',1);
jName(1) = java.lang.String(Name);
h.Handles.SimTable = awtcreate('com.mathworks.toolbox.timeseries.SimTsTablePanel',...
    '[Ljava.lang.String;[Ljava.lang.Object;',jName,DataArray);
%h.Handles.SimTable = SimTsTablePanel(Name,DataArray);

[simTables, h.Handles.PNLModelTables] = javacomponent(h.Handles.SimTable,[0 0 1 1],...
    ancestor(h.Handles.PNLTsOuter,'figure'));
%set(h.Handles.PNLModelTables,'parent',h.Handles.PNLTsOuter);
set(h.Handles.PNLModelTables,'Units','Characters','Parent',h.Handles.PNLTsOuter);
h.Handles.ModelTables = h.Handles.SimTable.getTables.toArray;
thisModel = h.Handles.ModelTables(1).getModel;
thisModel.TableModelNameTag = nodepath;


thisModel = h.Handles.ModelTables(1).getModel;

%set the mouse motion and clicked callbacks
Hnd = handle(h.Handles.ModelTables(1),'callbackproperties');

htmMouseListener = htmMouseListener(h.Handles.ModelTables(1),2);
awtinvoke(h.Handles.ModelTables(1),'addMouseMotionListener',...
    htmMouseListener);
Hnd.MouseClickedCallback = {@localMouseClicked,h.Handles.ModelTables,1,h};

%--------------------------------------------------------------------------
function localMouseClicked(es,ed,tables,Ind,h,varargin)
%Highlight the simulink block from the block-path, if the user clicks on the
%hyperlink.
% Also, deselect all selection from all other tables in the panel. 
%   tables is a java array of all the tables.
%   Ind is the index of the table who row was selected.

% es: table (javahandle_withcallbacks.com.mathworks.mwswing.MJTable)
% ed: mouse event
% h: @simulinkTsparentNode handle

h.mouseClickedActions(tables,Ind,ed);
