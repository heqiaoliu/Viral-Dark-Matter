function update(h,varargin)

% Copyright 2004-2005 The MathWorks, Inc.
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;
import javax.swing.*;

%% Find the time series in the hostnode
if isempty(h.ViewNode) || ~ishandle(h.ViewNode)
    return % All views deleted
end

%% If the viewNode has just been created there will not yet be a timePlot.
%% In this case open an empty table
tsList = h.ViewNode.getTimeSeries;
isSelected = true(size(tsList));
tsNames = cell(size(tsList));
tsPath = cell(size(tsList));
tableData = cell(size(h.Handles.tsTable.getModel.getData));

%% Preserve de-selected time series in the table    
for k=1:length(tsList)
    tsPath{k} = constructNodePath(h.ViewNode.getRoot.find('Timeseries',tsList{k}));
    tsNames{k} = tsList{k}.Name; 
    if size(tableData,2)==3 && size(tableData,1)>0 && ...
            (nargin==1 || isempty(varargin{1}))
        I = find(strcmp(tsPath{k},tableData(:,3)));
        if ~isempty(I)
            isSelected(k) = tableData{I(1),1};
        end
    elseif nargin>=2 && ~isempty(varargin{1}) % Single specified timeseries selects by a @tsnode
        isSelected(k) = (varargin{1}==tsList{k});
    end
end

tableData = [num2cell(isSelected(:)) tsNames(:) tsPath(:)];
% Set the resample time vector units to match the time plot
ind = find(strcmpi(h.ViewNode.getPlotTimeProp('TimeUnits'),...
    get(h.Handles.COMBunits,'String')));
if ~isempty(ind)
    set(h.Handles.COMBunits,'Value',ind(1));
end


%% Rebuild the table and refresh the dialog so that the state of the
%% components reflects the selected time series
h.Handles.tsTable.getModel.setDataVector(tableData,...
    {' ',xlate('Time series'),xlate('Path')},...
    h.Handles.tsTable);
h.refresh
