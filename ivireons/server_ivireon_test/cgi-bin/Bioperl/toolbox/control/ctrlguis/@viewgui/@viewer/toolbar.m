function toolbar(this)
%TOOLBAR  Creates the tool bar.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.4 $  $Date: 2010/02/08 22:29:55 $

load viewIconCData;

htoolbar = uitoolbar(this.Figure,'HandleVisibility','off');
% Create menu bar icons and associated callbacks.
b(1) = uipushtool(htoolbar,...
    'Tooltip',xlate('New Viewer'),...
    'CData',newfigCData,...
    'Tag','newViewer',...
    'ClickedCallback','ltiview');
b(2) = uipushtool(htoolbar,...
    'Tooltip',xlate('Print'),...
    'CData',printCData,...
    'Tag','printfigure',...
        'ClickedCallback',{@LocalPrint this});
b(3) = uitoolfactory(htoolbar,'Exploration.ZoomIn');
set(b(3),'Separator','on');
b(4) = uitoolfactory(htoolbar,'Exploration.ZoomOut');

b(5) = uitoolfactory(htoolbar,'Annotation.InsertLegend');
set(b(5),'Separator','on');     

% Store the toolbar if it is needed for later
this.HG.Toolbar = htoolbar;

function LocalPrint(eventsrc,eventdata,this)
% LocalPrint push button callback
print(this,'printer')
