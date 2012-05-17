function createBaseContext(dp,dc)
% Create the base DP context menu for the main panel or for a dialog.
%
% Pass empty for DialogContent (dc) if this is the main dialog panel, which occurs
% for a right-click on the "background" of the dialog panel).

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:36 $

hMainContext = dp.hContextMenu;

% If there are other context menus already present,
% use a separator on first item here
nextNeedsSep = uiservices.logicalToOnOff( ...
    ~isempty(get(hMainContext,'children')) );

% NOTE: the hDialogPanel "background" panel is not a dialog.
%       Its user-data is not used for context menu generation.
%       We don't try to put up a dialog context menu.
%
% We suppress showing the dialog-specific menu items for the main panel
% However, we do want the rest

% Determine if this context was invoked on a specific dialog,
% or just on a general GUI widget for the Dialog Presenter
if ~isempty(dc)
    dlg = getDialog(dp,dc);
    
    dialogName = dlg.Name;
    
    % If we add any menus here, we must also add a separator
    % However, we only add menus if certain optional services are NOT
    % offered by the DialogBorder.
    %
    % Assume no additional menus added initially:
    anyOptionsAdded = false;
    
    % List of services successfully enabled on DialogBorder children
    % Do not query dialogBorder directly; use cache of names.
    % We may have intentionally not subscribed to some services
    svcs = dp.DialogBorderServiceNamesActual;
    
    if ~any(strcmpi('DialogClose',svcs))  % ~hasService(dialogBorder,'DialogClose')
        % No DialogClose service in DialogBorder
        % Add a context menu
        anyOptionsAdded = true;
        % Is this dialog in the visibility index vector?
        % If not, it's invisible
        uimenu('parent',hMainContext, ...
            'label',['Close "' dialogName '"'], ...
            'callback',@(h,e)toggleDockedDialogVisibility(dp,dlg), ...
            'separator',nextNeedsSep);
        nextNeedsSep = 'off';
    end
    
    if ~any(strcmpi('DialogMoveToTop',svcs)) % ~hasService(dialogBorder,'DialogMoveToTop')
        % No DialogMoveToTop service in DialogBorder
        % Add a context menu
        anyOptionsAdded = true;
        uimenu('parent',hMainContext, ...
            'label',['Move "' dialogName '" to top' ], ...
            'callback',@(h,e)moveDialogToTop(dp,dlg), ...
            'separator',nextNeedsSep);
        nextNeedsSep = 'off';
    end
    
    if ~any(strcmpi('DialogUndock',svcs)) % ~hasService(dialogBorder,'DialogUndock')
        % No DialogUndock service in DialogBorder
        % Add a context menu
        anyOptionsAdded = true;
        % Is this dialog in the visibility index vector?
        % If not, it's invisible
        uimenu('parent',hMainContext, ...
            'label',['Undock "' dialogName '"'], ...
            'callback',@(h,e)undockDialog(dp,dlg), ...
            'enable','off', ...
            'separator',nextNeedsSep);
        nextNeedsSep = 'off';
    end
    
    if anyOptionsAdded
        nextNeedsSep = 'on';
    end
end

% Add list of all available dialogs as a sub-menu within context menu
hh = buildContextDialogSelection(dp);
set(hh,'separator',nextNeedsSep);

% Add menu options for dialog panel for example, Panel Lock, Auto-hide.
buildPanelMenuOptions(dp, hMainContext);
