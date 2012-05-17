function render(this)
%RENDER   Render the shuttle control

%	@commgui\@shuttlectrl
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/23 07:49:00 $

sz = guiSizes(this);

parent = this.Parent;
if parent == -1
    parent = figure;
end

ShuttlePanel = uipanel(parent, ...
    'Units','pixel',...
    'Title','',...
    'BorderType', 'none ', ...
    'Position', this.Position,...
    'Tag','ShuttlePanel');

uicontrol(ShuttlePanel, ...
    'Style', 'text',...
    'HorizontalAlignment', 'left', ...
    'String', 'Available items:', ...
    'Tag', 'AvailableListLabel', ...
    'Position', [sz.AvailListLabelX sz.AvailListLabelY sz.ListWidth sz.bh]);

availItems = getAvailableItems(this);
this.AvailableList = uicontrol(ShuttlePanel, ...
    'Style', 'listbox', ...
    'String', availItems, ...
    'Min', 1, ...
    'Max', 3, ...
    'Tag', 'AvailableList', ...
    'BackgroundColor', [1 1 1], ...
    'KeyPressFcn', @(hsrc,edata)kpcbLists(edata, parent), ...
    'Callback', @(hsrc,edata)lbcbAvailList(this), ...
    'Position', [sz.AvailListBoxX sz.AvailListBoxY sz.ListWidth sz.ListHeight]);

this.AddButton = uicontrol(ShuttlePanel, ...
    'Style', 'pushbutton', ...
    'String', 'Add ->', ...
    'Tag', 'AddButton', ...
    'KeyPressFcn', {@pbcbMove, this, parent}, ...
    'Callback', {@pbcbMove, this, parent}, ...
    'Position', [sz.AddButtonX sz.AddButtonY sz.bw sz.bh]);

this.RemoveButton = uicontrol(ShuttlePanel, ...
    'Style', 'pushbutton', ...
    'String', '<- Remove', ...
    'Tag', 'RemoveButton', ...
    'KeyPressFcn', {@pbcbMove, this, parent}, ...
    'Callback', {@pbcbMove, this, parent}, ...
    'Position', [sz.RemoveButtonX sz.RemoveButtonY sz.bw sz.bh]);

uicontrol(ShuttlePanel, ...
    'Style', 'text',...
    'HorizontalAlignment', 'left', ...
    'String', 'Selected items:', ...
    'Tag', 'OptionsViewSelectedListLabel', ...
    'Position', [sz.SelectListLabelX sz.SelectListLabelY sz.ListWidth sz.bh]);

this.SelectedList = uicontrol(ShuttlePanel, ...
    'Style', 'listbox', ...
    'String', getSelectedItems(this), ...
    'Min', 1, ...
    'Max', 3, ...
    'Tag', 'SelectedList', ...
    'BackgroundColor', [1 1 1], ...
    'KeyPressFcn', @(hsrc,edata)kpcbLists(edata, parent), ...
    'Callback', @(hsrc,edata)lbcbSelectedList(this), ...
    'Position', [sz.SelectListBoxX sz.SelectListBoxY sz.ListWidth sz.ListHeight]);

if this.RenderMoveUpDown
    this.MoveUpButton = uicontrol(ShuttlePanel, ...
        'Style', 'pushbutton', ...
        'String', 'Move Up', ...
        'Tag', 'MoveUpButton', ...
        'KeyPressFcn', {@pbcbMove, this, parent}, ...
        'Callback', {@pbcbMove, this, parent}, ...
        'Enable', 'off', ...
        'Position', [sz.MoveUpButtonX sz.MoveUpButtonY sz.bw sz.bh]);
    
    this.MoveDownButton = uicontrol(ShuttlePanel, ...
        'Style', 'pushbutton', ...
        'String', 'Move Down', ...
        'Tag', 'MoveDownButton', ...
        'KeyPressFcn', {@pbcbMove, this, parent}, ...
        'Callback', {@pbcbMove, this, parent}, ...
        'Enable', 'off', ...
        'Position', [sz.MoveDownButtonX sz.MoveDownButtonY sz.bw sz.bh]);
end

% Update the move up / move down buttons
updateButtons(this)

if this.RenderQuickHelp
    QuickHelpPanel = uipanel(ShuttlePanel, ...
        'Units','pixel',...
        'Title','Quick help',...
        'Position',...
        [sz.QuickHelpX sz.QuickHelpY sz.QuickHelpWidth sz.QuickHelpHeight],...
        'Tag','QuickHelpPanel');
    
    availItemsIdx = getAvailItemsIdx(this);
    if ~isempty(availItemsIdx)
        helpStr = this.QuickHelp(availItemsIdx(1));
    else
        helpStr = '';
    end
    
    this.QuickHelpText = uicontrol(QuickHelpPanel, ...
        'Style', 'text',...
        'HorizontalAlignment', 'left', ...
        'String', helpStr, ...
        'Tag', 'QuickHelpText', ...
        'Position',...
        [sz.QuickHelpTextX sz.QuickHelpTextY ...
        sz.QuickHelpTextWidth sz.QuickHelpTextHeight]);
