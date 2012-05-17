function addContextMenu(this) 
% ADDCONTEXTMENU create context menus for visualization
%
 
% Author(s): A. Stothert 10-Dec-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:16 $

%Get handle to the plot
hplot = this.hPlot;

% Group #1
hmenu.Systems = hplot.addMenu('responses','Label',xlate('Systems'));
hmenu.Requirements = uimenu('Parent',hplot.AxesGrid.UIContextMenu, ...
   'Label', ctrlMsgUtils.message('SLControllib:checkpack:menuBounds'), 'Tag', 'DesignRequirement');

% Group #2: Axes configuration, I/O and model selectors
grp2 = [...
   hplot.addMenu('iogrouping'); ...
   hplot.addMenu('ioselector'); ...
   hplot.addMenu('arrayselector')];
LocalUpdateVis(hplot.AxesGrid,grp2)  % initialize menu visibility
% Install listener to track plot size and update menu visibility
set(grp2(2),'UserData',handle.listener(hplot.AxesGrid,...
   hplot.AxesGrid.findprop('Size'),'PropertyPostSet',@(x,y) LocalUpdateVis(hplot.AxesGrid,grp2)))

% Group #3: Annotation and Focus
hplot.AxesGrid.addMenu('grid','Separator','on');
hplot.addMenu('fullview');
hplot.addMenu('properties','Separator','on');

%By default hide requirements menu
set(hmenu.Requirements,'Visible','off');

%Store menu handles;
this.hMenu = hmenu;
end

function LocalUpdateVis(AxGrid,MenuHandles)
% Initializes and updates visibility of "MIMO" menus
set(MenuHandles,'Separator','off')
if prod(AxGrid.Size([1 2]))==1
   set(MenuHandles(1:2),'Visible','off')
   set(MenuHandles(3),'Separator','on')
else
   set(MenuHandles(1:2),'Visible','on')
   set(MenuHandles(1),'Separator','on')
end
% I/O grouping options
subMenus = get(MenuHandles(1),'Children');
if all(AxGrid.Size([1 2])>1)
   set(subMenus([1 2]),'Visible','on')
else
   set(subMenus([1 2]),'Visible','off')
end
end