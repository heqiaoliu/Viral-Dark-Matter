function assertDialogListConsistency(dp,dlg)
% Perform a number of consistency checks
% There are no "functional" outcomes of calling this code other than
% assertions.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:25 $

% NOTE:
%  - Checking is based on dialogContent ID
%  - There are no IDs given to Dialog objects themselves at this time
%  - So we're really testing if multiple Dialog objects have the same
%    dialogContent child object
dlgID = dlg.DialogContent.ID;

% Find dialog in dialog lists
regIdx    = find(dlgID == getID(dp.Dialogs));
dockIdx   = find(dlgID == getID(dp.DockedDialogs));
undockIdx = find(dlgID == getID(dp.UndockedDialogs));

% Dialog must appear exactly once in master registration list
assert(isscalar(regIdx)); % exactly one

% Dialog may appear in docked or undocked list at most one time
assert(numel(dockIdx)<2);
assert(numel(undockIdx)<2);

% Dialog may not appear in both docked and undocked lists
% So dialog must not appear in at least one of these lists
assert( isempty(dockIdx) || isempty(undockIdx) );