end
end
%-------------------------------------------------------------------------------
function pbcbMove(hsrc, eventdata, hGui, hFig)
% Callback function for Add/Remove/Move up/Move down buttons

% Check if this is a key press event
if isstruct(eventdata) && isfield(eventdata, 'Key')
    if strcmp(eventdata.Key, 'escape')
        delete(hFig);
        return
    elseif ~strcmp(eventdata.Key, 'return')
        return
    end
end

% Get the caller's name
source = get(hsrc, 'Tag');

% Get the handle to the available items list
hAvailList = hGui.AvailableList;
hSelectList = hGui.SelectedList;

% Store the highlighted items in the available list.  We will use this value if
% we dont need to change it.
highlightedAvailableItems = get(hAvailList, 'Value');

switch source
    case 'AddButton'
        % Get the indices of the items listed in the available items listbox
        availItemsIdx = getAvailItemsIdx(hGui);
        
        % Get highlighted items from the available items list and determine
        % their indices in the full list
        highlightedItems = availItemsIdx(get(hAvailList, 'Value'));
        
        % Get the index number list of selected items.  Note that the sequence
        % also represents the display sequence
        selectedItems = hGui.SelectedItemIndices;
        
        % Add the newly selected items to the end of the list
        selectedItems = [selectedItems highlightedItems];
        
        % Set the displayed items in the selected listbox
        hGui.SelectedItemIndices = selectedItems;
        
        % Highlight the newly added items in the selected listbox
        numSelectedItems = size(selectedItems, 2);
        numHighlightedItems = size(highlightedItems, 2);
        highlightedSelectedItems = ...
            numSelectedItems-numHighlightedItems+1:numSelectedItems;

        % Decide which items should be highlighted in the available listbox
        % aftger removing the selected ones.
        highlightedAvailableItems = getHighlightedAvailableItemIdx(hGui);
        
    case 'RemoveButton'
        % Get highlighted items from the selected items list
        highlightedItems = get(hSelectList, 'Value');
        
        % Get the index number list of selected items.  Note that the sequence
        % also represents the display sequence
        selectedItems = hGui.SelectedItemIndices;
        
        if ~isempty(highlightedItems)
            % Remove the highlighted ones
            selectedItems(highlightedItems) = [];
            
            % Set the list of displayed items
            hGui.SelectedItemIndices = selectedItems;
            
            % Highlight an appropriate item after remove action
            highlightedSelectedItems = getHighlightedSelectedItemIdx(hGui);
        end
        
    case 'MoveUpButton'
        % Get highlighted items from the selected items list
        highlightedItems = get(hSelectList, 'Value');
        
        % Get the index number list of selected items.  Note that the sequence
        % also represents the display sequence
        selectedItems = hGui.SelectedItemIndices;
        
        % Move the highlighted one up one step
        dummy = selectedItems(highlightedItems(1)-1);
        selectedItems(highlightedItems-1) = selectedItems(highlightedItems);
        selectedItems(highlightedItems(end)) = dummy;
        
        % Set the list of displayed items
        hGui.SelectedItemIndices = selectedItems;
        
        % Highlight the first item
        highlightedSelectedItems = highlightedItems-1;
        
    case 'MoveDownButton'
        % Get highlighted items from the selected items list
        highlightedItems = get(hSelectList, 'Value');
        
        % Get the index number list of selected items.  Note that the sequence
        % also represents the display sequence
        selectedItems = hGui.SelectedItemIndices;
        
        % Move the highlighted one up one step
        dummy = selectedItems(highlightedItems(end)+1);
        selectedItems(highlightedItems+1) = selectedItems(highlightedItems);
        selectedItems(highlightedItems(1)) = dummy;
        
        % Set the list of displayed items
        hGui.SelectedItemIndices = selectedItems;
        
        % Highlight the first item
        highlightedSelectedItems = highlightedItems+1;
end

% Update the selected items listbox
set(hSelectList, 'String', getSelectedItems(hGui));
set(hSelectList, 'Value', highlightedSelectedItems);

% Update available items listbox
set(hAvailList, 'String', getAvailableItems(hGui));
set(hAvailList, 'Value', highlightedAvailableItems);

% Update the quick help
updateQuickHelp(hGui, highlightedAvailableItems)

% Update the move up / move down buttons
updateButtons(hGui)
end
%-------------------------------------------------------------------------------
function lbcbSelectedList(hGui)
% Callback function for selected items list box
updateButtons(hGui)
end
%-------------------------------------------------------------------------------
function lbcbAvailList(hGui)
% Callback function for available items list box

highlightedItems = get(hGui.AvailableList, 'Value');
availListLastValue = hGui.AvailableListLastValue;

