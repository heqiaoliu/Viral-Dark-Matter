function deleteDialogPanel(dp)
% Clean up resource allocations for DialogPanel

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:38 $

% Delete auto-scroll timer object
t = dp.hAutoScrollTimer;
if isa(t,'timer') && isvalid(t)
    % Wait for timer to stop before deleting
    %
    % For a periodic timer, tasks to execute must be < inf for wait to
    % work properly
    set(t,'TasksToExecute',1);
    stop(t); waitfor(t); delete(t);
    dp.hAutoScrollTimer = [];
end

% Delete auto-hide timer object
t = dp.hAutoHideTimer;
if isa(t,'timer') && isvalid(t)
    % Wait for timer to stop before deleting,
    % in case a time-out was still pending
    stop(t); waitfor(t); delete(t);
    dp.hAutoHideTimer = [];
end
