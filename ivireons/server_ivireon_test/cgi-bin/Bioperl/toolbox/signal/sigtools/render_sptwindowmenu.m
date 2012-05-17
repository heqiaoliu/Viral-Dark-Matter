function hwindow = render_sptwindowmenu(hFig, pos)
%RENDER_SPTWINDOWMENU Render a Signal Processing Toolbox "Window" menu.
%   HWINDOW = RENDER_SPTWINDOWMENU(HFIG, POS) creates a "Window" menu in POS position
%   on a figure whose handle is HFIG and return the handles to all the menu items.

%   Author(s): V.Pellissier
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2005/12/22 19:05:32 $ 

strs  = '&Window';
cbs   = 'winmenu(gcbo);';
tags  = 'winmenu'; 
sep   = 'off';
accel = '';
hwindow = addmenu(hFig,pos,strs,cbs,tags,sep,accel);

% We see no reason to make this call here.  It must be remade every time
% that the main 'Window' menu is clicked.  Having it here only slows down
% the launch of our tools.
% winmenu(hFig);

% [EOF]
