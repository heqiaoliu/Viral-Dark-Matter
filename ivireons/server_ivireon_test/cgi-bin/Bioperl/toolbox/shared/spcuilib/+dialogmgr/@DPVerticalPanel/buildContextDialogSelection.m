function h_main = buildContextDialogSelection(dp, hParentMenu)
% Create "All Dialogs" context menu and main menu specific to
% DPVerticalPanel. hParentMenu can either be a context menu handle or a
% handle to a main menu.
%
% For one or more registered dialogs, context menu will show:
%    All Dialogs >
%       Show All Dialogs
%       ----------------
%       DialogName1
%       DialogName2
%       ...
%
% Check marks are added to menu entries that are visible dialogs
% (docked or undocked).  Dialogs are listed in alphabetical order
% based on dialog name.
%
% When there are no registered dialogs, context menu will show:
%    All Dialogs >
%       No dialogs

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:29 $

% Create top-level menu entry
if nargin < 2
    hParentMenu = dp.hContextMenu;
end

h_main = uimenu('parent',hParentMenu, ...
    'label','All Dialogs','tag','AllDialogsMenu');

% Get list of dialog handles, in name-sorted order
allDlgs = sortInAlphaOrder(dp.Dialogs);
N = numel(allDlgs);

if N > 0
    % One or more dialogs present
    
    % Add "Show All Dialogs" menu
    %  - this has a one-shot callback action, it's not a modal state
    uimenu('parent',h_main, ...
        'label','Show All Dialogs', ...
        'callback',@(h,e)dockAllHiddenDialogs(dp),...
        'tag','ShowAllDialogsMenu');
    
    % Create list of dialog IDs for visibility test
    visibleDlgIDs = getID([dp.DockedDialogs dp.UndockedDialogs]);
    
    for i = 1:N
        thisDlg = allDlgs(i);
        
        % Visible dialogs get a checkmark in their menu
        isVisible = any(thisDlg.DialogContent.ID == visibleDlgIDs);
        showCheckmark = uiservices.logicalToOnOff(isVisible);
        
        hMenu = uimenu('parent',h_main, ...
            'label',thisDlg.Name, ...
            'callback',@(h,e)toggleDockedDialogVisibility(dp,thisDlg), ...
            'checked',showCheckmark,...
            'tag',[thisDlg.Name,'Menu']);

        % Add separator above first dialog entry in menu list
        if i==1
            set(hMenu,'separator','on');
        end
    end
else
    % No dialogs
    uimenu('parent',h_main, ...
        'label','No dialogs', ...
        'ena','off');
end

end

function sortedDlgs = sortInAlphaOrder(allDlgs)
% Sort list of all dialogs to be in alphabetical order based on name

[~,idx] = sort({allDlgs.Name});  % sort dialog names in ascending order
sortedDlgs = allDlgs(idx);

end

