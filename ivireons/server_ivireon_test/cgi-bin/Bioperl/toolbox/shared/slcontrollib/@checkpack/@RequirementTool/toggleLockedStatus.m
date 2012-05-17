function toggleLockedStatus(this) 
% TOGGLELOCKEDSTATUS
%
 
% Author(s): A. Stothert 17-Dec-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:50:48 $

wasLocked = this.isLocked;
this.isLocked = ~this.isLocked;

%Get the UI mgr so we can set widget properties appropriately
uiMgr = this.Application.getGUI;

%Set the locked widget correctly
hMenu = uiMgr.findchild('Base/Menus/Edit/Bounds/UnlockBound').WidgetHandle;
hButton = uiMgr.findchild('Base/Toolbars/Playback/Bounds/UnlockBound').WidgetHandle;
if this.isLocked, 
   set(hMenu,'Checked','off');
   set(hButton,'State','off', 'CData', getappdata(uiMgr,'signal_locked'));
else
   set(hMenu,'Checked','on'); 
   set(hButton,'State','on','CData', getappdata(uiMgr,'signal_unlocked'));
end

%If we installed context menus set them appropriately
if this.isLocked, enable = 'off'; 
else enable = 'on'; end
if ~isempty(this.hContextMenus)
   set(this.hContextMenus.cmUnlock,'Checked',enable);
   set(this.hContextMenus.cmNewBound,'Enable',enable);
   set(this.hContextMenus.cmEditBound,'Enable',enable);
end

%If there are any displayed bounds set their locked state appropriately
if ~isempty(this.hReq)
   set(this.hReq,'isLocked',this.isLocked)
   if ~wasLocked
      this.updateBlockBounds
   end
end
end