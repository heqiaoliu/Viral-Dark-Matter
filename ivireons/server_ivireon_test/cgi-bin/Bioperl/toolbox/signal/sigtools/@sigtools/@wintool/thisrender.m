function thisrender(hWT, pos)
%THISRENDER Render the window GUI

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $  $Date: 2008/05/31 23:28:46 $

if nargin < 2 , pos =[]; end

% test screen resolution

% Create figure and center it
hFig = setup_figure(hWT);

% Set up the figure handle
set(hWT, 'FigureHandle', hFig);

% Get the enable state
enabstate = get(hWT, 'Enable');

% Render menus
hndls.hmenus = render_menus(hWT, enabstate);

% Render toolbar
hndls.htoolbar = render_toolbar(hWT, enabstate);

% Store the handles of the menus and the toolbar buttons
set(hWT, 'Handles', hndls);

% Render components after having set the isRendered flag to 1 
% so that the listeners are fired.
render_components(hWT, enabstate);

% Render the "What's This?" button
hndls.htoolbar(end+1) = render_cshelpbtn(hFig, 'Wintool');

% Store the handles of the menus and the toolbar buttons
set(hWT, 'Handles', hndls);

% Add listeners
installListeners(hWT);

%-------------------------------------------------------------------
%                       Utility Functions
%-------------------------------------------------------------------
function hFig = setup_figure(hWT)

hFig = get(hWT, 'FigureHandle');
visstate  = get(hWT, 'Visible');

bgc  = get(0,'defaultuicontrolbackgroundcolor');
cbs = callbacks(hWT);

hFig = figure( ...
    'Color', bgc, ...
    'CloseRequestFcn', cbs.close, ...
    'DoubleBuffer' , 'on', ...
    'HandleVisibility', 'callback', ...
    'Menubar' , 'none', ...
    'NumberTitle', 'off', ...
    'Name', 'Window Design & Analysis Tool', ...
    'Visible', visstate);

% Center figure
sz = local_gui_sizes(hWT);
screensize = get(0, 'Screensize');
xpos = round((screensize(3)-sz.fig_w)/2);
ypos = round((screensize(4)-sz.fig_h)/2);
set(hFig, 'Position', [xpos ypos sz.fig_w sz.fig_h]);

% Print option default : don't print uicontrols
pt = printtemplate;
pt.PrintUI = 0;
set(hFig, 'PrintTemplate', pt);


%-------------------------------------------------------------------
function sz = local_gui_sizes(hWT)

% Get the generic gui sizes
sz = gui_sizes(hWT);

% Figure width and height
sz.fig_w = 683*sz.pixf;;
sz.fig_h = 550*sz.pixf;;

% Management component
sz.manag_x = 12;
sz.manag_y = 13;

% Specifications component
sz.specs_x = 440;
sz.specs_y = 13;

% Viewer component
sz.view_x = 12;
sz.view_y = 230;


%-------------------------------------------------------------------
function hmenus = render_menus(hWT, enabstate)
%RENDER_MENUS Render the menus of the Window GUI.

hFig = get(hWT, 'FigureHandle');
% Create an uimenu
uimenu(hFig);

% File menu
hfile = render_filemenu(hWT);

% Tools menu
[htoolsmenu, htoolsmenuitems] = render_toolsmenu(hFig);

% Window menu
hwindow = render_windowmenu(hFig);

% Help menu
[hhelpmenu, hhelpmenuitems] = render_helpmenu(hFig, hWT);

% Return the handles to all the menus
hmenus = [hfile(:); htoolsmenu; htoolsmenuitems(:); ...
        hwindow; hhelpmenu; hhelpmenuitems(:)];

% Set the enable state
set(hmenus, 'Enable', enabstate);


%-------------------------------------------------------------------
function hfile = render_filemenu(hWT)
%RENDER_FILEMENU Render the File menu

hFig = get(hWT, 'FigureHandle');

strs = {'&File', ...
    '&New WinTool', ...
    '&Export...', ...
    'Page Setup...', ...
    'Print Setup...', ...
    'Print Preview...', ...
    'Print...', ...
    'Full View Analysis', ...
    'Close'};
