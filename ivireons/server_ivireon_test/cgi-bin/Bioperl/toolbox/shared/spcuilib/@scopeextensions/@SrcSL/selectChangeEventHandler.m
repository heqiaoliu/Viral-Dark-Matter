function selectChangeEventHandler(this, ~)
%SELECTCHANGEEVENTHANDLER SELECTCHANGE event handler

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $  $Date: 2010/03/31 18:42:21 $

% We must be in floating mode and the model must be running, otherwise we
% return early.
if ~this.isFloating && ~isRunning(this) && isempty(this.InstallOnRun)
    return;
end

if this.isFloating
    hNew = [];
else
    hNew = this.InstallOnRun;
end

oldFullPath = this.commandLineArgs;

if isempty(hNew)
    
    % Always get the GSL/GSB from the model that sent the event.  If we do
    % not have event information, use the SLConnectMgr to get it from the
    % last connected signal.
    lastClickedSystem = slmgr.getCurrentSystem;
    model = this.SLConnectMgr.getSystemHandle.Name;
    
    % Make sure that the lastClickedSystem is in the model.  If not then
    % use the model that we are attached to.
    lastClickedModel = strtok(lastClickedSystem, '/');
    depth = 1;
    if ~isequal(model, lastClickedModel)
        lastClickedSystem = model;
        depth = inf;
    end
    
    hNew = {gsl(lastClickedSystem, depth)};
    if isempty(hNew{1})
        hBlocks = gsb(lastClickedSystem, depth);
        if strcmp(getPropValue(this, 'ProbingSupport'), 'SignalLinesOrBlocks')
            % If there is no line selected, check if we have a block
            % selected. If we do and we're only accepting lines, return
            % early to have no effect. If we have nothing selected,
            % continue to get the 'no signal selected' message.
            hNew = hBlocks;
        elseif ~isempty(hBlocks)
            % If we've just clicked on a block, just ignore it if we're not
            % in signals and blocks mode.  Unless we are not subscribed to
            % any data, but we have old path information, then resubcribe
            % to that path.
            if ~isSubscribed(this.SLConnectMgr) && ~isempty(oldFullPath)
                hNew = oldFullPath;
            else
                return;
            end
        end
    end
end

if ~isRunning(this)
    
    % If the model isn't running, set a flag that we want to connect when
    % the model starts running.
    this.InstallOnRun = hNew;
    return;
end

this.InstallOnRun = [];

% Attempt to resubscribe to the data source.
retval = resubscribeToData(this.SLConnectMgr, this, hNew{:});

if ~retval
    
    this.ErrorStatus = 'failure';
    this.ErrorMsg    = this.SLConnectMgr.errMsg;
    
    screenMsg(this.Application, this.ErrorMsg);
    
    % Stop simulator event callbacks (run/stop/etc)
    if ~isempty(this.SLConnectMgr)
        % this.SLConnectMgr.unsubscribeToEvent;
        
        % Stop data stream
        this.SLConnectMgr.unsubscribeToData;
    end
    hmgr = getGUI(this.Application);
    %Disable hilight button and menu item g421566
    hbtn=hmgr.findwidget('/Toolbars/Playback/SimButtons/PlaybackModes/Hilite');
    hmenu=hmgr.findwidget('/Menus/View/Hilite');
    set(hbtn,'enable','off');
    set(hmenu,'enable','off');
    enableStep(this.Controls, false);
    
    send(this.Application, 'DataLoadedEvent', ...
        uiservices.EventData(this.Application, 'DataLoadedEvent', false));
    send(this.Application, 'DataReleased');
    send(this.Application, 'DataSourceChanged', handle.EventData(this.Application, 'DataSourceChanged'));
    
    return
end

% If we are not successful reconnecting to the data, release the data
% source as the current/active source.
% If we are not subscribing to events, the hEventSink will be empty.
% Resubscribe using 'this' as the target.  g467205
if this.isDisconnected
    subscribeToEvent(this.SLConnectMgr, this);
end

setupDataBuffer(this);

% We will definitely connect now, but there may be reasons
% why we choose not to display the data
[b, e] = validateVisual(this, this.Application.Visual);
if ~b
    this.ErrorStatus = 'cancel';
    this.ErrorMsg    = e.message;
    screenMsg(this.Application, this.ErrorMsg);
    
    % Don't disconnect if we're in floating mode
    if ~this.isFloating;
        disconnectState(this);
    end
    
    enableStep(this.Controls, false);
    
    % Notify listeners that the source has changed even though we won't
    % call "installDataSource"
    
    send(this.Application, 'DataSourceChanged', handle.EventData(this.Application, 'DataSourceChanged'));
    return
end

this.ErrorStatus = 'success';
this.ErrorMsg    = '';

%Turn off snapshot mode in floating mode(g408487).

this.SnapShot = false;

installSourceName(this, getFullName(this.SLConnectMgr));
installDataSource(this.Application);

% If the signal that we are connecting to is different, then reset any
% internal buffers, states that the application has.
if ~isequal(oldFullPath, this.commandLineArgs)
    resetData(this.DataHandler);
end

% [EOF]
