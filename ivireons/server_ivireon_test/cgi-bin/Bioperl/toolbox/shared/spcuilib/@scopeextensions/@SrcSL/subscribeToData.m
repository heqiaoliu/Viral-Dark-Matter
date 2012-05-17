function retval = subscribeToData(this)
%SUBSCRIBETODATA subscribe to SLConnectMgr for data

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/03/31 18:42:26 $

if isempty(this.SLConnectMgr)
    retval = false;
    return
end

retval = this.SLConnectMgr.subscribeToData(this);

% If we fail to subscribe to the data, we want to return early.  If we are
% in floating mode, this is due to no signal being selected.  This is not
% an error case, so we set the errorStatus, but update the screenMsg with a
% message about connectivity.
if retval
    setupDataBuffer(this);
    retval = cacheSignalData(this);
else
    this.ErrorMsg = this.SLConnectMgr.errMsg;
    if this.isFloating;
        this.ErrorStatus = 'success';
    else
        this.ErrorStatus = 'failure';
        % need to cleanly disconnect and remove the control bar.
        disconnectState(this); % manage button/icon/etc
        disconnect(this.Application);
    end    
end

%------------------------------------------------------------------------
function disconnect(datasrc)
% Clear out all the referneces.
datasrc.DataSource = [];

% Let anyone else know that we are removing the data.
eventData = uiservices.EventData(datasrc, 'DataLoadedEvent', false);
send(datasrc,'DataLoadedEvent', eventData);
send(datasrc, 'DataReleased');

% Update the titlebar because we no longer have a source.
datasrc.updateTitleBar;

% Turn off the display.
if screenMsg(datasrc)
    screenMsg(datasrc, false);
end

set(getDisplayHandles(datasrc.Visual), 'Visible', 'off');

% [EOF]
