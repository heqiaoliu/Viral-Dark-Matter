function mRoot = addHSVMenu(this,menuType)
%ADDHSVMENU  Install HSV-specific response plot menus.

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:56 $
AxGrid = this.AxesGrid;

switch menuType
   
case 'yscale'
   % Y scale
   OnOff = {'on';'off'};
   Select = strcmp(AxGrid.YScale,{'linear','log'});
   mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
      'Label',xlate('Y Scale'),'Tag','yscale');
   mSub1 = uimenu('Parent',mRoot,...
      'Label',xlate('Linear'),...
      'Checked',OnOff{Select});
   set(mSub1,'Callback',@(x,y) LocalToggleScale(mSub1,1,AxGrid));
   mSub2 = uimenu('Parent',mRoot,...
      'Label',xlate('Log'),...
      'Checked',OnOff{~Select});
   set(mSub2,'Callback',@(x,y) LocalToggleScale(mSub2,2,AxGrid));
   L = handle.listener(AxGrid,AxGrid.findprop('YScale'),...
      'PropertyPostSet',@(x,y) LocalUpdateCheck([mSub1;mSub2],AxGrid));
   set(mRoot,'UserData',L)
   
end


%-------------------- Local Functions ---------------------------

function LocalToggleScale(Menu,Type,AxGrid)
% Zoom on critical point
if strcmp(get(Menu,'Checked'),'off')
   if Type==1
      AxGrid.YScale = 'linear';
   else
      AxGrid.YScale = 'log';
   end
end   

function LocalUpdateCheck(hSub,AxGrid)
if strcmp(AxGrid.YScale,'linear')
   set(hSub,{'Checked'},{'on';'off'})
else
   set(hSub,{'Checked'},{'off';'on'})
end   