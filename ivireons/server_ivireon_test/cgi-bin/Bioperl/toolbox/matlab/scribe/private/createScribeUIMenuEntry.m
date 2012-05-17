function entry = createScribeUIMenuEntry(hFig,menuType,displayText,propName,undoName,varargin)
% Create a scribe entry for a UIContextMenu
% hFig - The figure to operate on
% menuType - String representing the
%            expected result of calling the menu.
% displayText - The text to be displayed in the menu.
% propName - The name of the property being modified.
% undoName - The string to be shown in the undo menu

%   Copyright 2006-2007 The MathWorks, Inc.

switch menuType
    case 'Color'
        entry = localCreateColorEntry(hFig,displayText,propName,undoName);
    case 'LineWidth'
        entry = localCreateLineWidthEntry(hFig,displayText,propName,undoName);
    case 'LineStyle'
        entry = localCreateLineStyleEntry(hFig,displayText,propName,undoName);
    case 'HeadStyle'
        entry = localCreateHeadStyleEntry(hFig,displayText,propName,undoName);
    case 'HeadSize'
        entry = localCreateHeadSizeEntry(hFig,displayText,propName,undoName);
    case 'AddData'
        entry = localCreateAddDataEntry(hFig,displayText);
    case 'LegendToggle'
        entry = localCreateLegendToggleEntry(hFig,displayText);
    case 'Toggle'
        entry = localCreateToggleEntry(hFig,displayText,propName,undoName);
    case 'Marker'
        entry = localCreateMarkerEntry(hFig,displayText,propName,undoName);
    case 'MarkerSize'
        entry = localCreateMarkerSizeEntry(hFig,displayText,propName,undoName);
    case 'EditText'
        entry = localCreateEditTextEntry(hFig,displayText);
    case 'Font'
        entry = localCreateFontEntry(hFig,displayText,propName,undoName);
    case 'TextInterpreter'
        entry = localCreateTextInterpreterEntry(hFig,displayText,propName,undoName);
    case 'CloseFigure'
        entry = localCreateCloseFigureEntry(hFig,displayText);
    case 'BarWidth'
        entry = localCreateBarWidthEntry(hFig,displayText,propName,undoName);
    case 'BarLayout'
        entry = localCreateBarLayoutEntry(hFig,displayText,propName,undoName);
    case 'AutoScaleFactor'
        entry = localCreateAutoScaleFactorEntry(hFig,displayText,propName,undoName);
    case 'EnumEntry'
        entry = localCreateEnumEntry(hFig,displayText,propName,varargin{:},undoName);
    case 'CustomEnumEntry'
        entry = localCreateCustomEnumEntry(hFig,displayText,propName,varargin{:});        
    case 'GeneralAction'
        entry = localCreateActionEntry(hFig,displayText,varargin{:});
end

%----------------------------------------------------------------------%
function entry = localCreateActionEntry(hFig,displayText,callbackFunction)

entry = uimenu(hFig,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',callbackFunction);

%----------------------------------------------------------------------%
function entry = localCreateAutoScaleFactorEntry(hFig,displayText,propName,undoName)
% Create a uimenu that brings up a list of scale sizes

values = [.2,.3,.4,.5,.7,.9,1.0];
format = '%1.1f';

entry = localCreateNumEntry(hFig,displayText,propName,values,format,undoName);

%----------------------------------------------------------------------%
function entry = localCreateBarWidthEntry(hFig,displayText,propName,undoName)
% Create a uimenu that brings up a list of bar width sizes

values = [.2,.3,.4,.5,.6,.7,.8,.9,1.0];
format = '%1.1f';

entry = localCreateNumEntry(hFig,displayText,propName,values,format,undoName);

%----------------------------------------------------------------------%
function entry = localCreateBarLayoutEntry(hFig,displayText,propName,undoName)
% Create a uimenu that is linked to text interpreters

descriptions = {'Grouped','Stacked'};
values = {'grouped','stacked'};

entry = localCreateEnumEntry(hFig,displayText,propName,descriptions,values, undoName);

%----------------------------------------------------------------------%
function entry = localCreateCloseFigureEntry(hFig,displayText)
% Create a uimenu that closes the figure

entry = uimenu(hFig,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localCloseFigure,hFig});

%----------------------------------------------------------------------%
function localCloseFigure(obj,evd,hFig) %#ok<INUSL>
% Close the figure

close(hFig);

%----------------------------------------------------------------------%
function entry = localCreateTextInterpreterEntry(hFig,displayText,propName,undoName)
% Create a uimenu that is linked to text interpreters

descriptions = {'latex','tex','none'};
values = {'latex','tex','none'};

entry = localCreateEnumEntry(hFig,displayText,propName,descriptions,values, undoName);

%----------------------------------------------------------------------%
function entry = localCreateFontEntry(hFig,displayText,propName,undoName) %#ok<INUSL>
% Create a uimenu that brings up a font picker.

entry = uimenu(hFig,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@scribeContextMenuCallback,'localExecuteFontCallback',hFig,undoName});

