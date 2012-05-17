function setHTMTableColumn(h,tsTable,varargin)

% Copyright 2005-2008 The MathWorks, Inc.

%% Method to provide HTM appearance of a column of a table listing time series and
%% time series paths. Clicking on the time series hypertext will select the
%% time series node on the tree

import com.mathworks.toolbox.timeseries.*;

%% Find the time series column
if nargin>=3
    tsColumn = varargin{1};
else
    tsColumn = 1;
end

%% Make the time series column html
htmRenderer = BlockPathRenderer;
awtinvoke(tsTable.getColumnModel.getColumn(tsColumn-1),...
    'setCellRenderer',htmRenderer);
htmMouseListener = htmMouseListener(tsTable,tsColumn-1);
awtinvoke(tsTable,'addMouseMotionListener',...
    htmMouseListener);
%% Use mouse released so that JAWS gets a chance to announce the selected
%% cell
set(handle(tsTable,'callbackproperties'),...
    'MouseReleasedCallback',{@localMouseClicked tsTable h tsColumn})

%% Make sure the row width is wide enough to accommodate the html
if tsTable.getRowHeight<23
    drawnow
    awtinvoke(tsTable,'setRowHeight(I)',23);
end

    
function localMouseClicked(es,eventData,tsTable,h,tsColumn)

% Callback from timeseries tables which display timeseries by name (1st
% column) and path (2nd column)

import java.awt.geom.Point2D;
col = tsTable.columnAtPoint(eventData.getPoint);
if isequal(col,tsColumn-1)
    row = tsTable.rowAtPoint(eventData.getPoint);
    tableData = cell(tsTable.getModel.getData);
    pathspec = tableData{row+1,col+2};
    if isempty(pathspec)
        return
    end
    tsnode = h.search(pathspec);
    if ~isempty(tsnode)
        h.getRoot.Tsviewer.TreeManager.reset
        h.getRoot.Tsviewer.TreeManager.Tree.setSelectedNode(tsnode.getTreeNodeInterface);
        drawnow % Force the node to show seelcted
        h.getRoot.Tsviewer.TreeManager.Tree.repaint        
    end
end