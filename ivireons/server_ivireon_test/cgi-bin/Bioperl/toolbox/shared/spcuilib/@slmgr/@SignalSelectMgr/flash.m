function flash(this, flashCount, period)
%FLASH Alternate highlighting of lines/blocks

% Copyright 2005 The MathWorks, Inc.

% Also, if timer is already running, we're apparently still
% waiting for the current hilite operation to complete
% and we should not proceed
%
if isempty(this.flashTimer)
    
    if nargin < 3
        period = 0.2;
        if nargin < 2
            flashCount = 3;
        end
    end
    
    % Start flash procedure
    %
    % Note: currently, we do not allow another "flash" request to
    % come in until current flash request is completed.
    ht = timer( ...
        'ExecutionMode',  'FixedRate', ...
        'TasksToExecute', 2*flashCount, ...
        'Period',         period, ...
        'TimerFcn',       @(hTimer, ev) hilite_tick(this), ...
        'StopFcn',        @(hTimer, ev) hilite_stop(this, hTimer));
    
    this.flashTimer = ht;     % store object handle
    
    % Bring system forward/focus
    view(this.Signals(1).System);
    
    start(ht); % Start the flashing by starting the timer
end

% ----------------------------------
function hilite_tick(this)

% Toggle highlight state
if isa(this, 'slmgr.SignalSelectMgr')
    this.hilite('toggle');
end

% ------------------------------------------
function hilite_stop(this, hTimer)
% Shut down highlighting

% Make sure highlighting is indeed off.  However, if hilite is on at the
% start do we want to turn it off?
delete(hTimer);          % must not leave timer dangling
if isa(this, 'slmgr.SignalSelectMgr')
    this.hilite('off');
    set(this, 'flashTimer', []);    % clear handle - make this the last step
end

% [EOF]
