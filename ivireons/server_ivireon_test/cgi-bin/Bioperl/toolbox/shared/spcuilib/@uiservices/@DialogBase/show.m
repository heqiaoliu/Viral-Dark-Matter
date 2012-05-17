function show(hDialogBase, create)
%SHOW Show the dialog
%  If create=true (or omitted), create new dialog if
%  needed or bring existing dialog forward.
%  If create=false, open bring existing dialog forward.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:22 $

if nargin<2, create=true; end  % default

% Option: Should we reset the dialog size?
%   - only when it is re-opened after closing?
%   - or every time an update is requested?
%
resetSizeWhenNew = true;
resetSizeWhenUpdated = true;

% Construct full dialog title string
titleFull = [hDialogBase.TitlePrefix hDialogBase.TitleSuffix];

if isempty(hDialogBase.Dialog)
    % No dialog open at present
    if create
        % Create new dialog
        hDialogBase.Dialog = DAStudio.Dialog(hDialogBase);
        % ExplicitShow=true, so that repositioning of dialog
        % is not visible to user
        if isempty(hDialogBase.DialogPosition)
            % Never been positioned before, no old
            % position information to use
            hDialogBase.DialogPosition = hDialogBase.Dialog.position;
            hDialogBase.Dialog.resetSize(1);  % force size reset
        else
            % Dialog was previously opened, keep previous position
            % for this new instance
            if resetSizeWhenNew
                % reset size (but keep position)
                % Use only the starting coordinates of our old position
                % Reset dialog size
                hDialogBase.Dialog.resetSize(1);
                % - get this position
                new_position = hDialogBase.Dialog.position;
                % - get old origin
                new_position(1:2) = hDialogBase.DialogPosition(1:2);
                % Set in into dialog
                hDialogBase.Dialog.position = new_position;
            else
                % don't reset size
                hDialogBase.Dialog.position = hDialogBase.DialogPosition;
            end
        end
        setTitle(hDialogBase.Dialog, titleFull);
        show(hDialogBase.Dialog); % must call show when ExplicitShow=true
    end
else
    % Dialog is open
    % Refresh/redraw dialog content, adjust dialog size
    hDialogBase.Dialog.refresh;    % update the existing data
    if resetSizeWhenUpdated
        % Reset size, maintain position
        old_position = hDialogBase.Dialog.position;
        hDialogBase.Dialog.resetSize(1);  % force the resize
        new_position = hDialogBase.Dialog.position;
        new_position(1:2) = old_position(1:2);
        hDialogBase.Dialog.position = new_position;
    end
    setTitle(hDialogBase.Dialog, titleFull);
    show(hDialogBase.Dialog);  % bring dialog forward
end

% [EOF]
