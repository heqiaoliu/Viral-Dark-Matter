function dctRunOnAll(varargin)
%dctRunOnAll has been deprecated. Please use pctRunOnAll
%  dctRunOnAll allows a user to specify commands that should be run on
%  all matlabs in a matlabpool. This is useful if there is setup or
%  configuration changes than need to be done on all the processes
%  including this one.
%
%  SYNTAX
%
%  dctRunOnAll COMMAND runs the string command on all the workers and
%  prints any command line output back to this command window. The
%  requested COMMAND will be run in the base workspace of the workers and
%  does not have any return variables.
%
%  EXAMPLES
%
%  Clear all loaded functions on all matlabs
%    dctRunOnAll clear functions
%
%  Change directory on all workers to the project directory
%    dctRunOnAll cd /opt/projects/c1456
%
%  Add a few directories to all the paths
%    dctRunOnAll addpath({'/usr/local/path1' '/usr/local/path2'})
%
%   See also : pctRunOnAll, matlabpool 

%   Copyright 2007 The MathWorks, Inc.

warning('distcomp:dctrunonall:DeprecatedFunction', ...
    ['The dctRunOnAll function is deprecated and will be removed in the\n' ...
    'next version of the Parallel Computing Toolbox. Please use the\n' ...
    'pctRunOnAll function instead.']);
warning('off', 'distcomp:dctrunonall:DeprecatedFunction');

% Call the replacement pctRunOnAll function
pctRunOnAll(varargin{:});