cb = callbacks(hWT);
cbs = {'', ...
    cb.new, ...
    cb.export, ...
    cb.pagesetup, ...
    cb.printsetup, ...
    cb.printpreview, ...
    cb.print, ...
    cb.printtofigure, ...
    cb.close};
tags = {'file', ...
    'newwintool', ...
    'export', ...
    'pagesetup', ...
    'printsetup', ...
    'printpreview', ...
    'print', ...
    'printtofigure', ...
    'close'};
sep = {'off', ...
    'off', ...
    'on', ...
    'on', ...
    'off', ...
    'off', ...
    'off', ...
    'on', ...
    'on'};
accel = {'', ...
    'N', ...
    'E', ...
    '', ...
    '', ...
    '', ...
    'P', ...
    '', ...
    'W'};
hfile = addmenu(hFig,1,strs,cbs,tags,sep,accel);


%-------------------------------------------------------------------
function [htoolsmenu, htoolsmenuitems] = render_toolsmenu(hFig)
%RENDER_TOOLSMENU Render the Tools menu

strs  = 'Tool&s';
cbs   = '';
tags  = 'tools'; 
sep   = 'Off';
accel = '';
htoolsmenu = addmenu(hFig,2,strs,cbs,tags,sep,accel);
% render the "Zoom In" and "Zoom Out" menus
htoolsmenuitems = render_zoommenus(hFig, [2 1]);


%-------------------------------------------------------------------
function hwindow = render_windowmenu(hFig)
%RENDER_WINDOWMENU Render the Window menu

strs  = 'Window';
cbs   = 'winmenu(''callback'');';
tags  = 'winmenu'; 
sep   = 'off';
accel = '';
hwindow = addmenu(hFig,3,strs,cbs,tags,sep,accel);
winmenu(hFig);


%-------------------------------------------------------------------
function [hhelpmenu, hhelpmenuitems] = render_helpmenu(hFig, hWT)
%RENDER_HELPMENU Render the Help menu

[hhelpmenu, hhelpmenuitems] = render_spthelpmenu(hFig, 4);

strs  = 'WinTool &Help';
cbs = callbacks(hWT);
tags  = 'wintoolhelp'; 
sep   = 'off';
accel = '';
hhelpmenuitems(end+1) = addmenu(hFig,[4 1],strs,cbs.wintoolhelp,tags,sep,accel);

strs  = '&What''s This?';
cbs   = {@cshelpgeneral_cb, 'WinTool'};
tags  = 'whatsthis'; 
sep   = 'on';
accel = '';
hhelpmenuitems(end+1) = addmenu(hFig,[4 3],strs,cbs,tags,sep,accel);


%-------------------------------------------------------------------
function htoolbar = render_toolbar(hWT, enabstate);
%RENDER_TOOLBAR Render the toolbar of the window GUI.

hFig = get(hWT, 'FigureHandle');

% Render a Toolbar
hut = uitoolbar('Parent',hFig);

% Render standard buttons (New, Print, Print Preview)
hstdbtns = render_standardbtns(hWT, hut);

% Render the Print to Figure button
hprint2figurebtn = render_print2figurebtn(hWT, hut);

% Render the Zoom In and Zoom Out buttons
hzoombtns = render_zoombtns(hFig);

% Return the handles to all the toolbar buttons
htoolbar = [hstdbtns(:); hprint2figurebtn; ...
        hzoombtns(:)];

% Set the enable state
set(htoolbar, 'Enable', enabstate);


%-------------------------------------------------------------------
function hstdbtns = render_standardbtns(hWT, hut);
% Render standard buttons (New, Print, Print Preview)

% Load new, open, save print and print preview icons.
load mwtoolbaricons;

% Structure of all local callback functions
cbs = callbacks(hWT);     

% Cell array of cdata (properties) for the toolbar icons 
pushbtns = {newdoc,...
            printdoc,...
            printprevdoc};

tooltips = {'New WinTool',...
            'Print',...
            'Print Preview'};

