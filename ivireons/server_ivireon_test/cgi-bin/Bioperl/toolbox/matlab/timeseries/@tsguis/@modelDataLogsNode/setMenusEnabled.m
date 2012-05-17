function setMenusEnabled(h,manager)

% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2005/07/14 15:25:10 $

menutags = {'ts.copy','ts.paste','ts.shift','ts.select',...
    'ts.merge','ts.data','ts.remove','ts.filter','ts.detrend'};
if ~strcmp(class(h.up),'tsguis.simulinkTsParentNode')
    menutags{end+1} = 'ts.delete';
end


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
