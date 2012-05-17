function dfadjustmenu(dffig)
%DFADJUSTMENU Adjust contents of curve fit plot menus

%   $Revision: 1.1.8.2 $  $Date: 2010/04/24 18:31:43 $
%   Copyright 2003-2007 The MathWorks, Inc.

% Remove some menus entirely
h = findall(dffig, 'Type','uimenu', 'Parent',dffig);
removelist = {'figMenuEdit' 'figMenuInsert' 'figMenuDesktop'};
for j=1:length(removelist)
   h0 = findall(h,'flat', 'Tag',removelist{j});
   if (~isempty(h0))
      delete(h0);
      h(h==h0) = [];
   end
end

% Add or remove some items from other menus
% Fix FILE menu
h0 = findall(h,'flat', 'Tag','figMenuFile');
h1 = findall(h0, 'Type','uimenu', 'Parent',h0);
for j=length(h1):-1:1
   mtag = get(h1(j),'Tag');
   mlabel = get(h1(j),'Label');
   if isequal(mtag,'figMenuFileClose')
      m7 = h1(j);
      set(m7,'Label','&Close Distribution Fitting','Tag','dfitMenuClose')
   elseif ~isempty(findstr(mlabel,'Print...')) % it has no tag
      m5 = h1(j);
   else
      delete(h1(j));
      h1(j) = [];
   end
end
uimenu(h0, 'Label','&Import Data...', 'Position',1,...
      'Callback','dfittool(''import data'')', 'Tag','dfitMenuImportData');
uimenu(h0, 'Label','Clea&r Session','Position',2,...
       'Callback','dfittool(''clear session'')','Separator','on', ...
       'Tag','dfitMenuImportClearSession');
uimenu(h0, 'Label','&Load Session...', 'Position',3,...
      'Callback','dfittool(''load session'')', 'Tag','dfitMenuLoadSession');
uimenu(h0, 'Label','&Save Session...', 'Position',4,...
           'Callback','dfittool(''save session'')', 'Tag','dfitMenuSaveSession');
uimenu(h0, 'Label','&Generate Code...', 'Position',5,...
           'Callback','dfittool(''generate code'')', 'Tag','dfitMenuGenCode');

uimenu(h0, 'Label','&Define Custom Distributions...','Position',6,...
           'Callback',{@dfcustomdist,'define'}','Separator','on', ...
           'Tag','dfitMenuDefineCustom');
uimenu(h0, 'Label','I&mport Custom Distributions...', 'Position',7, ...
           'Callback',{@dfcustomdist,'import'},'Tag','importcustom');
uimenu(h0, 'Label','Cl&ear Custom Distributions...', 'Position',8,...
           'Callback',{@dfcustomdist,'clear'},'Tag','clearcustom');


set(m5,'Position',9,'Separator','on');
uimenu(h0, 'Label','Print to &Figure', 'Position',10,...
           'Callback','dfittool(''duplicate'')', 'Tag','dfitMenuPrint2Fig');
set(m7,'Position',11,'Separator','on');

% Fix VIEW menu
h0 = findall(h,'flat', 'Tag','figMenuView');
h1 = findall(h0, 'Type','uimenu', 'Parent',h0);
delete(h1);
uimenu(h0, 'Label','&Legend', 'Position',1,'Separator','off',...
           'Callback','dfittool(''togglelegend'')', 'Checked','on',...
           'Tag','showlegend');
dfgetset('showlegend','on');
uimenu(h0, 'Label','&Grid', 'Position',2,...
           'Callback','dfittool(''togglegrid'')', 'Checked','off', ...
           'Tag','showgrid');
dfgetset('showgrid','off');
h1 = uimenu(h0, 'Label','C&onfidence Level','Position',3,'Separator','on');
uimenu(h1, 'Label','9&0%', 'Position',1, ...
           'Callback','dfittool(''setconflev'',.90)','Tag','conflev90');
uimenu(h1, 'Label','9&5%', 'Position',2, 'Checked','on',...
           'Callback','dfittool(''setconflev'',.95)','Tag','conflev95');
uimenu(h1, 'Label','9&9%', 'Position',3, ...
           'Callback','dfittool(''setconflev'',.99)','Tag','conflev99');
uimenu(h1, 'Label','&Other...', 'Position',4, ...
           'Callback','dfittool(''setconflev'',[])','Tag','conflevOther');
dfgetset('conflev',0.95);
uimenu(h0, 'Label','&Clear Plot', 'Position',4,...
           'Callback','dfittool(''clear plot'')', 'Tag','dfitMenuClearPlot');

% Fix TOOLS menu
h0 = findall(h,'flat', 'Tag','figMenuTools');
h1 = findall(h0, 'Type','uimenu', 'Parent',h0);
for j=length(h1):-1:1
   mlabel = get(h1(j),'Label');
   mlabel(mlabel=='&') = [];
   if isempty(findstr(mlabel,'Zoom')) && isempty(findstr(mlabel,'Pan'))
     delete(h1(j));
     h1(j) = [];
   else
      set(h1(j),'Separator','off');
   end
end
uimenu(h0, 'Label','&Axes Limit Control', 'Position',4, 'Separator','on', ...
           'Callback','dfittool(''toggleaxlimctrl'')', 'Checked','off', ...
           'Tag','showaxlimctrl');
dfgetset('showaxlimctrl','off');
uimenu(h0, 'Label','&Default Axes Limits', 'Position',5, ...
           'Callback','dfittool(''defaultaxes'')', 'Tag','dfitMenuDefaultAxes');
uimenu(h0, 'Label','Set Default &Bin Rules', 'Position',6, 'Separator','on', ...
           'Callback', @setDefaultBinWidthRules, 'Tag','setbinrules');
           

% Fix HELP menu
h0 = findall(h,'flat', 'Tag','figMenuHelp');
h1 = findall(h0, 'Type','uimenu', 'Parent',h0);
delete(h1);
uimenu(h0, 'Label','Statistics &Toolbox Help', 'Position',1,'Callback',...
       'doc stats', 'Tag','dfitMenuHelpTbx');
uimenu(h0, 'Label', 'Distribution &Fitting Tool Help', 'Position',2,'Callback',...
        'dfswitchyard(''dfhelpviewer'', ''distribution_fitting'', ''dfittool'')', ...
        'Tag','dfitMenuHelpDfit');
uimenu(h0, 'Label','&Demos', 'Position',3,'Separator','on','Callback',...
       'demo toolbox stat', 'Tag','dfitMenuDemos'); 

% ------------------------------------

function setDefaultBinWidthRules(varargin)
% SETDEFAULTBINWITHRULES Callback for Set Default Bin Rules

binWidth = awtinvoke('com.mathworks.toolbox.stats.BinWidth', 'getBinWidth');
awtinvoke(binWidth, 'displayDefaultBinWidth');