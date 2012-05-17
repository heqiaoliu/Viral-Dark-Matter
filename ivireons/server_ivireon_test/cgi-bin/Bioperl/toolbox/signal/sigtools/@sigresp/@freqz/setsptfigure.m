function setsptfigure(this,hFig)
%SETSPTFIGURE Set the default figure properties for Signal Toolbox GUIs.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision $  $Date: 2004/12/26 22:22:58 $

set(hFig,'MenuBar','None',...
    'Toolbar','None', ...
    'WindowButtonDownFcn', [], ...
    'WindowButtonMotionFcn', [], ...
    'WindowButtonUpFcn', []);

% Create the menus
render_menus(hFig);

% Create the toolbar
render_toolbar(hFig);

%-------------------------------------------------------------------
function  render_menus(hFig)

% Render the "File" menu
render_sptfilemenu(hFig);

% Render the "Edit" menu
render_spteditmenu(hFig);

% Render the "Insert" menu
render_sptinsertmenu(hFig,3);

% Render the "Tools" menu
render_spttoolsmenu(hFig,4);

% Render the "Window" menu
render_sptwindowmenu(hFig,5);

% Render a Signal Processing Toolbox "Help" menu
render_spthelpmenu(hFig,6);


%-------------------------------------------------------------------
function render_toolbar(hFig)

hui = uitoolbar('Parent',hFig);

% Render Print buttons (Print, Print Preview)
render_sptprintbtns(hui);

% Render the annotation buttons (Edit Plot, Insert Arrow, etc)
render_sptscribebtns(hui);

% Render the zoom buttons
render_zoombtns(hFig);

% [EOF]



