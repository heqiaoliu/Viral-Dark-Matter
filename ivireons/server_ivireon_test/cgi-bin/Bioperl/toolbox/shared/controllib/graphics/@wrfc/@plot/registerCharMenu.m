function registerCharMenu(this,CharMenu)
%registerCharMenu Creates characteristics menu items parented to
% CharMenu and is linked to the CharacteristicManager of the plot

%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $   $Date: 2010/04/11 20:36:31 $


localUpdateCharMenu(this,CharMenu)
set(CharMenu,'UserData',handle.listener(this, ...
    this.findprop('CharacteristicManager'),'PropertyPostSet', ...
    @(x,y) localUpdateCharMenu(this,CharMenu)));
end

function localUpdateCharMenu(this,CharMenu)
% Updates the Characteristics Menu

SubMenus = get(CharMenu,'Children');
if isempty(this.CharacteristicManager)
    CharIdx = [];
else
    CharIdx = find(strcmp('Characteristic',{this.CharacteristicManager.CharacteristicGroup}));
end
numChars = length(CharIdx);
numSubMenus = length(SubMenus);


if numSubMenus > numChars
    % Remove menu items
    delete(SubMenus(numSubMenus+1:end))
else
    % Add submenus
    for ct = 1:(numChars-numSubMenus)
        uimenu('Parent',CharMenu,...
            'Callback',@(x,y) localMenuCallback(x,this));
    end
end

SubMenus = get(CharMenu,'Children');
CharManager = this.CharacteristicManager;
for ct2 = 1:numChars
    set(SubMenus(ct2),...
        'Label',CharManager(CharIdx(ct2)).CharacteristicLabel, ...
        'Checked', localLogicalToOnOff(CharManager(CharIdx(ct2)).Visible),...
        'Visible', localLogicalToOnOff(~isempty(CharManager(CharIdx(ct2)).Waveforms)), ...
        'Tag', CharManager(CharIdx(ct2)).CharacteristicID)
end

end

function value = localLogicalToOnOff(VisState)
% Convert logical to on/off
if VisState
    value = 'on';
else
    value = 'off';
end
end


function localMenuCallback(es,this)
% Show/hide characteristic characteristic
m = es;  % menu handle
if strcmp(get(m,'checked'),'on');
    this.hideCharacteristic(get(es,'Tag'));
else
    this.showCharacteristic(get(es,'Tag'));
end
end

