function isValid = subscribeToEvent(this, eventSink, varargin)
%CONNECT  subscribe to simulink model status events
%   OUT = CONNECT(ARGS) <long description>

%   Author(s): J. Yu
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/10/07 14:24:27 $

% Don't really subscribe to events here anymore, that's in the source

isValid = true; %#ok
try
    this.hSignalSelectMgr.init(varargin{:});
    [isValid, errorMsg] = this.hSignalSelectMgr.checkConnection;
catch e
    isValid = false;
    errorMsg =  uiservices.cleanErrorMessage(e);
end
if ~isValid
    this.errMsg = errorMsg;
else   
    % Only for normal mode, what about other cases?
    if ~isempty(eventSink),
        hRoot = this.hSignalSelectMgr.getSystemHandle;
        this.connected = eventSink.State.attachToModel(hRoot,hRoot.SimulationStatus,...
        @(h, ev) eventSink.onStateEventHandler(ev));
    end
end

% [EOF]