%----------------------------------------------------------------------%
function entry = localCreateEditTextEntry(hFig,displayText)
% Create a uimenu that sets text into edit mode

entry = uimenu(hFig,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localEditText,hFig});

%----------------------------------------------------------------------%
function localEditText(obj,evd,hFig) %#ok<INUSL>
% Get a handle to the mode. Though this creates an interdependency, it is
% mitigated by the guarantee that this callback is only executed while the
% mode is active, and thus already created.

if isactiveuimode(hFig,'Standard.EditPlot')
    hPlotEdit = plotedit(hFig,'getmode');
    hMode = hPlotEdit.ModeStateData.PlotSelectMode;
    hObj = hMode.ModeStateData.SelectedObjects;
else
    hObj = hittest(hFig);
end

set(hObj,'Editing','on');

%----------------------------------------------------------------------%
function entry = localCreateMarkerSizeEntry(hFig,displayText,propName,undoName)
% Create a uimenu that brings up a list of marker sizes

values = [2,4,5,6,7,8,10,12,18,24,48];
format = '%1.0f';

entry = localCreateNumEntry(hFig,displayText,propName,values,format,undoName);

%----------------------------------------------------------------------%
function entry = localCreateHeadSizeEntry(hFig,displayText,propName,undoName)
% Create a uimenu that brings up a list of marker sizes

values = [6,8,10,12,15,20,25,30,40];
format = '%2.0f';

entry = localCreateNumEntry(hFig,displayText,propName,values,format,undoName);

%----------------------------------------------------------------------%
function entry = localCreateMarkerEntry(hFig,displayText,propName,undoName)
% Creates a uimenu that represents marker types

descriptions = {'+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none'};
values = {'+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none'};

entry = localCreateEnumEntry(hFig,displayText,propName,descriptions,values, undoName);


%----------------------------------------------------------------------%
function entry = localCreateToggleEntry(hFig,displayText,propName,undoName)
% Creates a uimenu that sets a property to "on" or "off" 

entry = uimenu(hFig,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localToggleValue,hFig,propName,undoName});

%----------------------------------------------------------------------%
function localToggleValue(obj,evd,hFig,propName,undoName)
% Sets the toggle value

% The value to set is the "Checked" property 
if strcmpi(get(obj,'Checked'),'on')
    checkValue = 'off';
else
    checkValue = 'on';
end

scribeContextMenuCallback(obj,evd,'localUpdateValue',hFig,propName,checkValue,undoName);

%----------------------------------------------------------------------%
function entry = localCreateLegendToggleEntry(hFig,displayText)
% Create a uimenu entry that toggles a legend.

entry = uimenu(hFig,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localToggleLegend,hFig});

%----------------------------------------------------------------------%
function localToggleLegend(obj,evd,hFig) %#ok<INUSL>
% Get a handle to the mode. Though this creates an interdependency, it is
% mitigated by the guarantee that this callback is only executed while the
% mode is active, and thus already created.
if isactiveuimode(hFig,'Standard.EditPlot')
    hPlotEdit = plotedit(hFig,'getmode');
    hMode = hPlotEdit.ModeStateData.PlotSelectMode;
    hObj = hMode.ModeStateData.SelectedObjects;
else
    hObj = hittest(hFig);
end

for i=1:length(hObj)
    legend(double(hObj(i)),'Toggle');
end

%----------------------------------------------------------------------%
function entry = localCreateAddDataEntry(hFig,displayText)
% Create the menu entry which adds data to an axes.

entry = uimenu(hFig,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localAddData,hFig});

%----------------------------------------------------------------------%
function localAddData(obj,evd,hFig) %#ok<INUSL>
% Get a handle to the mode. Though this creates an interdependency, it is
% mitigated by the guarantee that this callback is only executed while the
% mode is active, and thus already created.
if isactiveuimode(hFig,'Standard.EditPlot')
    hPlotEdit = plotedit(hFig,'getmode');
    hMode = hPlotEdit.ModeStateData.PlotSelectMode;
    hObj = hMode.ModeStateData.SelectedObjects;
else
    hObj = hittest(hFig);
end

adddatadlg(hObj, hFig);

%----------------------------------------------------------------------%
function entry = localCreateLineStyleEntry(hFig,displayText,propName,undoName)
% Create a uimenu that brings up a list of line styles

descriptions = {'solid','dash','dot','dash-dot','none'};
values = {'-','--',':','-.','none'};

entry = localCreateEnumEntry(hFig,displayText,propName,descriptions,values,undoName);

%----------------------------------------------------------------------%
function entry = localCreateHeadStyleEntry(hFig,displayText,propName,undoName)
% Create a uimenu that brings up a list of line styles

descriptions = {'None','Plain','V-Back','C-Back','Diamond','Deltoid'};
values = {'none','plain','vback2','cback2','diamond','deltoid'};

entry = localCreateEnumEntry(hFig,displayText,propName,descriptions,values,undoName);

