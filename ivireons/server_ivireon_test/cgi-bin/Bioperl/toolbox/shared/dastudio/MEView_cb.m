function varargout = MEView_cb(dlg, fcn, varargin)

%   Copyright 2009-2010 The MathWorks, Inc.

if ~isempty(dlg)
manager = dlg.getSource();
end

switch (fcn)
    case 'doFilterProperties'
        if usejava('jvm')
            t = timerfind('Name', 'MEViewTimer');
            if isempty(t)
                t = timer('Name', 'MEViewTimer');
                t.StartDelay = .200;
                t.TimerFcn   = {@doFilterPropertiesTimerFcn, dlg};
            end        
            stop(t);
            start(t);        
        else
            if ishandle(dlg)
                dlg.refresh;
            end
        end
        
    case 'doAdd'        
        view = varargin{1};
        doAdd(dlg, view);
    
    case 'doRemove'
        view = varargin{1};
        doRemove(dlg, view);
        
    case 'doUp'
        view = varargin{1};
        doUp(dlg, view);
        
    case 'doDown'
        view = varargin{1};
        doDown(dlg, view);
        
    case 'doReorderProperties'
        view          = varargin{1};
        proposedOrder = varargin{2};
        
        doReorderProperties(dlg, view, proposedOrder);
        
    case 'doEnableDisableButtons'        
        view = manager.ActiveView;
        if ~isempty(view.Properties)
            allProps = find(view.Properties, 'isVisible', true, 'isTransient', false);
            % Enable disable up/down buttons
            rows = dlg.getSelectedTableRows('view_columns_table');    
            % Enable disable up/down buttons
            % Use same logic which we used for up and down move.
            tempRows = int32(rows) - 1; 
            dlg.setEnabled('view_up_button', isempty(find(tempRows < 0, 1)))
            tempRows = rows + 1;
            dlg.setEnabled('view_down_button', isempty(find(tempRows > (length(allProps) - 1), 1)));
        end
        
    case 'doAddProperty'
        view = varargin{1};
        property = varargin{2};
        location = varargin{3};
        doAddProperty(view, property, location);
        
    otherwise
        error('DAStudio:UnknownAction', 'unknown action');
end

%
%
%
function doFilterPropertiesTimerFcn(t, ~, dlg)
if usejava('jvm')
% clean up the timer
stop(t);
   %delete(t);
% update the view manager ui
if ishandle(dlg)
    dlg.refresh;
end
end


%
% Add properties to the view.
%
function doAdd(dlg, view)
% don't bother doing anything if the edit text & list selection is empty
text     = dlg.getWidgetValue('view_search_edit');
indices  = dlg.getWidgetValue('view_properties_list') + 1;
if isempty(text) && isempty(indices)
    return;
else
    % If there is a text, it should be a valid matlab name.
    if ~isempty(text) && ~isValidPropertyName(text)
        return;
    end
end

% find out what properties we want to add (list selection takes precedence)
if ~isempty(indices)
    imd   = DAStudio.imDialog.getIMWidgets(dlg);
    list  = imd.find('Tag', 'view_properties_list');
    items = list.getListItems;
    props = items(indices);
else
    props = {strtrim(text)};
end
% Add property after selected row. In the case of multi-select, it is after
% the last selection.
rows = dlg.getSelectedTableRows('view_columns_table');
viewProperties = [];
if isempty(view.Properties)
    % Take shortcut    
    for i = 1:length(props)
       viewProperties = [viewProperties; DAStudio.MEViewProperty(props{i})];
    end
    % refresh the ME
    view.Properties = viewProperties;
    return;
end
% Remove properties which need reordering
view.disableLiveliness;
viewProperties = view.Properties;
propNames = get(viewProperties, 'Name');
for i = 1:length(props)
    k = strmatch(lower(props{i}), lower(propNames), 'exact');
    if ~isempty(k)
        if ~viewProperties(k).isVisible || viewProperties(k).isTransient
            viewProperties(k) = [];
            propNames = get(viewProperties, 'Name');
            if isempty(propNames)
                break;
            end
        end
