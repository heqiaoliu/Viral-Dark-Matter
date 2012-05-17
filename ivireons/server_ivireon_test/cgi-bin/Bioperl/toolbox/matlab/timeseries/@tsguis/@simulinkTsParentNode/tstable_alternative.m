function tstable_alternative(h,varargin)
%Render tables of all Simulink data objects in the GUI. 

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2008/12/29 02:11:30 $


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

%% Assemble the container tables by traversing each node child (one table
%% for each)
leafNodes = handle([]); Names = {}; Data = {};
for k = 1:length(simnodes)
    thisnode = simnodes(k);
    if thisnode.AllowsChildren %this is a model (not Simulink.Timeseries) node
        Names{end+1} = thisnode.Label;
        [simTsArray,dataNames] = tstoolUnpack(thisnode.SimModelhandle);
        tableData = cell(0,3);
        for ii = 1:length(simTsArray)
            thisTs = simTsArray{ii};
            tinfo = thisTs.TimeInfo;
            time_str = sprintf('%0.3g - %0.3g %s',tinfo.Start, tinfo.End,tinfo.Units);
            blk_path = thisTs.BlockPath;
            str = sprintf('<font size=3><a href="dynamicHiliteSystem(''%s'')">%s</font></a>',...
                blk_path,blk_path);
            %str = sprintf('"<html>%s</html>"',blk_path);
            tableData(ii,:) = {dataNames{ii},time_str,str};
        end
        if ~isempty(tableData)
            Data{end+1} = tableData;
        end
    else 
        leafNodes(end+1) = thisnode; %explicitly imported Ts
    end
end

% add a table for explicitly imported Simulink timeseries data 
if ~isempty(leafNodes)
    tableData = cell([length(leafNodes),3]);
    for k=1:length(leafNodes)
        thisleafnode = leafNodes(k);
        %thisleafClass = class(thisleafnode);
        tinfo = thisleafnode.Timeseries.TimeInfo;
        time_str = sprintf('%0.3g - %0.3g %s',tinfo.Start, tinfo.End,tinfo.Units);
        blk_path = thisleafnode.Timeseries.BlockPath;
        str = sprintf('<font size=3><a href="dynamicHiliteSystem(''%s'')">%s</font></a>',...
                blk_path,blk_path);
        tableData(k,:) = {thisleafnode.Label,time_str,str};
    end
    Names{end+1} = 'Explicitly imported Time Series data';
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

H = SimTsTablePanel(Names,DataArray);
[simTables, h.Handles.PNLModelTables] = javacomponent(H,[0 0 1 1],...
    ancestor(h.Handles.PNLTsOuter,'figure'));
set(h.Handles.PNLModelTables,'parent',h.Handles.PNLTsOuter);
h.Handles.ModelTables = H.getTables.toArray;

