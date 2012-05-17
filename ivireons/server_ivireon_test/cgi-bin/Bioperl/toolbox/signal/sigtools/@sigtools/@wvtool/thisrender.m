function thisrender(this)
%THISRENDER Render the wvtool object.

%   Author(s): V.Pellissier
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.5.4.7 $  $Date: 2005/12/22 19:05:06 $

% Set up the figure handle
hFig = setup_figure(this);

% Render menus
h.menus = render_menus(hFig,this);

% Render toolbar
h.toolbar = render_toolbar(hFig, this);

% Store handles in object
set(this,'Handles', h);

% Render siggui.winviewer
thisiew = getcomponent(this, '-class', 'siggui.winviewer');
render(thisiew, hFig, [], 3);

hL = siglayout.gridlayout(hFig, 'HorizontalGap', 5, 'VerticalGap', 5);
hL.add(thisiew.Container, 1, 1);

% Render the CSHelp button
render_cshelpbtn(hFig, 'WVTool');

%-------------------------------------------------------------------
function hFig = setup_figure(this)

% Get the default background color
bgc  = get(0,'defaultuicontrolbackgroundcolor');

name = get(this, 'Name');

cbs = callbacks(this);

hFig = figure('CloserequestFcn', cbs.close, ...
    'Color', bgc, ...
    'DoubleBuffer', 'on', ...
    'HandleVisibility', 'callback', ...
    'Menubar', 'None', ...
    'NumberTitle', 'On', ...
    'IntegerHandle', 'On', ...
    'Name', name, ...
    'Toolbar', 'None', ...
    'Visible', 'off');

% Center figure
sz = local_gui_sizes(this);
origUnits = get(0, 'Units'); set(0, 'Units', 'Pixels');
screensize = get(0, 'Screensize'); set(0, 'Units', origUnits);
xpos = round((screensize(3)-sz.fig_w)/2);
ypos = round((screensize(4)-sz.fig_h)/2);
set(hFig, 'Position', [xpos ypos sz.fig_w sz.fig_h]);


% Print option default : don't print uicontrols (measurements)
pt = printtemplate;
pt.PrintUI = 0;
set(hFig, 'PrintTemplate', pt);

set(this, 'FigureHandle', hFig);

%-------------------------------------------------------------------
function sz = local_gui_sizes(this)

% Get the generic gui sizes
sz = gui_sizes(this);

% Figure width and height
sz.fig_w = 674*sz.pixf;
sz.fig_h = 335*sz.pixf;


%-------------------------------------------------------------------
function hmenus = render_menus(hFig,this)

% Render the "File" menu
hmenus.hfile = render_sptfilemenu(hFig);

set(findobj(hmenus.hfile, 'tag', 'print'),        'Callback', {@print_cb,     this});
set(findobj(hmenus.hfile, 'tag', 'printpreview'), 'Callback', {@printprev_cb, this});

% Render the "Edit" menu
hmenus.hedit = render_spteditmenu(hFig);

set(findobj(hmenus.hedit, 'Tag', 'figMenuEditCopyFigure'), 'Callback', {@copyfig_cb, this});

% Render the "Insert" menu
hmenus.hinsert = render_sptinsertmenu(hFig,3);

% Render the "Tools" menu
hmenus.htools = render_spttoolsmenu(hFig,4);

% Render the "Window" menu
hmenus.hwindow = render_sptwindowmenu(hFig,5);

% Render a Signal Processing Toolbox "Help" menu
hmenus.hhelp = render_helpmenu(hFig,this);


%-------------------------------------------------------------------
function hhelp = render_helpmenu(hFig,this)

[hhelpmenu, hhelpmenuitems] = render_spthelpmenu(hFig,6);

strs  = '&What''s This?';
cbs   = {@cshelpgeneral_cb, 'WinView'};
tags  = 'whatsthis'; 
sep   = 'on';
accel = '';
hwhatsthis = addmenu(hFig,[6 2],strs,cbs,tags,sep,accel);

cbs = callbacks(this);
strs  = xlate('WVTool Help');
cb    = cbs.helpwvtool;
tags  = 'wvtool help'; 
sep   = 'off';
accel = '';
hwvtoolhelp = addmenu(hFig,[6 1],strs,cb,tags,sep,accel);


hhelp = [hwvtoolhelp, hhelpmenu, hhelpmenuitems(1), hwhatsthis, hhelpmenuitems(2:end)];


%-------------------------------------------------------------------
function htoolbar = render_toolbar(hFig, this)

htoolbar.htoolbar = uitoolbar('Parent',hFig);

% Render Print buttons (Print, Print Preview)
htoolbar.hprintbtns = render_sptprintbtns(htoolbar.htoolbar);

set(findobj(htoolbar.hprintbtns, 'tag', 'printresp'), ...
    'ClickedCallback', {@print_cb,     this});
set(findobj(htoolbar.hprintbtns, 'tag', 'printprev'), ...
    'ClickedCallback', {@printprev_cb, this});

% Render the annotation buttons (Edit Plot, Insert Arrow, etc)
htoolbar.hscribebtns = render_sptscribebtns(htoolbar.htoolbar);

% Render the zoom buttons
htoolbar.hzoombtns = render_zoombtns(hFig);

%-------------------------------------------------------------------
function copyfig_cb(hcbo, eventStruct, this)

hFig    = get(this, 'FigureHandle');
old_ppm = get(hFig, 'PaperPositionMode');
set(hFig, 'PaperPositionMode', 'auto');

hv = getcomponent(this, '-class', 'siggui.winviewer');
copyfigure(hv);

set(hFig, 'PaperPositionMode', old_ppm);

%-------------------------------------------------------------------
function print_cb(hcbo, eventStruct, this)

hFig = get(this, 'FigureHandle');
old_resize = get(hFig, 'ResizeFcn');
set(hFig, 'ResizeFcn', []);

hv = getcomponent(this, '-class', 'siggui.winviewer');
print(hv, ...
    'PaperUnits', get(hFig, 'PaperUnits'), ...
    'PaperOrientation', get(hFig, 'PaperOrientation'), ...
    'PaperPosition', get(hFig, 'PaperPosition'), ...
    'PaperSize', get(hFig, 'PaperSize'), ...
    'PaperType', get(hFig, 'PaperType'));

set(hFig, 'ResizeFcn', old_resize);

%-------------------------------------------------------------------
function printprev_cb(hcbo, eventStruct, this)

hFig = get(this, 'FigureHandle');
old_resize = get(hFig, 'ResizeFcn');
set(hFig, 'ResizeFcn', []);

hv = getcomponent(this, '-class', 'siggui.winviewer');
printpreview(hv, ...
    'PaperUnits', get(hFig, 'PaperUnits'), ...
    'PaperOrientation', get(hFig, 'PaperOrientation'), ...
    'PaperPosition', get(hFig, 'PaperPosition'), ...
    'PaperSize', get(hFig, 'PaperSize'), ...
    'PaperType', get(hFig, 'PaperType'));

set(hFig, 'ResizeFcn', old_resize);

% [EOF]
