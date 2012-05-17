function this = tabpanel(hfig)
% Creates tab panel.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:12 $
this = ctrluis.tabpanel;
this.Parent = handle(hfig);
this.Listener = [...
      handle.listener(this,this.findprop('Selected'),'PropertyPostSet',@LocalLayoutPanel)];

% Acquire geometry parameters
FigUnits = get(hfig,'Units');
tframe =  uicontrol('Parent',hfig,'Style','frame','Units',FigUnits,'Position',[0 0 10 5]);
set(tframe,'Units','pixels');
p = get(tframe,'Position');
this.Pix2Unit = [10 5]./p(3:4);
set(tframe,'Units','characters');
p = get(tframe,'Position');
this.Char2Unit = [10 5]./p(3:4);
delete(tframe)

% Colors
color = get(hfig,'color');
lcolor = min(1, color * 1.2);
mcolor = min(1, color * .7);
dcolor = min(1, color * .3);

% Create panel
this.Panel = [...
   uicontrol('parent',hfig,'visible','off','backgroundcolor',lcolor,'style','text','enable','off');...
   uicontrol('parent',hfig,'visible','off','backgroundcolor',color,'style','text','enable','off');...
   uicontrol('parent',hfig,'visible','off','backgroundcolor',dcolor,'style','text','enable','off');...
   uicontrol('parent',hfig,'visible','off','backgroundcolor',mcolor,'style','text','enable','off');...
   uicontrol('parent',hfig,'visible','off','backgroundcolor',dcolor,'style','text','enable','off');...
   uicontrol('parent',hfig,'visible','off','backgroundcolor',mcolor,'style','text','enable','off');...
   uicontrol('parent',hfig,'visible','off','backgroundcolor',color,'style','text','enable','off');...
   uicontrol('parent',hfig,'visible','off','backgroundcolor',lcolor,'style','text','enable','off');...
   uicontrol('parent',hfig,'visible','off','backgroundcolor',color,'style','text','enable','off');...
   uicontrol('parent',hfig,'visible','off','backgroundcolor',lcolor,'style','text','enable','off')];

% Create tab edges
this.TabLeftEdge = [...
   uicontrol('parent',hfig,'backgroundcolor',lcolor,'style','text','enable','off');...
   uicontrol('parent',hfig,'backgroundcolor',color,'style','text','enable','off')];
this.TabRightEdge = [...
   uicontrol('parent',hfig,'backgroundcolor',dcolor,'style','text','enable','off');...
   uicontrol('parent',hfig,'backgroundcolor',mcolor,'style','text','enable','off')];
this.TabTopEdge = [...
   uicontrol('parent',hfig,'backgroundcolor',color,'style','text','enable','off');...
   uicontrol('parent',hfig,'backgroundcolor',lcolor,'style','text','enable','off')];

% Enable=inactive so that buttondown event is trapped
this.Label = uicontrol('parent',hfig,'Horiz','center',...
   'BackgroundColor',color,'Style','text','enable','inactive');


function LocalLayoutPanel(eventsrc,eventdata)
% Reposition objects making up the selected panel
layout(eventdata.AffectedObject)