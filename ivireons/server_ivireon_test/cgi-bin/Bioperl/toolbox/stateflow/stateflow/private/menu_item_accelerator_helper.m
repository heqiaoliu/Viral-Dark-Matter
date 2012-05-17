function ret = menu_item_accelerator_helper( command, key )
% Helper to correctly dispatch accelerator keys for menu items

%  Copyright 2005-2008 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2008/12/01 08:06:43 $

persistent sobj;

if nargin > 2
    return;
end

ret = false;

switch command
    case 'enter'
        prevState = get(0, 'ShowHiddenHandles');
        set(0, 'ShowHiddenHandles', 'on');
        obj = findobj(gcf, 'Type', 'uimenu', 'Accelerator', key);
        if ~isempty(obj)
            obj = obj(1);
            if strcmp(get(obj, 'Enable'), 'off')
                sobj = obj;
                ret = true;
            end
        end
        set(0, 'ShowHiddenHandles', prevState);

    case 'exit'
        sobj = [];

    case 'getmenu'
        ret = sobj;

end