%----------------------------------------------------------------------%
function entry = localCreateEnumEntry(hFig,displayText,propName,descriptions,values,undoName)
% General helper function for enumerated types

entry = uimenu(hFig,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localUpdateEnumCheck,hFig,propName,descriptions,values});
for k=1:length(values)
    uimenu(entry,...
        'HandleVisibility','off',...
        'Label',descriptions{k},...
        'Separator','off',...
        'Visible','off',...
        'Callback',{@scribeContextMenuCallback,'localUpdateValue',hFig,propName,values{k},undoName});
end

%----------------------------------------------------------------------%
function entry = localCreateCustomEnumEntry(hFig,displayText,propName,descriptions,values,callback)
% General helper function for enumerated types

if ~iscell(callback)
    callback = {callback};
end

entry = uimenu(hFig,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localUpdateEnumCheck,hFig,propName,descriptions,values});
for k=1:length(values)
    uimenu(entry,...
        'HandleVisibility','off',...
        'Label',descriptions{k},...
        'Separator','off',...
        'Visible','off',...
        'Callback',{callback{:},hFig,values{k}});
end

%----------------------------------------------------------------------%
function localUpdateEnumCheck(obj,evd,hFig,propName,descriptions,values) %#ok<INUSL>
% For uimenu entries with children, make sure the proper one is checked

% Get a handle to the mode. Though this creates an interdependency, it is
% mitigated by the guarantee that this callback is only executed while the
% mode is active, and thus already created.
if isactiveuimode(hFig,'Standard.EditPlot')
    hPlotEdit = plotedit(hFig,'getmode');
    hMode = hPlotEdit.ModeStateData.PlotSelectMode;
    hObjs = hMode.ModeStateData.SelectedObjects;
else
    hMenu = ancestor(obj,'UIContextMenu');
    if isappdata(hMenu,'CallbackObject')
        hObjs = getappdata(hMenu,'CallbackObject');
    else
        hObjs = hittest(hFig);
    end
end
value = get(hObjs(end),propName);
location = strcmpi(value,values);
if any(location)
    label = descriptions{strcmpi(value,values)};
    menus = findall(obj,'Label',label);
    hPar = get(menus(1),'Parent');
else
    menus = [];
    hTemp = findall(obj,'Label',descriptions{1});
    hPar = get(hTemp(1),'Parent');
end
hSibs = findall(hPar);
set(hSibs(2:end),'Checked','off');
set(menus,'Checked','on');

%----------------------------------------------------------------------%
function entry = localCreateLineWidthEntry(hFig,displayText,propName,undoName)
% Create a uimenu that brings up a list of line widths

values = [.5,1:1:12];
format = '%1.1f';

entry = localCreateNumEntry(hFig,displayText,propName,values,format,undoName);

%----------------------------------------------------------------------%
function entry = localCreateNumEntry(hFig,displayText,propName,values,format,undoName)
% General helper function for menus with numeric values.

entry=uimenu(hFig,...
         'HandleVisibility','off',...
         'Label',displayText,...
         'Visible','off',...
         'Callback',{@localUpdateCheck,hFig,propName,format});
for k=1:length(values)
  uimenu(entry,...
         'HandleVisibility','off',...
         'Label',sprintf(format,values(k)),...
         'Separator','off',...
         'Visible','off',...
         'Callback',{@scribeContextMenuCallback,'localUpdateValue',hFig,propName,values(k),undoName});
end

%----------------------------------------------------------------------%
function localUpdateCheck(obj,evd,hFig,propName,format) %#ok<INUSL>
% For uimenu entries with children, make sure the proper one is checked

% Get a handle to the mode. Though this creates an interdependency, it is
% mitigated by the guarantee that this callback is only executed while the
% mode is active, and thus already created.
if isactiveuimode(hFig,'Standard.EditPlot')
    hPlotEdit = plotedit(hFig,'getmode');
    hMode = hPlotEdit.ModeStateData.PlotSelectMode;
    hObjs = hMode.ModeStateData.SelectedObjects;
else
    hMenu = ancestor(obj,'UIContextMenu');
    if isappdata(hMenu,'CallbackObject')
        hObjs = getappdata(hMenu,'CallbackObject');
    else
        hObjs = hittest(hFig);
    end
end

if ~isprop(hObjs(end),propName)
    return;
end

value = get(hObjs(end),propName);
label = sprintf(format,value);
menus = findall(obj,'Label',label);
if ~isempty(menus)
    hPar = get(menus(1),'Parent');
else
    menus = [];
    hPar = obj;
end
hSibs = findall(hPar);
set(hSibs(2:end),'Checked','off');
set(menus,'Checked','on');

%----------------------------------------------------------------------%
function entry = localCreateColorEntry(hFig,displayText,propName,undoName)
% Create a uimenu that brings up a color dialog:

% The menu will be reparented later, but for now parent it to the figure.
entry = uimenu(hFig,'HandleVisibility','off','Label',displayText,...
    'Callback',{@scribeContextMenuCallback,'localExecuteColorCallback',hFig,propName,undoName});