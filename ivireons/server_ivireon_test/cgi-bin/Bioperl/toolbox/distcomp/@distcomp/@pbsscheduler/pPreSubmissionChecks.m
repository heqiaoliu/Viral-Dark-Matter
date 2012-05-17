function clusterScriptExt = pPreSubmissionChecks( pbs, job, tasks )
; %#ok Undocumented
% pPreSubmissionChecks - check properties before we allow submission to
% proceed. Side-effect - calculate script extension on the cluster.

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:51:02 $

if numel( tasks ) < 1
    error('distcomp:pbsscheduler:InvalidState', ...
          'A job must have at least one task to submit to a PBS schdeuler');
end

% Warning to indicate that we are going to change CWD
if pbs.pCwdIsUnc
    warning('distcomp:pbsscheduler:DirectoryChange', ...
            ['The current working directory is a UNC path. To correctly execute PBS commands we will\n' ...
             'have to change to the directory given by tempdir. We will change back afterwards.%s'],'');
end

% Check for non-shared vs. parallel job
if isa( job, 'distcomp.simpleparalleljob' ) && ~pbs.HasSharedFilesystem
    error( 'distcomp:pbsscheduler:nonsharedParallel', ...
           'The PBS scheduler requires a shared filesystem for parallel jobs' );
end
    

% Set up script ending
switch pbs.ClusterOsType
  case 'pc'
    clusterScriptExt = '.bat';
  case 'unix'
    clusterScriptExt = '.sh';
  otherwise
    error( 'distcomp:pbsscheduler:UnsupportedCluster', ...
           ['The PBS scheduler cannot be used with ''mixed'' clusters. \n', ...
            'Please choose ''pc'' or ''unix'''] );
end

if isempty( getenv( 'MDCE_DEBUG' ) )
    % Ensure we can send the environment
    setenv( 'MDCE_DEBUG', 'false' );
end

