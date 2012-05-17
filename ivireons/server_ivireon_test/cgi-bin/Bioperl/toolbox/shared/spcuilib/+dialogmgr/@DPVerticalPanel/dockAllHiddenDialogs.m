function dockAllHiddenDialogs(dp)
% Dock all hidden dialogs to make them visible.
% (Doesn't touch undocked dialogs, nor make any hidden dialogs become
% undocked.)

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:43 $

% Make all hidden dialogs become docked
%
% New docked dialog list will have all currently docked dialogs listed
% first, then we add all hidden dialogs.
%
% This partitioning leads to the "least astonishing" display update:
% all currently visible dialogs remain in their order and at the top of the
% panel, and~ invis panels appear at the bottom in no particular order.
[currDockDlgs,hiddenDlgs] = getDockedAndHiddenDialogs(dp);

% Create list with currently visible dialogs, plus all currently
% hidden dialogs, to become the new visible dialog list:
dp.DockedDialogs = [currDockDlgs hiddenDlgs];

% Make sure panel is visible, then update display
dp.PanelVisible = true; % turn on DialogPanel display
showDialogPanel(dp);    % update display

% Synchronize properties of DialogBorder that have states
% (responds to dialog panel lock, etc)
enableDialogBorderServices(dp);

% Always update message - in case we must turn it off
showNoDockedDialogsMsg(dp);

shiftViewToBottom(dp);
