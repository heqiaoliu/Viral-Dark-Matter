function start(obj, type, nlabs, sched, gui, filedependencies)
; %#ok Undocumented
%start Start interactive session and show the GUI command window.
%   Start interactive session, or detect the presence of an active session.  Perform
%   all the setup and message display needed.  Displays the GUI.

%   Copyright 2006-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.15 $  $Date: 2010/02/25 08:01:21 $

% Error if we are already running an interactive job
if obj.isPossiblyRunning()
    error('distcomp:interactive:OpenConnection', ...
          ['Found an active interactive session.\n' ...
           'You cannot have multiple interactive sessions open simultaneously.\n', ...
           'To terminate the existing session, use   %s close\n'], obj.CurrentInteractiveType);
end

% Error if we are currently the wrong interactive type
obj.pCheckAndSetInteractiveType(type)

if nargin > 4
    openGUI = strcmp(gui, 'opengui');
else
    openGUI = true;
end

% ANY error in this function will trigger this onCleanup which calls
% pStopLabsAndDisconnect - it is only at the very end of this function that
% we say startup is complete.
obj.IsStartupComplete = false;
cleanupOnFailure = onCleanup(@() iCleanupIfStartupFailed(obj));

try
    % TODO: maybe pass in cfg.hostname to ConnectionManager constructor???
    % Is that the correct thing to do?
    connMgr = obj.pCreateConnectionManager();
catch err
    rethrow(err);
end

% We need the name of this machine to connect back to from the parallel
% job.  Get from pctconfig as it allows the user to override the default 
% hostname.
cfg = pctconfig();
hostname = cfg.hostname;

% Build the SocketAddress to connect back to - allowing the user to override
% the hostname. The InetSocketAddress constructor throws no exceptions.
% TODO: Here, we override the hostname from original socket address. Is that
% really the right thing to do?
origSockAddr = connMgr.getAddress();
sockAddr = java.net.InetSocketAddress( hostname, origSockAddr.getPort() );

% Remove finished and failed jobs.  Warn about queued and pending jobs.
try
    obj.pRemoveOldJobs(sched);
catch err
    % Need to close the ConnectionManager
    throw( MException(err.identifier,...
        'Failed to locate and destroy old interactive jobs.\nThis is caused by: \n%s', err.message) );
end

% At this point, we know that the configuration worked, so we can print messages
% to the user.  Make sure we don't leave this function without printing the
% final newline.
cleanup = onCleanup(@() fprintf('\n'));  
fprintf('Starting %s', type);
if ~isempty(sched.Configuration)
    fprintf(' using the ''%s'' configuration ... ', sched.Configuration);
else
    fprintf(' ... ');
end

% Create and store the parallel job.
try
    obj.pCreateParallelJob(sched, nlabs, sockAddr);
    if strcmp(type, 'matlabpool')
        obj.ParallelJob.PathDependencies = [obj.ParallelJob.PathDependencies(:) ; iGenerateMatlabpoolPath];
        if ~isempty( filedependencies )
            obj.ParallelJob.FileDependencies = [filedependencies(:) ; obj.ParallelJob.FileDependencies(:)];
        end
    end
    submit(obj.ParallelJob);
catch err
    throw( MException(err.identifier,...
        'Failed to start %s.\nThis is caused by:\n%s', type, err.message) );
end

% Wait for the labs to connect back to the client.
if isempty(nlabs)
    nlabs = inf; % Set to match the expectations of pGetSockets.
end
try
    schans = obj.pGetSockets(nlabs);
catch err
    % pGetSockets rewrites the error.
    rethrow(err);
end

% Create the Java objects for this interactive session.
try
    % SessionFactory takes ownership of the Sockets as well as the Session.
    com.mathworks.toolbox.distcomp.pmode.SessionFactory.createClientSession(schans);
    session = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession();
    % Now that we have a session we should add the file dependencies so
    % that they are well known to subsequent changes
    fda = session.getFileDependenciesAssistant;
    filedependencies = obj.ParallelJob.FileDependencies;
    % Only 
    cwd = pwd;
    for i = 1:numel( filedependencies )
        fda.addClientDependency( cwd, filedependencies{i} );
    end
    % Once created we should loop waiting for all labs to finish starting
    % up
    while ~session.waitForSessionToStart(100, java.util.concurrent.TimeUnit.MILLISECONDS);
    end
catch err
    throw( MException(err.identifier,...
        'Failed to initialize the interactive session.\nThis is caused by:\n%s', err.message) );
end


% For a matlabpool session tell the session to listen for Path and Clear
% notification and send them onto the labs
if strcmp(type, 'matlabpool')
    try
        session.startSendPathAndClearNotificationToLabs;
    catch err
        throw( MException(err.identifier,...
            'Failed to initialize the interactive session.\nThis is caused by:\n%s', err.message) );
    end
end

% Only open the GUI if the start command requested it
if openGUI
    try
        com.mathworks.toolbox.distcomp.parallelui.ParallelUI.start(session.getLabs());
    catch err
        throw( MException(err.identifier,...
            'Failed to initialize the interactive session.\nThis is caused by:\n%s', err.message) );
    end
end
obj.IsGUIOpen = openGUI;

try
    fprintf('connected to %d labs.', session.getPoolSize());
    obj.IsStartupComplete = true;
catch err %#ok<NASGU>
end


function iCleanupIfStartupFailed(obj)
if ~obj.IsStartupComplete
    obj.pStopLabsAndDisconnect();
end


function cellPath  = iGenerateMatlabpoolPath
% Find all elements of the matlab path that are not under $MATLABROOT

% Convert the path the a cell array of strings
cellPath = strread(path, '%s', 'delimiter', pathsep);

if isdeployed
    % When deployed we also remove any toolbox code under ctfroot
    rootsToRemove = {matlabroot, fullfile( ctfroot, 'toolbox' )};
else
    rootsToRemove = {matlabroot};
end

for n = 1:length( rootsToRemove )
    thisRoot = rootsToRemove{n};
    % Which parts of poath start with thisRoot
    toRemove = strncmp(cellPath, thisRoot, numel(thisRoot));
    cellPath(toRemove) = [];
end
