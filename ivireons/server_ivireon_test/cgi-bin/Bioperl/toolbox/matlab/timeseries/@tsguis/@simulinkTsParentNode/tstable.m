function tstable(h,varargin)
%Render tables of all Simulink data objects in the GUI.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2008/12/29 02:11:28 $


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

%% Note:
%if nargin<3 % no special instructions on updating an existing table
%Note: "special instructions" might never be needed; there is a separate
%path for updating time info through updatePanel methods, using
%"tstable_timevectorupdate". Similarly, adding a node is handled by
%tstable_addnode, deletion by tstable_removenode and renaming by
%tstable_renamenode methods.

%% Initialize
if isfield(h.Handles,'PNLModelTables') && ~isempty(h.Handles.PNLModelTables)
    Pos_PNLModelTables = get(h.Handles.PNLModelTables,'pos');
    delete(h.Handles.PNLModelTables)
    %delete(h.Handles.ModelTables)
else
    Pos_PNLModelTables = [0 0 1 1];
end

%% Assemble the container tables by traversing each node child (one table
%% for each): start from scratch
leafNodes = handle([]); Names = {}; Data = {}; nodepath = {};
for k = 1:length(simnodes)
    thisnode = simnodes(k);
    if thisnode.AllowsChildren %this is a model (not Simulink.Timeseries) node
        Names{end+1} = thisnode.Label;
        nodepath{end+1} = thisnode.constructNodePath; %one for each table
        [simTsArray,dataNames] = tstoolUnpack(thisnode.SimModelhandle);
        tableData = cell(0,3);
        for ii = 1:length(simTsArray)
            thisTs = simTsArray{ii};
            tinfo = thisTs.TimeInfo;
            if isnan(tinfo.Increment)
                samplingBehav = 'non-uniform';
            else
                samplingBehav = 'uniform';
            end
            time_str = sprintf('%0.3g - %0.3g %s (%s)',tinfo.Start,...
                tinfo.End,tinfo.Units, xlate(samplingBehav));
            blk_path = thisTs.BlockPath;
            %str = sprintf('<font size=3><a href="dynamicHiliteSystem(''%s'')">%s</font></a>',blk_path,blk_path);
            %str = sprintf('"<html>%s</html>"',blk_path);
            str = h.getBlockPathString(blk_path);
            tableData(ii,:) = {dataNames{ii},time_str,str};
        end
        if ~isempty(tableData)
            Data{end+1} = tableData;
        end
    else
        leafNodes(end+1) = thisnode; %explicitly imported Ts
    end
end

%% Add a table for explicitly imported (unpacked) Simulink Timeseries
if ~isempty(leafNodes)
    tableData = cell([length(leafNodes),3]);
    nodepath{end+1} = h.constructNodePath;
    for k=1:length(leafNodes)
        thisleafnode = leafNodes(k);
        %thisleafClass = class(thisleafnode);
        tinfo = thisleafnode.Timeseries.TimeInfo;
        time_str = sprintf('%0.3g - %0.3g %s',tinfo.Start, tinfo.End,tinfo.Units);
        blk_path = thisleafnode.Timeseries.BlockPath;
        str = h.getBlockPathString(blk_path);
        tableData(k,:) = {thisleafnode.Label,time_str,str};
    end
    Names{end+1} = xlate('Unpacked Time Series');
    Data{end+1} = tableData;
end

if ~isempty(Names)
    DataArray = javaArray('java.lang.Object',length(Names));
    for r = 1:length(Data)
        S = javaArray('java.lang.String',size(Data{r},1),3);
        for k = 1:size(Data{r},1)
            for n=1:3
                S(k,n) = java.lang.String(Data{r}{k,n});
            end
        end
        DataArray(r) = S;
    end
else
    Names = {''};
    DataArray =  javaArray('java.lang.Object',1);
end

%% Now create and render the tables
jNames = javaArray('java.lang.String',length(Names));
for k=1:length(Names)
    jNames(k) = java.lang.String(Names{k});
end
h.Handles.SimTable = awtcreate('com.mathworks.toolbox.timeseries.SimTsTablePanel',...
    '[Ljava/lang/String;[Ljava/lang/Object;',jNames,DataArray);
%h.Handles.SimTable = SimTsTablePanel(Names,DataArray);
[simTables, h.Handles.PNLModelTables] = javacomponent(h.Handles.SimTable,[0 0 1 1],...
    ancestor(h.Handles.PNLTsOuter,'figure'));
set(h.Handles.PNLModelTables,'parent',h.Handles.PNLTsOuter,'Units','Characters');
set(h.Handles.PNLModelTables,'pos',Pos_PNLModelTables);
h.Handles.ModelTables = h.Handles.SimTable.getTables.toArray;
%h.Handles.SimTsTable = H;

%     % set the tag for the "explicitly imported data" table
%     if ~isempty(leafnodesTscell)
%         explicitTableModel = h.Handles.ModelTables(end).getModel;
%         explicitTableModel.TableModelNameTag='explicit';
%     end

%% Post processing: Attach Model Name tags and mouse motion listeners to
%% each table.
for k = 1:length(nodepath)
    thisModel = h.Handles.ModelTables(k).getModel;
    thisModel.TableModelNameTag = nodepath{k};

    %set the mouse motion and clicked callbacks
    Hnd = handle(h.Handles.ModelTables(k),'callbackproperties');

    htmMouseListener = htmMouseListener(h.Handles.ModelTables(k),2);
    awtinvoke(h.Handles.ModelTables(k),'addMouseMotionListener',...
        htmMouseListener);
    Hnd.MouseClickedCallback = {@localMouseClicked,h.Handles.ModelTables,k,h};
end

%--------------------------------------------------------------------------
function localMouseClicked(es,ed,tables,Ind,h)
%Highlight the simulink block from the block-path, if the user clicks on the
%hyperlink.
% Also, deselect all selection from all other tables in the panel.
%   tables is a java array of all the tables.
%   Ind is the index of the table who row was selected.

% es: table (javahandle_withcallbacks.com.mathworks.mwswing.MJTable)
% ed: mouse event
% h: @simulinkTsparentNode handle

h.mouseClickedActions(tables,Ind,ed);
