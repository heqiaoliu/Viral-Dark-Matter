function tstable_addnode(h,Node)
%Callback to a single node (timeseries or logs obj) being added to the
%Simulink Time Series Parent node.
%Node: new node added

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2008/12/29 02:11:29 $

import javax.swing.*;
import com.mathworks.toolbox.timeseries.*

if isempty(h.Handles) || isempty(h.Handles.PNLTsOuter) || ...
        ~ishghandle(h.Handles.PNLTsOuter)
    return % No panel
end
if ~isfield(h.Handles,'SimTable') || isempty(h.Handles.SimTable) ||...
        ~ishandle(h.Handles.SimTable) || h.Handles.ModelTables.length==0 || ...
        isempty(char(h.Handles.ModelTables(end).getModel.TableModelNameTag)) %this last one checks if the slate is there, but blank
    h.tstable; %create table afresh
    return
end
nodepath = '';

%refresh ModelTables
h.Handles.ModelTables = h.Handles.SimTable.getTables.toArray;

if isa(Node,'tsguis.simulinkTsNode')
    % add a row to the unpacked timeseries table
    tinfo = Node.Timeseries.TimeInfo;
    time_str = sprintf('%0.3g - %0.3g %s',tinfo.Start, tinfo.End,tinfo.Units);
    blk_path = Node.Timeseries.BlockPath;
    str = h.getBlockPathString(blk_path);
%     J = javaArray('java.lang.String',3); 
%     J(1) = java.lang.String(Node.Label);
%     J(2) = java.lang.String(time_str);
%     J(3) = java.lang.String(str);
    Row = {Node.Label,time_str,str};
    % check if "Unpacked Time Series table exists)
    if ~isempty(h.Handles.ModelTables) && ...
            strcmp(h.Handles.ModelTables(end).getModel.TableModelNameTag,h.constructNodePath)
        % new timeseries row will be added to the existing "unpacked time
        % series" table
        k = 0;
        %awtinvoke(h.Handles.SimTable,'addRowToTable',J);
        h.Handles.SimTable.addRowToTable(Row);
        %disp(k)
    else
        % a new table called "unpacked time series" for the added
        % timeseries will be created
        k = length(h.Handles.ModelTables)+1;
        %awtinvoke(h.Handles.SimTable,'addRowToTable',J);
        h.Handles.SimTable.addRowToTable(Row);
        h.Handles.ModelTables = h.Handles.SimTable.getTables.toArray;
        %disp(k)
    end    

    %k = h.Handles.SimTable.addRowToTable(Row);
    nodepath = h.constructNodePath;
    % if k>0, a new table for "unpacked time series" was created.
else
    %add a new table for the SimModelhandle in Node
    Name = Node.Label;
    nodepath = Node.constructNodePath;
    [simTsArray,dataNames] = tstoolUnpack(Node.SimModelhandle);
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
        str = h.getBlockPathString(blk_path);
        tableData(ii,:) = {dataNames{ii},time_str,str};
    end

    if ~isempty(tableData)
        S = javaArray('java.lang.String',1,3);
        for kk = 1:size(tableData,1)
            for n = 1:3
                S(kk,n) = java.lang.String(tableData{kk,n});
            end
        end

        % insert new table
        k = length(h.Handles.ModelTables);
        %h.Handles.SimTable.addTable(Name, tableData);
        awtinvoke(h.Handles.SimTable,'addTable',java.lang.String(Name),S);
        drawnow
        h.Handles.ModelTables = h.Handles.SimTable.getTables.toArray;
        %k = h.Handles.SimTable.addTable(Name, tableData);
        %k = k+1; % index of new table location converted from java indexing (base 0) to MATLAB (base 1).
        
        %if last table is for unpacked ts, then insert the new table right
        %above it. So the location indicator "k" would not be incremented.
        if isempty(h.Handles.ModelTables) || ...
                ~strcmp(h.Handles.ModelTables(end).getModel.TableModelNameTag,...
                h.constructNodePath)
            k = k+1; 
        end
    else
        k = 0;
    end
end

if k>0
    thisModel = h.Handles.ModelTables(k).getModel;
    thisModel.TableModelNameTag = nodepath;

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
