function updateDialogContent(dp)
% Update content of each visible dialog, docked or undocked.
% - Only update docked dialogs if DialogPanel is visible
% - Update in display order; this order is not essential, but top-down
%   may lead to better visual outcome for the user.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:34 $

% Update docked
if dp.PanelVisible
    if ~isempty(dp.DockedDialogs)
        % Dialog update method works on a vectors
        update(dp.DockedDialogs);
    end
end

% Update undocked
if ~isempty(dp.UndockedDialogs)
    update(dp.UndockedDialogs);
end

