function setMenusEnabled(h,manager)

% Copyright 2004-2005 The MathWorks, Inc.

menutags = {'ts.copy','ts.paste','ts.delete','ts.shift','ts.select','ts.merge',...
    'ts.data','ts.arith','ts.export'};
allmenuTags = get(manager.Menus,{'Tag'});
set(manager.Menus(ismember(allmenuTags,menutags)),'Enable','off')
set(manager.Menus(~ismember(allmenuTags,menutags)),'Enable','on')

allToolBarTags = get(manager.ToolbarButtons,{'Tag'});
set(manager.ToolbarButtons(ismember(allToolBarTags,menutags)),'Enable','off')
set(manager.ToolbarButtons(~ismember(allToolBarTags,menutags)),'Enable','on')
