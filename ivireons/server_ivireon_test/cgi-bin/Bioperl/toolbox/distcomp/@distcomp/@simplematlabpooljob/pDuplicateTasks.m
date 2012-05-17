function pDuplicateTasks( job )
; %#ok Undocumented
%pDuplicateTasks - create job.MaximumNumberOfWorkers-1 empty tasks.

% Copyright 2000-2010 The MathWorks, Inc.

% $Revision: 1.1.6.3 $    $Date: 2010/03/01 05:20:20 $ 

% At this point, assert that the job has 1 task, and a valid minimum number
% of workers.
if length( job.Tasks ) ~= 1
   error( 'distcomp:simplematlabpooljob:badnumberoftasks', ...
          'A MatlabPool job must contain 1 task prior to submission' );
end
if isinf( job.MaximumNumberOfWorkers )
    error( 'distcomp:simplematlabpooljob:badnumberofworkers', ...
           ['Please set the maximum number of workers to a finite ' ...
            'value prior to submission of a MatlabPool job']);
end

maxW        = job.MaximumNumberOfWorkers;
numToCreate = maxW - 1;
leadTask    = job.Tasks(1);
props       = { 'taskfunction', 'nargout', 'argsin', ...
                'capturecommandwindowoutput' };
serializer = job.Serializer;

if maxW > 1
    jobloc   = job.pGetEntityLocation;
    proxies  = serializer.Storage.createProxies( jobloc, numToCreate );
    tasks    = handle( -ones( 1, numToCreate ) );
    values   = serializer.getFields( leadTask, props );
    % Task is not duplicated 1:1. Instead, Tasks 2 - N get @distcomp.nop
    % for task function, zero output args and no input args.
    if ~job.pIsInteractivePool
        values{1} = @distcomp.nop;
    	values{2} = 0;
        values{3} = {};
    end
    
    for ii=1:numToCreate
        tasks(ii) = distcomp.createObjectsFromProxies( ...
            proxies(ii), job.DefaultTaskConstructor, job, 'norootsearch' );
        tasks(ii).pInitialiseLocation( proxies(ii), [], [], [] );
    end
    serializer.putFields( tasks, props, values );
end
