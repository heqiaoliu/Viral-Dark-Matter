function cleanup(obj, type, config)
; %#ok Undocumented
%Remove all interactive jobs owned by the current user.

%   Copyright 2006 The MathWorks, Inc.

if isempty(config)
    % Use the default parallel configuration if no configuration is specified.
    config = defaultParallelConfig();
else
    % Check we have a valid configuration
    distcompConfigSection(config, 'findResource');
end
% Error if we are currently the wrong interactive type
obj.pCheckAndSetInteractiveType(type)

% Get the job tag we should look for as the stopLabsAndDisconnect might set
% that to an invalid value
tag = obj.Tag;
% Give a current session a chance to shutdown.
if obj.isPossiblyRunning()
    obj.pStopLabsAndDisconnect();
end
% Indicate that we are finished with this session
obj.CurrentInteractiveType = 'none';

sched = obj.pGetScheduler(config);
jobs = sched.findJob('Tag', tag, 'UserName', obj.UserName);

if isempty(jobs) 
    fprintf(['Did not find any pre-existing parallel jobs '...
             'created by %s.\n\n'], type);
else
    fprintf(['Destroying %d pre-existing parallel job(s) ' ...
             'created by %s.\n\n'], length(jobs), type);
    jobs.destroy;
end