end           
end
% Now add requested properties
index = 0;
propNames = get(viewProperties, 'Name');
if ~isempty(rows)
   visProperties = find(view.Properties, 'isVisible', true, 'isTransient', false);
   propertyAfter = visProperties(rows(end)+1).Name;
   index = strmatch(lower(propertyAfter), lower(propNames), 'exact');
end
vProps = viewProperties(1:index);
for j = 1:length(props)
    k = strmatch(lower(props{j}), lower(propNames), 'exact');
    if isempty(k)
        vProps = [vProps; DAStudio.MEViewProperty(props{j})];
    end
end
vProps = [vProps; viewProperties(index+1:end)];
% refresh the ME
view.enableLiveliness;
    view.Properties = vProps;
% Select the last property added
viewProperties = find(view.Properties, 'isVisible', true, 'isTransient', false);
viewProperties = get(viewProperties, 'Name');
index = strmatch(lower(char(props{end})), lower(viewProperties), 'exact');
dlg.selectTableRow('view_columns_table', index - 1);
MEView_cb(dlg, 'doEnableDisableButtons');

%
%
% doRemove
%
% Remove property from the view.
%
function doRemove(dlg, view)
% don't bother doing anything if the table selection is empty
rows = dlg.getSelectedTableRows('view_columns_table');
if isempty(rows) || isempty(view.Properties)
    return;
end

% TODO: Can we avoid copy to refresh UI? Direct manipulation does not
% amount to any change.
view.disableLiveliness;
viewProperties = copy(view.Properties);
visibleProperties = find(viewProperties, 'isVisible', true, 'isTransient', false);
props = cell(length(rows), 1);
for i = 1:length(rows)
    props{i} = visibleProperties(rows(i)+1);
end
for i = 1:length(props)
    props{i}.isVisible = false;
    if strcmp(props{i}.Name, view.GroupName)
        view.GroupName = '';
    end
end
view.enableLiveliness;
% refresh the ME
view.Properties = viewProperties;
MEView_cb(dlg, 'doEnableDisableButtons');

%
% Move property up
%
function doUp(dlg, view)
% Return if view does not have anything
if isempty(view.Properties)
    return;
end
rows = dlg.getSelectedTableRows('view_columns_table');
% Before continuing, validate
tempRows = int32(rows) - 1;
if isempty(find(tempRows < 0, 1))
    % We can move.
    propsToMove = cell(length(rows), 2);
    visProperties = find(view.Properties, 'isVisible', true, 'isTransient', false);
    for i = 1:length(rows)
        propToMove = visProperties(rows(i) + 1).Name;
        rowToMoveBefore = rows(i) - 1;
        if ~isempty(find(rows == rowToMoveBefore))
            rowToMoveBefore = rows(1) - 1;
        end
        propToMoveBefore = visProperties(rowToMoveBefore + 1).Name;        
        propsToMove{i,1} = propToMove;
        propsToMove{i,2} = propToMoveBefore;        
    end
    % Move
    view.disableLiveliness;
     vProps = view.Properties;
    if length(rows) == 1
         vProps = swapProperties(vProps, propsToMove{1}, propsToMove{2});          
    else
        num = length(propsToMove);
        for i = 1:num
            vProps = swapProperties(vProps, char(propsToMove{i, 1}), char(propsToMove{i, 2}));            
        end
    end    
    view.enableLiveliness;
     view.Properties = vProps;
    dlg.selectTableRows('view_columns_table', double(rows-1));
end
MEView_cb(dlg, 'doEnableDisableButtons');


%
% Move property down
%
function doDown(dlg, view)
% Return if view does not have anything
if isempty(view.Properties)
    return;
