function varargout = newSource(this, hNewSource, doStop)
%NEWSOURCE Load and install a new data source
%  Installs new data source. Stops player first, if running
%  Accepts command-line input args, or a connection object constructor
%
%  NOTE: Always sends NewSourceEvent to synchronize callers,
%        even if an error during load occurred.
%
%  Callers must allow for synchronization by giving up the execution thread
%  after calling this function.  Any statements that must execute after the
%  call to newSource must be setup in a listener on NewSourceEvent that is
%  sent once newSource has completed.  See loadSource() for an easy-to-use
%  blocking implementation that calls this method.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/10/29 16:09:56 $

if doStop
    % Invokes "Stop" method and pends until stop completes using a listener
    %
    % Stop player, if running, in order to load new Source
    stop(this, @(h,e) onStop(this, hNewSource));
else
    % No stop required (new player instance being created)
    % Skipping stop is not for performance (although it truly isn't needed)
    % It's for same-thread-of-execution issues related to error handlers
    %
    % NOTE: left-hand side args are only available (from local fcn,
    %       and back to caller) if doStop=false
    %
    [varargout{1:nargout}] = onStop(this, hNewSource);
end

% ------------------------------------------------------------
function varargout = onStop(this, hNewSource)
%onStop Called when the Stop event is fired.
%
%   Wait for the DataSource to stop.  This is usually waiting for a timer
%   to finish.

this.IsConnecting = true;

hOldSource = this.DataSource;

% Check 1st entry in args
% If it's a handle, use that method for constructing new data source
% Otherwise use ParseCmdLineArgs (general parser)

engageConnection(hNewSource);

% Actions for return states of datasource construction:
%         'success' (install new source)
%         'failure' (reconnect last source, launch error dialog)
%         'cancel'  (reconnect last source)
%
switch hNewSource.errorStatus
    case 'success'     
        % Succeeded in creating new data source - 
        %   finish installing source:
        
        if ~isempty(hOldSource)
            if ~hNewSource.isEqual(hOldSource)
                hOldSource.ActiveSource = false;
                hOldSource.disengageConnection;
            end
        end
        hNewSource.ActiveSource = true;
        this.installDataSource(hNewSource);
        
    case 'cancel'
        % Failed to create new data source
        %

        if ~isempty(hOldSource)
            if ~hNewSource.isEqual(hOldSource) && ~hOldSource.ActiveSource
                hOldSource.ActiveSource = true;
                hOldSource.reconnect;
                this.installDataSource;
            end
        end
        
    case 'failure'
        % Failed to create new data source
        %
        % Reconnect previous data source
        if ~isempty(hOldSource) && ~hOldSource.ActiveSource
            hOldSource.ActiveSource = true;
            hOldSource.reconnect;
        end
        
    otherwise
        error(generatemsgid('Assert'),...
            'Assert: unrecognized error status "%s"', hNewSource.errorStatus)
end

drawnow;  % flush all graphical changes

% Send synchronization event
%
if ~strcmp(hNewSource.ErrorStatus, 'cancel')
    send(this, 'NewSourceEvent', uiservices.EventData(this, 'NewSourceEvent', hNewSource));
end

% Create status to pass to event handler
if nargout
    varargout = {strcmp(hNewSource.ErrorStatus, 'success'), hNewSource.ErrorMsg};
end

this.IsConnecting = false;

% [EOF]
