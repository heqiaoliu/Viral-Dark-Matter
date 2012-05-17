function res = createScribeContextMenu(hThis,hFig) %#ok<INUSL>
% Given a figure, check for context-menu entries specific to that shape-type and
% figure. If no context-menu has been defined, then create one. It should
% be noted that we are only returning entries to be merged into a larger
% context-menu at a later point in time.

% The context-menu entries will be uniquely identified by a tag based on the shape
% type. Tags should be of the form "package.class.uicontextmenu" and will
% have their visibility set to off.

%   Copyright 2006 The MathWorks, Inc.

hPlotEdit = plotedit(hFig,'getmode');
hMode = hPlotEdit.ModeStateData.PlotSelectMode;
hMenu = hMode.UIContextMenu;

res = findall(hMenu,'Type','uimenu','Tag','scribe.arrow.uicontextmenu');
if ~isempty(res)
    res = res(end:-1:1);
    return;
end

% Create the context menu entries.
res = [];

% Reverse Direction:
res(end+1) = uimenu(hFig,'Label','Reverse Direction','Callback',{@localReverseDirection,hMode},...
    'HandleVisibility','off');
% Line color:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'Color','Color ...','Color','Color');
set(res(end),'Separator','on');
% Line width:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'LineWidth','Line Width','LineWidth','Line Width');
% Line style:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'LineStyle','Line Style','LineStyle','Line Style');
% Head style:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'HeadStyle','Head Style','HeadStyle','Head Style');
% Head size:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'HeadSize','Head Size','HeadSize','Head Size');

% Set the tag for future access
set(res,'Tag','scribe.arrow.uicontextmenu','Visible','off','Parent',hMenu);

%----------------------------------------------------------------------%
function localReverseDirection(obj,evd,hMode)
% Reverse the direction of the arrow.

props = {'X','Y'};
hObjs = hMode.ModeStateData.SelectedObjects;
origVals = get(hObjs,props);
% To reverse direction, simply reverse the contents of X and Y
newVals = cellfun(@(x)(fliplr(x)),origVals,'UniformOutput',false);
% Construct a property undo
graph2dhelper('scribeContextMenuCallback',obj,evd,'localConstructPropertyUndoCallback',...
    hMode.FigureHandle,hMode,'Direction',props,origVals,newVals)
set(hObjs,props,newVals);