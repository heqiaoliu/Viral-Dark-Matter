function success = register(dp,thisDialog)
% Register a dialog with the DialogPanel.

% xxx this should become addDockedDialog(dp,thisDialogContent)

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:49:00 $

% Add a new dialog to the dialog panel list
%
% tag is optional string to override default context menu for dialogs.
% Without the tag, context menu gets defined by default tag 'GenericDialog'.

% Confirm that the dialog passed here is what we expect
verifyDialogType(dp,thisDialog);
%success = false;

% Check that dialog name is not a duplicate
names = {dp.Dialogs.Name};
dialogName = thisDialog.Name;
if any(strcmpi(names,dialogName))
    % Internal message to help debug. Not intended to be user-visible.
    errID = generatemsgid('duplicatedialog');
    error(errID, 'Attempt to register duplicate dialog name: %s', dialogName);
end

% Add dialog object to dialog list
%
% Determine index into the static repository of Dialog handles
% (not the repository for the subset of visible dialogs)
dp.Dialogs(end+1) = thisDialog;

% Engage DialogBorder services
%  - Enable specified services
%  - Attach listeners to specified service events, if any
%
% These services have events with the same names as the services
%
% NOTE: This list needs to remain in-sync with the list of desired
%       DialogBorder services listed in DPVerticalPanel properties
%       declarations.  Adding/removing services here correctly disables
%       callbacks from executing, BUT graphical icons for the services
%       may still show up due to the service being listed in the class
%       property initial value.
%
engageServices( ...
    thisDialog.DialogBorder, ...
    {'DialogTitle',    [], ...
    'DialogClose',     @(h,e)closeDialog(dp,thisDialog), ...
    'DialogMoveToTop', @(h,e)moveDialogToTop(dp,thisDialog), ...
    'DialogUndock',    @(h,e)undockDialog(dp,thisDialog), ...
    'DialogRoller',    []} );

success = true;

