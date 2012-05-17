function hmenu = ltiplotmenu(hplot,plotType) 
%LTIPLOTMENU  Constructs right-click menus for LTI response plots. 

%  Author(s): James Owen 
%  Revised:   Kamesh Subbarao
%   Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.23.4.10 $ $Date: 2010/04/11 20:29:39 $ 

%Create a group of context menu items appropriate for the plotType. 
%Note hplot is a @respplot object. Return a structure with fields set  
%to the appropriate meu handles for each item 
     
AxGrid = hplot.AxesGrid;
hmenu = struct(...
   'Systems',[],...
   'Characteristics',[], ...
   'Group1', []);

% Group #1: Data contents (waves & characteristics)
hmenu.Systems = hplot.addMenu('responses','Label',xlate('Systems'));
grp1 = hmenu.Systems;

if ~strcmp(plotType,{'pzmap','rlocus','margin','iopzmap'})
   % Create a Characteristics menu
   hmenu.Characteristics = hplot.addMenu('characteristics');
   grp1(end+1) = hmenu.Characteristics;
   hplot.registerCharMenu(hmenu.Characteristics)
end

switch plotType
   case 'bode'
      % Show mag/phase
      grp1(end+1) = hplot.addBodeMenu('show');
   case 'nyquist'
      % Show negative frequency
      grp1(end+1) = hplot.addNyquistMenu('show');
   case 'lsim'
      % Show input signal
      grp1(end+1) = hplot.addSimMenu('show');
end

hmenu.Group1 = grp1;


% Group #2: Axes configuration, I/O and model selectors
grp2 = [...
   hplot.addMenu('iogrouping'); ...
   hplot.addMenu('ioselector'); ...
   hplot.addMenu('arrayselector')];
LocalUpdateVis(AxGrid,grp2)  % initialize menu visibility
% Install listener to track plot size and update menu visibility
set(grp2(2),'UserData',handle.listener(AxGrid,...
   AxGrid.findprop('Size'),'PropertyPostSet',@(x,y) LocalUpdateVis(AxGrid,grp2)))

% Group #3: Annotation and Focus
AxGrid.addMenu('grid','Separator','on');

% Zoom and full view
switch plotType
   case 'nyquist'
      % Show mag/phase
      hplot.addNyquistMenu('zoomcritical');
   case {'step','impulse','lsim','initial'}
      hplot.addMenu('normalize');
end
hplot.addMenu('fullview');

% Add properties menu
switch plotType
   case 'lsim'
      grp3 = [...
         handle(hplot.addSimMenu('lsimdata'));...
         handle(hplot.addSimMenu('lsiminit'))];
   case 'initial'
      grp3 = handle(hplot.addSimMenu('lsiminit'));
   otherwise
      grp3 = [];
end
grp3 = [grp3 ; handle(hplot.addMenu('properties'))];
set(grp3(1),'Separator','on');

%------------------ Local Functions -----------------------------

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


