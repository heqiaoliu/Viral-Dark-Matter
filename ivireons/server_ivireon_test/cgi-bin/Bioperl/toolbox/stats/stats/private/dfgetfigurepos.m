function figpos = dfgetfigurepos(dffig,units)
%DFGETFIGUREPOS Get position for a d.f. figure without uicontrols

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:28:56 $
%   Copyright 2003-2004 The MathWorks, Inc.

% Get figure position in specified units
figpos = get(dffig,'Position');
figpos = hgconvertunits(dffig,figpos,get(dffig,'Units'),units,dffig);

% Get location of top of frame
hsel = getappdata(dffig,'selectioncontrols');
framepos = get(hsel(1),'Position');
framepos = hgconvertunits(dffig,framepos,get(hsel(1),'Units'),units,dffig);
frametop = framepos(2)+framepos(4);

% Get location of bottom of buttons
hbut = getappdata(dffig,'buttoncontrols');
butpos = get(hbut(1),'Position');
butpos = hgconvertunits(dffig,butpos,get(hbut(1),'Units'),units,dffig);
butbase = butpos(2);

% Reduce figure height by the height of the controls
figpos(4) = max(0,figpos(4)-(frametop-butbase));
