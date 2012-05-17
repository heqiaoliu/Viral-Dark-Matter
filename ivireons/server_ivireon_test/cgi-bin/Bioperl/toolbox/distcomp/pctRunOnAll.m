function pctRunOnAll(varargin)
%pctRunOnAll run a command on all members of a matlabpool
%  pctRunOnAll allows a user to specify commands that should be run on
%  all matlabs in a matlabpool. This is useful if there is setup or
%  configuration changes than need to be done on all the processes
%  including this one.
%
%  SYNTAX
%
%  pctRunOnAll COMMAND runs the string command on all the workers and
%  prints any command line output back to this command window. The
%  requested COMMAND will be run in the base workspace of the workers and
%  does not have any return variables.
%
%  EXAMPLES
%
%  Clear all loaded functions on all matlabs
%    pctRunOnAll clear functions
%
%  Change directory on all workers to the project directory
%    pctRunOnAll cd /opt/projects/c1456
%
%  Add a few directories to all the paths
%    pctRunOnAll addpath({'/usr/local/path1' '/usr/local/path2'})
%
%   See also : matlabpool 

%   Copyright 2007 The MathWorks, Inc.

command = iParseRunOnAllArgs(varargin{:});
session = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession;
if isempty(session) || ~session.isSessionRunning
    error('distcomp:pctrunonall:NotRunning', ...
        'Cannot execute pctRunOnAll %s \nwhen matlabpool is not running.', command);
end
l = session.getLabs();
if isempty( l )
    error( 'distcomp:pctrunonall:RunOnClient', ...
           ['pctRunOnAll must be run either from the client, or the leading \n', ...
            'task in a matlabpool job'] );
end
o = com.mathworks.toolbox.distcomp.pmode.RunOnAllCompletionObserver(l.getNumLabs);
% Labs.eval includes the deadlock detection
l.eval(command, o);
evalin('base', command);

while (~o.waitForCompletion(1, java.util.concurrent.TimeUnit.SECONDS))
    if ~session.isSessionRunning
        error('distcomp:pctrunonall:NotRunning', ...
            'The matlabpool on which the command was run has been shut down');
    end
end

end
% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function command = iParseRunOnAllArgs(varargin)
% iParseRunOnAllArgs checks that we can create a single string from
% varargin
if numel(varargin) == 0
    command = '';
    return
end
% Ensure that all elements of varargin are strings 1xN
if (all(cellfun(@ischar, varargin) &  ...
        cellfun(@(C) size(C, 2), varargin) == cellfun(@numel, varargin)))
    command = sprintf('%s ', varargin{:});
else
    error('distcomp:pctrunonall:InvalidInput', 'Command input to pctRunOnAll must be all strings')
end
end
