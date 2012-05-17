function setMenusEnabled(h,manager)

% Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2005/07/14 15:26:49 $

menutags = {'ts.shift','ts.select','ts.merge'};
allmenuTags = get(manager.Menus,{'Tag'});

%% Show menus
set(manager.Menus(ismember(allmenuTags,menutags)),'Enable','off')
set(manager.Menus(~ismember(allmenuTags,menutags)),'Enable','on')

%% Show toolbar buttons
allToolBarTags = get(manager.ToolbarButtons,{'Tag'});
set(manager.ToolbarButtons(ismember(allToolBarTags,menutags)),'Enable','off')
set(manager.ToolbarButtons(~ismember(allToolBarTags,menutags)),'Enable','on')

%% Only show Arithmetic menu if this node has @tsnode children
if length(h.getChildren)>=1 
    set(manager.Menus(ismember(allmenuTags,'ts.arith')),'Enable','on')
    set(manager.Menus(ismember(allToolBarTags,'ts.arith')),'Enable','on')
else
    set(manager.Menus(ismember(allmenuTags,'ts.arith')),'Enable','off')
    set(manager.Menus(ismember(allToolBarTags,'ts.arith')),'Enable','off')
end
