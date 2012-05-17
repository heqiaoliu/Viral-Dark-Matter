function close(hScopes)
%CLOSE    Close scope GUI, shut down data connections, etc.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2009/09/09 21:30:02 $

% Ways to get here:
%    Close all force
%    delete(h)
%    click "x" button in GUI
%    menu "close"
%    API call to "close"
%
% Some timing issues to consider:
%   - If we close the figure, we lose the figure userdata, and that holds the
%     handle to the timer.  If that is lost, the timer is invalid.  But, any
%     pending timer events will not properly resolve - and an error may occur.
%
%  - we want to close the movie source (say, a file stream)
%    but if the timer is still running, it could cause another
%    event (frame to be viewed) ... and that would potentially
%    require the file to remain open. hence, we must shut down
%    the timers first

for i=1:numel(hScopes)
    hScope = hScopes(i);
    
    if ~isempty(hScope.Parent) && ishghandle(hScope.Parent) && ~hScope.IsConnecting
        % Close dialog windows, but not the main GUI
        % Nothing to do with usability --- it's that the main GUI
        % holds the timer and data objects, and we can't delete
        % the objects before flushing pending events, etc.
        %
        % Prevent recursive closing, trigger dialog objects to close
        set(hScope.Parent,'DeleteFcn','');

        % Make figure invisible so a quick and clean tear-down
        % is shown to user.  Hides any incremental tear-down of
        % components within main GUI (buttons, etc).
        %
        % Let managed dialogs know we're closing down
        %
        % External figures/windows that are dependent on a
        % scope figure can synchronize closing themselves by
        % listening for this event.  For dialogs, consider sub-
        % classing DialogBase to gain several services "for free."
        %
        hScope.visible('off');
        send(hScope, 'Close');

        % If we're closing the last MPlay, close any open single-
        % instance dialogs (e.g., all MPlay'ers share these dialogs).
        % If there are still other MPlay'ers, keep them open
        hScope.initInstanceNumber('free');  % return instance number to pool

        % Now begin the timer shut-down sequence
        % 1. Shut down and delete timer object
        % 2. Close the figure
        %
        % We must do this in this sequence.  If we close the figure and
        % delete the scope object, we will lose the handle to the timer.
        % If that is lost, the timer is invalid.  But, any pending timer
        % events will not properly resolve - and an error may occur.
        %
        % Remedy:
        %   1 - load a new stopfcn into the timer
        %   2 - send a stop event to the timer
        %   3 - when the stopfcn is called, we know the timer events are flushed
        %   4 - delete the timer
        %   5 - delete the window
        
        stop(hScope, @(h, ev) finalShutdownSteps(hScope));
    end
end

% --------------------------------------------------------
function finalShutdownSteps(this)
% Final steps:
%  - close data source
%  - delete timer object
%  - close MPlay window

% Shut down listeners
%
if ~isempty(this.Listeners)
    this.Listeners = [];
end

% Close data source
%
% Note that closing the data source could throw an error,
% depending on the state of the connection, having nothing
% to do with the shut-down sequence itself. Protect against this:
try
    close(this.DataSource);
%     deleteAllChildren(this.DataSource)
catch e %#ok
end

this.DataSource = [];

% Close the MPlay window
delete(this.Parent);
delete(this.ScopeCfg);
uiscopes.manager('remove', this);

% this.UIMgr = [];
% unrender(this.UIMgr, true);
deleteAllChildren(this.UIMgr);

delete(this);

% [EOF]
