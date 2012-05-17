function releaseData(this)
%RELEASEDATA Sent data released event

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/10/29 16:09:57 $

% Tell the source to disengage its connection.  File sources should release
% file handles, simulink should shutdown the RTO listeners, etc.
if ~isempty(this.DataSource)
    disengageConnection(this.DataSource);
end

% Clear out all the referneces.
this.DataSource = [];

% Let anyone else know that we are removing the data.
eventData = uiservices.EventData(this, 'DataLoadedEvent', false);
send(this,'DataLoadedEvent', eventData);
send(this, 'DataReleased');

% Update the titlebar because we no longer have a source.
this.updateTitleBar;

% Turn off the display.
if screenMsg(this)
    screenMsg(this, false);
end

set(getDisplayHandles(this.Visual), 'Visible', 'off');

% [EOF]
