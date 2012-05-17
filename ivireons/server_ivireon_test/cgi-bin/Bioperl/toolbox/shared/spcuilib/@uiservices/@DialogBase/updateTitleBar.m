function updateTitleBar(hDialogBase,eventData)
%UpdateTitleBar Update title bar name of all managed dialogs.
%  updateTitleBar(hDialogBase,eventData) reacts to the event
%  'UpdateDialogsTitleBarEvent' being thrown.  eventData must
%  contain the titleSuffix string to use in the .data field.
%
%  Example code to throw event from client application GUI:
%
%      % Send title-bar update event to all managed DialogBase dialogs
%      newTitleSuffix = 'something';
%      eventName = 'UpdateDialogsTitleBarEvent';
%      send(hMPlayer,eventName, ...
%          uiservices.EventData(hMPlayer,eventName,newTitleSuffix));
%
%  Note that a client application MUST define this event name if any
%  DialogBase dialogs are "managed"; an error will occur otherwise.
%
%  The title bar-prefix is preset by each dialog subclass, so that part
%  of the title is not expected to change - just the suffix.  If no suffix
%  change is desired, a client does not need to throw this event.
%
%  updateTitleBar(hDialogBase) assumes TitleSuffix property
%  already contains the appropriate title-bar suffix string.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:24 $

% If called due to an event, copy TitleSuffix string on each event.
% Make sure to use an empty string if data is empty
% (data could have been [] instead of '', for example)
if nargin>1
    if isempty(eventData.data)
        hDialogBase.TitleSuffix = '';
    else
        hDialogBase.TitleSuffix = eventData.data;
    end
end

% Update dialog, if open
%   Note: 'false' flag means update-only -> suppress dialog creation
%   Note: 'show' method assembles title bar from prefix and suffix
show(hDialogBase, false);

% [EOF]
