function handles = renderOptionsMenu(this)
%RENDEROPTIONSMENU <short description>
%   OUT = RENDEROPTIONSMENU(ARGS) <long description>

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:22:57 $

% Get the figure handle
hFig = this.FigureHandle;

% Create the file menu
hOptionsMenu = uimenu(...
    'Parent',hFig,...
    'Label','&Options',...
    'Tag','OptionsMenu');

% Attach submenu items
uimenu(...
    'Parent',hOptionsMenu,...
    'Callback',{@(hsrc,edata)menucbOptionsView(hsrc,this)},...
    'Label','Eye Diagram Object &Settings View...',...
    'Position', 1,...
    'Tag','OptionsMenuEyeSettings');

uimenu(...
    'Parent',hOptionsMenu,...
    'Callback',{@(hsrc,edata)menucbOptionsView(hsrc,this)},...
    'Label','&Measurements View...',...
    'Position', 2,...
    'Tag','OptionsMenuMeasurements');

handles.OptionsPlotCtrl = uimenu(...
    'Parent',hOptionsMenu,...
    'Callback',{@(hsrc,edata)menucbPlotCtrl(this)},...
    'Label','Eye Diagram &Plot Controls...',...
    'Separator', 'on',...
    'Position', 3,...
    'Tag','OptionsMenuPlotCtrl');

%-------------------------------------------------------------------------------
function menucbOptionsView(hsrc, hGui)
% Callback function for view options

% Get the caller ID
callerID = get(hsrc, 'Tag');

% Rener the window
renderOptionsViewSetup(hGui, callerID);

%-------------------------------------------------------------------------------
function menucbPlotCtrl(hGui)
% Callback function for plot controls

hPlotCtrl = hGui.PlotCtrlWin;

% If the PlotCtrlWin is empty, this is hte first time we render this window.
% First construct the object.
if isempty(hPlotCtrl)
    eyeStr = getSelected(hGui.EyeDiagramObjMgr);
    if ~isempty(eyeStr)
        hEye = eyeStr.Handle;
    else
        hEye = [];
    end
    hGui.PlotCtrlWin = commscope.EyeScopePlotCtrlWin(hGui, hEye);
    hPlotCtrl = hGui.PlotCtrlWin;
    % Set the single eye diagram view plot control window object
    hGui.SingleEyeScopeFace.PlotCtrlWin = hPlotCtrl;
end

if isRendered(hPlotCtrl)
    % Bring the window to the front
    bringToFront(hPlotCtrl);
else
    % Rener the window
    render(hPlotCtrl);
end

%-------------------------------------------------------------------------------
% [EOF]
