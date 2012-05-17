function sched = pGetScheduler(config)
; %#ok Undocumented
% Find the scheduler from a configuration name.
%
% schd = pGetScheduler( 'configurationName' ) returns a scheduler found
% using the configuration. If the configurationName doesn't uniquely
% identify a scheduler then an error is throw.
%
%   Copyright 2006-2008 The MathWorks, Inc.

sched = findResource('scheduler', 'configuration', config);

if numel(sched) == 1
    set(sched, 'Configuration', config);
    return;
end

% Error handling follows.
% Generate the message to explain to users how to find information
% on solving the problem. If we are using the desktop, we can hyperlink the
% docsearch command.
docsearchStr = 'docsearch(''Programming with User Configurations'')';
if usejava('desktop')
    docsearchStr = sprintf( '<a href="matlab:%s">%s</a>', docsearchStr, docsearchStr );
end
msgModifyConfig = sprintf( ...
    [ ...
        'To learn how to modify your configuration to uniquely identify '...
        'your scheduler execute the command:\n' ...
        '  %s\n' ...
    ], docsearchStr );

% Throw the appropriate error.
if isempty(sched)
    error( 'distcomp:configuration:NoScheduler',...
        'Could not find a scheduler when using the configuration ''%s''.\n%s',...
        config, msgModifyConfig);
else
    error( 'distcomp:configuration:NoScheduler', ...
        'Found %d schedulers when using the configuration ''%s''.\n%s',...
        numel(sched), config, msgModifyConfig);
end

