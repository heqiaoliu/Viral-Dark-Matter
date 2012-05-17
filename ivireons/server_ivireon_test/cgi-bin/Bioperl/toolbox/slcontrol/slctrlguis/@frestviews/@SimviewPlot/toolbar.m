function toolbar(this)
%  TOOLBAR creates the toolbar for simView figure
%


% Author(s): Erman Korkut 26-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2009/04/21 04:49:55 $

load viewIconCData;

htoolbar = uitoolbar(this.Figure,'HandleVisibility','off');
% Create menu bar icons and associated callbacks.
b(1) = uipushtool(htoolbar,...
    'Tooltip',ctrlMsgUtils.message('Slcontrol:frest:strPrint'),...
    'CData',printCData,...
    'Tag','printfigure',...
        'ClickedCallback',{@LocalPrint this});
b(2) = uitoolfactory(htoolbar,'Exploration.ZoomIn');
set(b(2),'Separator','on');
b(3) = uitoolfactory(htoolbar,'Exploration.ZoomOut');


function LocalPrint(eventsrc,eventdata,this)
% LocalPrint push button callback
print(this)