tags = {'newwintool',...
        'printresp',...
        'printprev'};

% List callbacks for pushbuttons
btncbs = {cbs.new,...
          cbs.print,...
          cbs.printpreview};

% Render the PushButtons
for i = 1:length(pushbtns),
   hstdbtns(i) = uipushtool('Cdata',pushbtns{i},...
        'Parent', hut,...
        'ClickedCallback',btncbs{i},...
        'Tag',            tags{i},...
        'Tooltipstring',  tooltips{i});
end
 

%-------------------------------------------------------------------
function hprint2figurebtn = render_print2figurebtn(hWT, hut);
% Render the "Print to figure" toolbar button

% Load the MAT-file with the icon
load wintoolicons;

% Structure of all local callback functions
cbs = callbacks(hWT);     

% Render the ToggleButtons
hprint2figurebtn = uipushtool('Cdata',icons.printtofigure,...
    'Parent', hut, ...
    'ClickedCallback', cbs.printtofigure, ...
    'Tag',            'printtofigure', ...
    'Tooltipstring',  'Full View Analysis', ...
    'Separator',      'On');


%-------------------------------------------------------------------
function render_components(hWT, enabstate)
%RENDER_COMPONENTS Render the components of the Window GUI.

% Find the components
hSpecs = getcomponent(hWT, '-class', 'siggui.winspecs');
hView  = getcomponent(hWT, '-class', 'siggui.winviewer');
hManag = getcomponent(hWT, '-class', 'siggui.winmanagement');

% Get the figure Handle
hFig = get(hWT, 'FigureHandle');

sz = gui_sizes(hWT);

% The management component MUST be render the last to be sure that 
% the listeners are fired properly.
render(hSpecs, hFig);
render(hView, hFig);
render(hManag, hFig);

hLayout = siglayout.gridbaglayout(hFig);

set(hLayout, ...
    'HorizontalGap',     12*sz.pixf, ...
    'VerticalGap',       5*sz.pixf, ...
    'VerticalWeights',   [1 0], ...
    'HorizontalWeights', [1 0]);

hLayout.add(hView.Container, 1, 1:2, ...
    'Fill', 'Both');
hLayout.add(hManag.Container, 2, 1, ...
    'MinimumHeight', 212*sz.pixf, ...
    'Fill', 'Horizontal', ...
    'BottomInset', 8*sz.pixf);
hLayout.add(hSpecs.Container, 2, 2, ...
    'MinimumHeight', 212*sz.pixf, ...
    'MinimumWidth', 232*sz.pixf, ...
    'BottomInset', 8*sz.pixf);

%-------------------------------------------------------------------
function installListeners(hWT)

% Find the components
hSpecs = getcomponent(hWT, '-class', 'siggui.winspecs');
hView  = getcomponent(hWT, '-class', 'siggui.winviewer');
hManag = getcomponent(hWT, '-class', 'siggui.winmanagement');

%----------------- Create the listeners to event--------------------

% The Viewer and Specifications components listen to a NewSelection event 
% thrown by the Management component
addlistener(hWT, 'NewSelection', @newselection_eventcb, hManag, hView);
addlistener(hWT, 'NewSelection', @isemptyselection_eventcb, hManag, hWT);
addlistener(hWT, 'NewSelection', @newselection_eventcb, hManag, hSpecs);

% The Management and Viewer components listen to a NewCurrentwinIndex event 
% thrown by the Specifications component
addlistener(hWT, 'NewCurrentwinIndex', @newcurrentwinindex_eventcb, hSpecs, hView);
addlistener(hWT, 'NewCurrentwinIndex', @newcurrentwinindex_eventcb, hSpecs, hManag);

% The Specifications component listen to a NewCurrentwin event 
% thrown by the Management component
addlistener(hWT, 'NewCurrentwin', @newcurrentwin_eventcb, hManag, hSpecs);

% The Management component listen to a NewState event 
% thrown by the Specifications component
addlistener(hWT, 'NewState', @newcurrentwinstate_eventcb, hSpecs, hManag);

% [EOF]
