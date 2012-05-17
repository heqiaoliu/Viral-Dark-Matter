function connectState(this)
%CONNECTSTATE Initialize the Simulink data connection.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.10 $ $Date: 2010/05/20 03:07:51 $

% Get Simulink object path (slPath), describing a block or port
% slPath is a cell-array containing the descriptor, as it may have
% more than one part
%    {'path'} or {'path',portIdx} or [line_handles]
%    It may also be omitted, in which case gsb/gsl is used
%

this.NewData = false;

% Set up the simulink path input for subscribeToEvent.
if isempty(this.ScopeCLI)
    slPath = {};
else
    slPath = this.ScopeCLI.ParsedArgs;
end
if isempty(slPath) || isempty(slPath{1});
    slPath = {};
end

% Init the SLConnectMgr, attach it to Simulink model
okToOpenModel = this.findProp('OpenSimulinkModel').Value;
hSLConnectMgr = slmgr.SLConnectMgr;

hSLConnectMgr.subscribeToEvent(this, slPath{:}, okToOpenModel);

% xxx put a call to datahandler here to check for valid connection

% Did slSignalData create successfully?
% Failure modes: no signal, invalid block selected, etc
isValid = hSLConnectMgr.connected;
if ~isValid

    % Copy error message for reporting:
    this.ErrorMsg = sprintf('Could not connect to %s\n\n%s', ...
        convertPathToString(slPath), hSLConnectMgr.errMsg);
    this.ErrorStatus = 'failure';
    disconnectState(this); % manage button/icon/etc
    
    % Get out of here on basic connect failure!
    return
end

% hSLConnectMgr successfully created: install object into DCS
this.SLConnectMgr = hSLConnectMgr;
this.errorStatus = 'success';

% Set persistent connection mode to the default 'persistent'.  This is so
% when we reconnect to a block/line we force persistent.
this.setConnectionMode('persistent');

% Turn off snapshot when connecting to a new source.  The first time this
% is a no-op because it is set off in schema.  Keeping it on would show
% an all-black screen when the model starts.
this.setSnapShotMode('off');

% If it's available, install the name of the Simulink
% signal path in the main title bar
if ~isempty(this.SLConnectMgr)
    installSourceName(this, getFullName(this.SLConnectMgr));
end


% manage button/icon/etc
enable(this.Controls,true);
updateConnectButton(this,'connect');


% Attach immediately if the model is currently running
if this.isRunning 
    % Listener comes up in the disabled state - no data events yet!
    % Only fire when we are running.  Cannot use the simstate because this
    % overloads running for initializing.
    subscribeToData(this);

    % Note: Data stream NOT turned on at this time,
    %       nor are simulator state changes
    %
    %  This object is not supposed to be "running" just yet
    %  Data stream (run-time objects) is enabled via EnableData
    %  only AFTER the DCS object has been successfully installed
    %  by InstallDataSource - done by caller

    % Could react to error status
    %   (failure could be, say, selecting 2 signals instead of 1 or 3)
    % if ~strcmp(this.errorStatus,'success')
    % end
    
    startVisualUpdater(this);
end

l = handle.listener(this.SLConnectMgr.hSignalSelectMgr.Signals(1).Block, ...
    'NameChangeEvent', @(h, ev) sourceNameChanged(this));
set(this, 'NameChangeListener', l);

% -------------------------------------------------------------------------
function sourceNameChanged(this)

installSourceName(this, getFullName(this.SLConnectMgr));
send(this.Application, 'SourceNameChanged');
updateTitleBar(this.Application);

% -------------------------------------------------------------------------
function string = convertPathToString(path)

if isempty(path) || isempty(path{1})
    string = 'Simulink';
else
    if iscell(path{1})
        path = path{1};
    end
    if ischar(path{1})
        string = path{1};
    else
        try
            modelName = get(path{1}, 'Parent');
            blockName = get(path{1}, 'Name');
            string = [modelName '/' blockName];
        catch e %#ok
            string = 'Simulink';
        end
    end
end

% Do not add port information for now.
% if length(path) > 1
%     if length(path{2}) > 1
%         string = [string ' ports ']; %#ok
%     else
%         string = [string ' port ']; %#ok
%     end
%     string = [string mat2str(path{2})]; %#ok
% end


% [EOF]