end
rows = dlg.getSelectedTableRows('view_columns_table');
% First validate.
tempRows = rows(end:-1:1);
% Moving down so add 1 to each row.
tempRows = tempRows + 1;
allProps = find(view.Properties, 'isVisible', true, 'isTransient', false);
% If we do not have invalid row, move.
if isempty(find(tempRows > (length(allProps) - 1), 1))
    % We can move.
    propsToMove = cell(length(rows), 2);
    for i = 1:length(rows)
        propToMove = allProps(rows(i) + 1).Name;        
        rowToMoveAfter = rows(i) + 1;
        if ~isempty(find(rows == rowToMoveAfter))
            rowToMoveAfter = rows(end) + 1;
        end
        propToMoveAfter = allProps(rowToMoveAfter + 1).Name;        
        propsToMove{i,1} = propToMove;
        propsToMove{i,2} = propToMoveAfter;        
    end
    % Move
    view.disableLiveliness;
    vProps = view.Properties;    
    if length(rows) == 1
         vProps = swapProperties(vProps, propsToMove{1}, propsToMove{2});          
    else
        num = length(propsToMove);
        for i = 1:num
            vProps = swapProperties(vProps, char(propsToMove{num-i+1, 1}), ...
                            char(propsToMove{num-i+1, 2}));
        end
    end    
    view.enableLiveliness;
    view.Properties = vProps;
    dlg.selectTableRows('view_columns_table', double(rows+1));
end
MEView_cb(dlg, 'doEnableDisableButtons');

%
%
%
function doReorderProperties(dlg, view, proposedOrder, sideeffects)
acceptedOrder = proposedOrder;

% let the accepted order be the proposed order with Name first
aIndex = strmatch('Name', acceptedOrder, 'exact');
if isempty(aIndex)
    aIndex = 1;
else
    acceptedOrder(aIndex) = [];
    acceptedOrder = ['Name'; acceptedOrder];
    aIndex = 2; % account for Name being first column
end
view.disableLiveliness;
% rearrange the current properties list to reflect the accepted columns
props  = view.Properties;
for i = 1:length(props)
    prop = props(i);
    if prop.isVisible
        if ~strcmp(prop.Name, acceptedOrder{aIndex})
            pIndex = strmatch(acceptedOrder{aIndex}, get(props, 'Name'), 'exact');
            pObj   = find(props, 'Name', acceptedOrder{aIndex});
            
            % remove
            props(pIndex) = [];
            
            % insert
            props = [props(1:i-1); pObj; props(i:end)]; 
        end
        
        aIndex = aIndex + 1;
    end
end
view.Properties = props;
view.enableLiveliness;
    
if ~view.ViewManager.IsCollapsed
    % update the view manager UI
    dlg.refresh;
end

%
%
function valid = isValidPropertyName(prop)
%
% Is this a valid property name?
% Alpha then alphanumeric, dots, spaces, parenthesis are allowed.
% 
valid = ~isempty(regexpi(prop,'^[a-z_][.\(\)\w\s]*$','once'));


%
% Swap two properties in properties array.
%
function props = swapProperties(vProps, p1, p2)
viewProperties = get(vProps, 'Name');    
id1 = strmatch(p1, viewProperties, 'exact');
id2 = strmatch(p2, viewProperties, 'exact');
tempProperty = vProps(id1);         
vProps(id1) = vProps(id2);
vProps(id2) = tempProperty; 
props = vProps;



%
% add property to a view
%
function doAddProperty(view, property, location)

if ~isempty(view) && ~isempty(property)
    if isempty(location)
        location = 'append';
    end
    for i = 1:length(property)
        % Check for any duplicates
        if isempty(view.Properties)
            prop = [];
            view.Properties = [];
        else
            prop = find(view.Properties, 'Name', property{i}.Name);
        end
        if isempty(prop)
            if strcmpi(location, 'append')
                view.Properties = [view.Properties; property{i}];
            else
                view.Properties = [property{i}; view.Properties];
            end
        else
            % Just make it visible
            prop.isVisible = true;
        end
    end
end


