function addTs(h,ts,varargin)

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2010/04/21 21:33:58 $

import com.mathworks.mde.desk.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;
import com.mathworks.mwswing.desk.*;

persistent initialized;

if ~iscell(ts)
    ts = {ts};
end

% If necessary build the timeplot
wb = [];
treeLocked = false;
cachedCloseReq = '';
if isempty(h.Plot) || ~ishandle(h.Plot)
    % Hide status text
    set(h.Handles.InitTXT,'Visible','off')
    
    % Lock the tree
    treeLocked = true;
    treeModel = h.getRoot.TsViewer.TreeManager.Tree.getTree.getSelectionModel;
    selectedTreePathCache = treeModel.fCurrentPath;
    treeModel.fCurrentPath = treeModel.getSelectionPath;
    
    % Create @respplot. All @respplot style managers are defined by the
    % tsviewer
    h.maybeDockFig;
    
    % Create a preview if one is defined
    if isempty(initialized)
        % Do not allows closing the preview figure during initialization
        % to prevent getting into a bad state (g552825)
        cachedCloseReq = get(h.Figure,'closeRequestFcn');
        set(h.Figure,'closeRequestFcn','');
        wb = h.createPreview(ts,wb);
    end
    
    % Create the uitspanel
    if isempty(initialized) && ishandle(wb)
        waitbar(.2,wb,xlate('Adding layout manager'));
    end
    viewpanel = tsguis.uitspanel('Parent',h.Figure,'Name',xlate('Time Series Plot'),...
        'SelectionHighlight','off');
    
    % If there's a preview reset the child order
    if isempty(initialized)
        h.updatePreview;
    end
    
    % Create the @respack plot
    h.createPlot(viewpanel,ts);
end

% Is the time series already there?
ts = h.checkUniqueNames(ts);
if isempty(ts)
    nestedCleanup;
    return
end

% Customize the plot apearance for the added time series
status = h.setPlotProperties(ts);
if ~status % Failure to accommodate new timeseries.
    nestedCleanup;
    return;
end

% Update table and plot
if isempty(initialized) && ishandle(wb)
    waitbar(.6,wb,xlate('Activating special plot features'));
end
if nargin>=3
    axespos = varargin{1};
else
    axespos = [];
end
if length(ts)==1
    h.Plot.addTs(ts{1},axespos);
else % Add members of a tscollection to the same axes
    h.Plot.addTs(ts{1},axespos,true);
    axespos = h.Plot.axesgrid.size(1);
    for k=2:length(ts)-1
        h.Plot.addTs(ts{k},axespos,true);
    end
    h.Plot.addTs(ts{end},axespos);
end

% Fire tschanged event to announce the change
h.send('tschanged',handle.EventData(h,'tschange'));

% The following drawnow is required because event markers do not show up
% otherwise, if multiple timeseires are plotted in quick succession, as when
% plotting a tscollection as a whole (r.s.) - G265793
drawnow

%% Dock into the Time Sereis Group
h.maybeDockFig;

% Refresh the axestable
if isempty(initialized) && ishandle(wb)
    waitbar(.8,wb,xlate('Updating plot...'));
end
drawnow % Figure must be fully rendered before plot is set visible.
set(findobj(allchild(h.Figure),'type','uimenu'),'enable','on');
h.Plot.Visible = 'on';

% Add legend
ax = h.Plot.AxesGrid.getaxes;
h.Plot.AxesGrid.refreshlegends;
for k=1:length(ax)
    legend(double(ax(k)),'show');
end
drawnow
if isempty(initialized)
    set(findobj(allchild(h.Figure),'type','uimenu'),'enable','on');
    set(allchild(findobj(allchild(h.Figure),'type','uitoolbar')),'enable','on')
    delete(findobj(h.Figure,'type','axes','-depth',1));
    if ishandle(wb)
        waitbar(1,wb,xlate('Completed'));
    end
end

% Determine if the property editor should be opened
if ~isempty(h.getRoot.Tsviewer.MDIGroupName)
    h.maybeShowPropEditor(MLDesktop.getInstance.getGroupContainer(xlate('Time Series Plots')));
end

% If the Property Editor was opened above it is possible that the figure
% was closed during its construction. In this case close the waitbar and
% return early to prevent errors caused by accessing an invalid figure
% (g552825)
if ~ishghandle(h.Figure)
    nestedCleanup;
    return
end
plotedit(h.Figure,'off');

h.setDropAdaptor(h.DropAdaptor);
if isempty(initialized)
    delete(wb);
    initialized = true;
end

%% Unlock the tree
if treeLocked
    treeModel.fCurrentPath = selectedTreePathCache;
end

if ~isempty(cachedCloseReq)
    set(h.Figure,'closeRequestFcn',cachedCloseReq);
end
    % Delete any remaining waitbars and restore figure closeRequestFcn
    % before returning
    function nestedCleanup        
        if ~isempty(wb)
            delete(wb);
        end       
        if ishghandle(h.Figure) && ~isempty(cachedCloseReq)
            set(h.Figure,'closeRequestFcn',cachedCloseReq);
        end
    end

end

