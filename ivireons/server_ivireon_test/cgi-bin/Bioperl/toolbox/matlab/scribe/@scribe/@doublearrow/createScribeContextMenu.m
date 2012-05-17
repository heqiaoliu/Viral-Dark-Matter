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

res = findall(hMenu,'Type','uimenu','Tag','scribe.doublearrow.uicontextmenu');
if ~isempty(res)
    res = res(end:-1:1);
    return;
end

% Create the context menu entries.
res = [];

% Line color:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'Color','Color ...','Color','Color');
% Line width:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'LineWidth','Line Width','LineWidth','Line Width');
% Line style:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'LineStyle','Line Style','LineStyle','Line Style');
% Head style:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'HeadStyle','Head Style','HeadStyle','Head Style');
% Head size:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'HeadSize','Head Size','HeadSize','Head Size');

% Set the tag for future access
set(res,'Tag','scribe.doublearrow.uicontextmenu','Visible','off','Parent',hMenu);