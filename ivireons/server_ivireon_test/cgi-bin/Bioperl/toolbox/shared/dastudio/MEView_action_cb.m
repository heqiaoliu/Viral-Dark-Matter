function MEView_action_cb(id)

%   Copyright 2009-2010 The MathWorks, Inc.

root   = DAStudio.Root;
action = find(root, '-isa', 'DAStudio.Action', 'id', id);

if isempty(action)
    return;
end;

% extract needed callback data from the action
fcn  = action.callbackData{1};

if strcmpi(action.toggleAction, 'on')
     actionName = action.callbackData{1};        
         % extract needed callback data from the action
         propName = actionName;
         propObj  = action.callbackData{2};

         if strcmpi(action.on, 'on')
             propObj.(propName) = true;
         else
             propObj.(propName) = false;
         end
else
    % execute whatever action is being requested
    switch (fcn)
        case 'hide'        
            view = action.callbackData{4};
            prop = action.callbackData{2};            
            prop.isVisible = false;
            if strcmp(prop.Name, view.GroupName)
                view.GroupName = '';
            end
            
        case {'insertPath' 'insertHidden'}
            prop = action.callbackData{2};
            propertyAfter = action.callbackData{3};
            view = action.callbackData{4};
            allProps = view.Properties;
            props = get(view.Properties, 'Name');
            % Remove it from existing location.
            removeIndex = strmatch(prop.Name, props);
            allProps(removeIndex) = [];            
            props = get(allProps, 'Name');
            % Special case when context menu is on icon/name column
            if strcmp(propertyAfter, 'Name')
                allProps = [prop; allProps];
            elseif strcmp(propertyAfter, ' ') % icon column
                allProps = [prop; allProps];
            elseif isempty(propertyAfter)
                allProps = [allProps; prop];
            else  
                afterIndex = strmatch(propertyAfter, props, 'exact');
                allProps = [allProps(1:afterIndex); prop; allProps(afterIndex+1:end)];
            end
            view.Properties = allProps;            
            prop.IsVisible = true;
            prop.isTransient = false;

        case 'groupBy'
            groupName = action.callbackData{2};
            view = action.callbackData{3};
            view.GroupName = groupName;             
    
        case 'removeGrouping'
            view = action.callbackData{2};
            view.GroupName = '';
            
        otherwise
            error('DAStudio:UnknownAction', 'unknown action');
     end
end
