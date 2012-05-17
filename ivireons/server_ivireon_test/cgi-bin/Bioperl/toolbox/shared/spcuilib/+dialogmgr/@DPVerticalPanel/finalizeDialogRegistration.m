function finalizeDialogRegistration(dp)
% Done registering dialog panels
%  - determine dialog ordering from initial order specifications,
%    store in .DockedDialogs
%  - determine DialogBorder services to apply, and cache
%  - update dialog content

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:48:55 $

% Translate from .DockedDialogNamesInit to .DockedDialogs
% DockedDialogNamesInit
%   A cell-array of strings indicating the names of dialogs to make docked
%   and the order in which they are to appear.  This cell-array is used
%   ONLY AT INITIALIZATION to pre-load the index array, and at the time
%   that serialization of property values is performed.
%
%   NOTE: The init vector may specify an incomplete list of panel names.
%         That is fully supported and expected.
%
% DockedDialogs
% A vector containing a subset of Dialog objects in .Dialogs that are
% currently docked in the multi-dialog panel.  This vector is used during
% program operation to determine docked display order, and is updated at
% runtime to reflect changes to docking order and dialog visibility.

% Get dialogs names that are to be opened at initialization
initNames = dp.DockedDialogNamesInit;
Ninit = numel(initNames);

% Get names of all registered dialogs, visible or otherwise
allDlgs = dp.Dialogs;
allNames = {allDlgs.Name};

% Allocate vector of indices for efficiency
idxVisOrder = zeros(1,Ninit); % maximum # of names we can match
Nfound = 0; % number of names identified in registered Dialog list

% Determine dialog visibility order
for i = 1:Ninit
    idx = find(strcmpi(initNames{i},allNames));
    if isempty(idx)
        % Internal message to help debugging. Not intended to be user-visible.
        warning(generatemsgid('UnrecognizedDialogName'), ...
                'Dialog name "%s" not found',initNames{i});
    else
        % Record dialog in order in which it is to appear
        Nfound = Nfound + 1;
        idxVisOrder(Nfound) = idx;
    end
end
dp.DockedDialogs = allDlgs(idxVisOrder(1:Nfound));

% Cache services used for panel lock and unlock
cacheDialogBorderServices(dp);

% Synchronize properties of DialogBorder that have state
enableDialogBorderServices(dp);

% Flush changes to dialog displays
updateDialogContent(dp);