idx = ismember(highlightedItems, availListLastValue);
if length(highlightedItems) > 1
    lastSelectedItems = find(~idx);
    if length(lastSelectedItems) > 1
        if lastSelectedItems(1) == 1
            lastClickedItem = highlightedItems(lastSelectedItems(1));
        else
            lastClickedItem = highlightedItems(lastSelectedItems(end));
        end
    else
        lastClickedItem = highlightedItems(lastSelectedItems);
    end
else
    lastClickedItem = highlightedItems;
end

hGui.AvailableListLastValue = highlightedItems;

% Update the quick help
updateQuickHelp(hGui, lastClickedItem)

end
%-------------------------------------------------------------------------------
function kpcbLists(eventdata, hFig)
% Key press callback function to finish processing.  It check for escape key

switch eventdata.Key
    case 'escape'
        delete(hFig);
    case 'return'
        % If a keypress function is specified, relay to the owner using key
        % press function
end
end
%-------------------------------------------------------------------------------
function availItemsIdx = getAvailItemsIdx(this)
% Get the indices of the items listed in the available items listbox
selectItemsIdx = this.SelectedItemIndices;
availItemsIdx = setdiff(1:length(this.Items),selectItemsIdx);
end
%-------------------------------------------------------------------------------
function availItems = getAvailableItems(this)
items = this.Items;
selectItems = this.SelectedItemIndices;
availItems = items(setdiff(1:length(items),selectItems));
end
%-------------------------------------------------------------------------------
function selectItems = getSelectedItems(this)
items = this.Items;
selectItems = items(this.SelectedItemIndices);
end
%-------------------------------------------------------------------------------
function updateButtons(this)
selectedList = this.SelectedList;

highlightedItems = get(selectedList, 'Value');
selectedItems = get(selectedList, 'String');
numSelectedItems = size(selectedItems, 1);

% Update Move up/down buttons
if ~isempty(highlightedItems) ...
        && ~any(highlightedItems == 0) && ~any(diff(highlightedItems) ~= 1)
    % If the first item is selected, then disable move up button
    if highlightedItems(1) == 1
        set(this.MoveUpButton, 'Enable', 'off');
    else
        set(this.MoveUpButton, 'Enable', 'on');
    end
    
    % If the last item is selected, then disable move up button
    if highlightedItems(end) == numSelectedItems
        set(this.MoveDownButton, 'Enable', 'off');
    else
        set(this.MoveDownButton, 'Enable', 'on');
    end
else
    % If non-selected or a discontinuous list is highlighted, then disable both
    set(this.MoveUpButton, 'Enable', 'off');
    set(this.MoveDownButton, 'Enable', 'off');
end

% Update Add/Remove buttons
if numSelectedItems > 0
    % Enable remove button if there is at least one selected item
    set(this.RemoveButton, 'Enable', 'on');
else
    % If there is no selected items left, then disable remove button
    set(this.RemoveButton, 'Enable', 'off');
end
numAvailItems = length(this.Items) - numSelectedItems;
if numAvailItems > 0
    % Enable add button if there is at least one selected item
    set(this.AddButton, 'Enable', 'on');
else
    % If there is no selected items left, then disable add button
    set(this.AddButton, 'Enable', 'off');
end
end
%-------------------------------------------------------------------------------
function updateQuickHelp(this, idx)
availItemsIdx = getAvailItemsIdx(this);
if ~isempty(availItemsIdx)
    set(this.QuickHelpText, 'String', this.QuickHelp(availItemsIdx(idx)))
else
    set(this.QuickHelpText, 'String', '')
end
end
%-------------------------------------------------------------------------------
function idx = getHighlightedSelectedItemIdx(this)
% Decide which items should be highlighted in the selected listbox
% aftger removing the selected ones.

itemIndecis = this.SelectedItemIndices;
hList = this.SelectedList;

idx = getHighlightedItemIdx(itemIndecis, hList);

end
%-------------------------------------------------------------------------------
function idx = getHighlightedAvailableItemIdx(this)
% Decide which items should be highlighted in the available listbox
% aftger removing the selected ones.

itemIndecis = getAvailItemsIdx(this);
hList = this.AvailableList;

idx = getHighlightedItemIdx(itemIndecis, hList);

end
%-------------------------------------------------------------------------------
function idx = getHighlightedItemIdx(itemIndecis, hList)

% Highlight an appropriate item after removing one from the list
numItems = size(itemIndecis, 2);
highlightedItems = get(hList, 'Value');

if (numItems > 0)
    if any(highlightedItems > numItems)
        % if last item of the previous list was removed, than highlight the
        % last item of the new list.
        idx = numItems;
    else
        % if last item of the previous list was not removed, than highlight
        % the item after the removed item.
        idx = highlightedItems(end);
    end
else
    idx = 1;
end
end
% [EOF]
