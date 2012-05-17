function res = createScribeContextMenu(hThis,hFig) %#ok<INUSL>
% Given a figure, check for context-menu entries specific to that shape-type and
% figure. If no context-menu has been defined, then create one. It should
% be noted that we are only returning entries to be merged into a larger
% context-menu at a later point in time.

% The context-menu entries will be uniquely identified by a tag based on the shape
% type. Tags should be of the form "package.class.uicontextmenu" and will
% have their visibility set to off.

%   Copyright 2006-2007 The MathWorks, Inc.

hPlotEdit = plotedit(hFig,'getmode');
hMode = hPlotEdit.ModeStateData.PlotSelectMode;
hMenu = hMode.UIContextMenu;

res = findall(hMenu,'Type','uimenu','Tag','scribe.textbox.uicontextmenu');
if ~isempty(res)
    fitBoxToTextEntry = findall(res,'Label','Fit Box to Text');
    set(fitBoxToTextEntry,'Checked',get(hThis,'FitBoxToText'));
    res = res(end:-1:1);
    return;
end

% Create the context menu entries.
res = [];
% Edit
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'EditText','Edit','','');
% Fit Box to Text
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'Toggle','Fit Box to Text','FitBoxToText','Fit Box to Text');
set(res(end),'Checked',get(hThis,'FitBoxToText'));
set(res(end),'Separator','on');
% Text color:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'Color','Color ...','Color','Text Color');
set(res(end),'Separator','on');
% Background color:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'Color','Background Color ...','BackgroundColor','Background Color');
% Edge color:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'Color','Edge Color ...','EdgeColor','Edge Color');
% Font:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'Font','Font ...','','Font');
% Interpreter:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'TextInterpreter','Interpreter','Interpreter','Interpreter');
% Line width:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'LineWidth','Line Width','LineWidth','Line Width');
% Line style:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'LineStyle','Line Style','LineStyle','Line Style');


% Set the tag for future access
set(res,'Tag','scribe.textbox.uicontextmenu','Visible','off','Parent',hMenu);
