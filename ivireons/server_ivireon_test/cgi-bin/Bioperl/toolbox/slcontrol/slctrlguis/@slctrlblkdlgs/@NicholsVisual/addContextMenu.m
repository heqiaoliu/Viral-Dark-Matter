function addContextMenu(this) 
% ADDCONTEXTMENU create context menus for visualization
%
 
% Author(s): A. Stothert 10-Dec-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:09 $

%Get handle to the plot
hplot = this.hPlot;

% Group #1
hmenu.Systems = hplot.addMenu('responses','Label',xlate('Systems'));
hmenu.Characteristics = hplot.addMenu('characteristics');
hmenu.Requirements = uimenu('Parent',hplot.AxesGrid.UIContextMenu, ...
   'Label', ctrlMsgUtils.message('SLControllib:checkpack:menuBounds'), 'Tag', 'DesignRequirement');

% Install listener to track responses added or deleted to update
% characteristics.
set(hmenu.Characteristics,...
   'UserData',handle.listener(hplot,hplot.findprop('Responses'),...
   'PropertyPostSet',@(x,y) LocalCharCallback(y,hmenu.Characteristics,hplot)));

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

%Install characteristics submenus
lticharmenu(hplot,hmenu.Characteristics,'nichols');

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

function LocalCharCallback(eventdata,CharMenuHandle,hplot)
%  Listener Callback applies characteristics for systems imported through
%  the LTIVIEWER of in the hold mode.
subMenus=get(CharMenuHandle,'Children');
ch = subMenus(strcmp('on',get(subMenus,'checked')));
if ~isempty(eventdata.NewValue)
   wf = find(eventdata.NewValue,'Characteristics',[]);
   for ct = 1:length(ch)
      for  ctwf = 1:length(wf)
         args = get(ch(ct),'UserData');
         try %#ok<TRYNC>
            % RE: Creation may fail due to size incompatibility, cf. stability
            %     margins on plot with mix of SISO and MIMO systems
            wfChar = wf(ctwf).addchar(args{:});
            applyOptions(wfChar.Data,hplot.Options); % initialize parameters
         end
      end
   end
end
end




