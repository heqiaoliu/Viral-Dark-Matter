function setMenusEnabled(h,manager)

% Copyright 2004-2006 The MathWorks, Inc.

if isa(h,'tsguis.tsseriesview')
    menutags = {'ts.arith','ts.export'};
else
    menutags = {'ts.arith','ts.select','ts.export'};
end
allmenuTags = get(manager.Menus,{'Tag'});
set(manager.Menus(ismember(allmenuTags,menutags)),'Enable','off')
set(manager.Menus(~ismember(allmenuTags,menutags)),'Enable','on')

allToolBarTags = get(manager.ToolbarButtons,{'Tag'});
set(manager.ToolbarButtons(ismember(allToolBarTags,menutags)),'Enable','off')
set(manager.ToolbarButtons(~ismember(allToolBarTags,menutags)),'Enable','on')
