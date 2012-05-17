function flash(this, flashCount, period)
%FLASH   Alternate highliting of block connected to the Wired Scope.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/09/15 20:47:23 $

if isempty(this.flashTimer)
    if nargin < 3
        period = 0.2;
        if nargin < 2
            flashCount = 3;
        
        end
    end
    
    blkh = get(this,'BlockHandle');

    % Create timer object for the flash process.
    ht = timer( ...
        'ExecutionMode', 'FixedRate',...
        'TasksToExecute', 2*flashCount,...
        'Period',         period,...
        'TimerFcn',       @(htimer,ev)hilite_tick(blkh),...
        'StopFcn',        @(htimer,ev)hilite_stop(this, htimer, blkh));
    
    this.flashTimer = ht;
    
    %Bring the Parent model forward.
    parentObj = get_param(get(blkh,'Parent'),'Object');
    view(parentObj);
    
    %Start the timer to start flashing.
    start(ht);
end

% -------------------------------------------------------------------------
function hilite_tick(blkh)
% Hilite the block.

if ishandle(blkh)
    blkObj = get(blkh, 'Object');
    hstatus = get(blkObj,'hilite');
    if strcmp(hstatus,'none')
        hilite(blkObj,'on');
    else
        hilite(blkObj,'off');
    end
end

% -------------------------------------------------------------------------
function hilite_stop(this, htimer, blkh)
% Shutdown hilite.

% Clear the timer object
delete(htimer);

% If the block is still there, turn the highlighting off.  Do not get it
% from the object, because the object might be gone and the block might
% still exist.
if ishandle(blkh)
    blkObj = get(blkh,'Object');
    hilite(blkObj,'off');
end

% Clear the handle to the timer object if the source still exists.
if ishandle(this)
    this.FlashTimer = [];
end

% [EOF]
