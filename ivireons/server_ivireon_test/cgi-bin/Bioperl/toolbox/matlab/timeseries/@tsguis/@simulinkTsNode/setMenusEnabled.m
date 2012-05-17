function setMenusEnabled(h,manager)

% Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $ $Date: 2005/07/14 15:25:48 $

if strcmp(class(h.up),'tsguis.simulinkTsParentNode')
    menutags = {'ts.shift','ts.select'};
else
    menutags = {'ts.shift','ts.select','ts.delete'};
end

allmenuTags = get(manager.Menus,{'Tag'});
set(manager.Menus(ismember(allmenuTags,menutags)),'Enable','off')
set(manager.Menus(~ismember(allmenuTags,menutags)),'Enable','on')

allToolBarTags = get(manager.ToolbarButtons,{'Tag'});
set(manager.ToolbarButtons(ismember(allToolBarTags,menutags)),'Enable','off')
set(manager.ToolbarButtons(~ismember(allToolBarTags,menutags)),'Enable','on')


