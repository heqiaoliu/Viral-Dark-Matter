function update(h,varargin)

% Copyright 2004-2005 The MathWorks, Inc.

import javax.swing.*; 
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;

%% Find the time series in the hostnode
if isempty(h.ViewNode) || ~ishandle(h.ViewNode)
    return % All views deleted
end

%% Get the list of timeseries in the hostnode
tsList = h.ViewNode.getTimeSeries;
isSelected = true(size(tsList));
tsNames = cell(size(tsList));
tsPath = cell(size(tsList));
tableData = cell(size(h.Handles.tsTable.getModel.getData));

%% Preserve de-selected time series in the table    
for k=1:length(tsList)
    tsPath{k} = constructNodePath(h.ViewNode.getRoot.find('Timeseries',tsList{k}));
    tsNames{k} = tsList{k}.Name; 
    if size(tableData,2)==4 && size(tableData,1)>0 && ...
            (nargin==1 || isempty(varargin{1}))
        I = find(strcmp(tsPath{k},tableData(:,3)));
        if ~isempty(I)
            isSelected(k) = tableData{I(1),1};
        end
    % Single specified timeseries selected
    elseif nargin>=2 && ~isempty(varargin{1}) 
        isSelected(k) = (varargin{1}==tsList{k});
    end
end

%% Create column ranges
colRanges = cell(length(tsList),1);
for k=1:length(tsList)
    colRanges{k} = sprintf('1:%d',size(tsList{k}.Data,2));
end
tableData = [num2cell(isSelected(:)) tsNames(:) tsPath(:) colRanges(:)];

%% Rebuild the table and refresh the dialog so that the state of the
%% components reflects the selected time series
h.Handles.tsTable.getModel.setDataVector(tableData,...
    {xlate('Modify (y/n)?'),xlate('Time Series'),xlate('Path'),xlate('Selected Column(s)')},...
    h.Handles.tsTable);
drawnow
h.refreshInterpPanel;

