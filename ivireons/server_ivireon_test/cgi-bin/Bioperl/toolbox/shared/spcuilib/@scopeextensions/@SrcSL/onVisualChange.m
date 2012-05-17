function onVisualChange(this)
%ONVISUALCHANGE 

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/03/31 18:42:18 $

% Make sure that the RTO listeners are disabled so that we do not get
% updates while we're switching sources.  We will enable at the end.
enableData(this, false);

oldErrorStatus = this.ErrorStatus;

% Cache the data locally

% Install the new data source to match the current visual and get the new
% data object into the source.
installDataHandler(this);


% If we were unable to connect with the last visual, try reconnecting with
% the new one.  This can happen when the old data handler did not handle
% the setup, i.e. not 1 or 3 when viewing video.
if ~strcmp(oldErrorStatus, 'success')
    retval = resubscribeToData(this.SLConnectMgr, this);
    if ~retval
        this.ErrorStatus = 'failure';
        this.ErrorMsg    = this.SLConnectMgr.errMsg;
        screenMsg(this.Application, this.ErrorMsg)
    end
end

% Let the datahandler check the connection.
if this.SLConnectMgr.getSignalData.numComponents ~= 0
    validateVisual(this.Application);
end

% If we are connected, get the last frame from the old visual via the
% SignalData object which will keep holding it.
if isConnected(this)
    if isDataEmpty(this)
        screenMsg(this.Application, this.emptyDataMessage);
    else
        period = this.SLConnectMgr.hSignalData.Period;
        if period > 0
            this.Data.FrameRate = 1/period;
        end
    end
end

% If we are valid at this point, re-enable the data stream, if not put up
% the screen message describing why.
enableData(this);

% [EOF]

% LocalWords:  RTO datahandler
