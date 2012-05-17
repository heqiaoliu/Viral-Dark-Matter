function init(hDialogBase,theTitlePrefix,hAppInst)
%INIT Initialize method for base class.
%  INIT(hDialogBase,titlePrefix,hAppInst) initializes the DialogBase
%  subclass with the prefix string titlePrefix to be used in the
%  dialog title bar, and an optional application-instance object handle
%  hAppInst on which to receive events.  If an object handle is passed,
%  the dialog is "managed", otherwise it is "unmanaged."
%
% Standard services provided by DialogBase, performed whether the dialog
% is "managed" or "non-managed", include:
%  - restore position of dialog when it re-opens after moving/closing
%  - structured title-bar name
%
% Services provided to "managed" dialogs include:
%  - closing dialog when main application closes
%  - automatic updates to title bar name
%  - client app must define following events:
%      CloseDialogsEvent
%      UpdateDialogsTitleBarEvent

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2010/04/21 21:49:39 $

% Record prefix string to use as part of title bar name
hDialogBase.TitlePrefix = theTitlePrefix;

% Get/store application-instance object handle
% This handle is retained as a service to subclassed objects
% (we don't require this beyond listener creation below)
if nargin<3, hAppInst=[]; end
hDialogBase.hAppInst = hAppInst;
isHG1 = ~feature('hgUsingMATLABClasses');

% Only create listeners for managed dialogs
%
% This means clients (that is, all hAppInst objects) must
% implement these events or an error will occur
if ~isempty(hAppInst)
    % throw an error if either of these listeners comes up "Empty", because
    % our client simply forgot to define the necessary events!
    % *** NOTE: once HG1 is deprecated, remove this block of code ***
     if isHG1
        hDialogBase.Listen_Client = listener_closeDialog(hDialogBase, hAppInst);
        % Listen for title bar name changes eventData is titleSuffix string
       hDialogBase.Listen_Client(2) = listener_titlebar(hDialogBase,hAppInst);
    % *** NOTE: once HG1 is deprecated, remove the above block of code ***
    else
        % When using MCOS object (in HG2), if the event is not one of the
        % member events, it will hard-error. So checking for event before
        % adding a listener.
        if ~isa(hAppInst, 'MCOS') || ...
                any(ismember(lower(events(hAppInst)),lower( 'CloseDialogEvent')))
            hDialogBase.Listen_Client = listener_closeDialog(hDialogBase, hAppInst);
        end
        % Listen for title bar name changes eventData is titleSuffix string        
        if ~isa(hAppInst, 'MCOS') || ...
                any(ismember(lower(events(hAppInst)),lower( 'UpdateDialogsTitleBarEvent')))
            hDialogBase.Listen_Client(2) = listener_titlebar(hDialogBase,hAppInst);
        end
    end
end

% --------------------------------
function listen_client = listener_closeDialog(hDialogBase, hAppInst)
    listen_client =  handle.listener( ...
        hAppInst, 'CloseDialogsEvent', ...
        @(hh,ev)onParentClosed(hDialogBase));


% --------------------------------
function listen_client = listener_titlebar(hDialogBase,hAppInst)
    listen_client =  handle.listener( ...
        hAppInst, 'UpdateDialogsTitleBarEvent', ...
        @(hh,ev)updateTitleBar(hDialogBase,ev));

% [EOF]
