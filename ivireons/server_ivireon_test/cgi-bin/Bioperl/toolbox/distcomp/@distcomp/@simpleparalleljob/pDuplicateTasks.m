function pDuplicateTasks( job )
; %#ok Undocumented
%pDuplicateTasks - copy the single defining task prior to submission
%  We make job.MaximumNumberOfWorkers copies.


%  Copyright 2000-2010 The MathWorks, Inc.
%  $Revision: 1.1.10.5 $    $Date: 2010/03/01 05:20:21 $ 

% At this point, assert that the job has 1 task, and a valid minimum number
% of workers.
if length( job.Tasks ) ~= 1
   error( 'distcomp:simpleparalleljob:badnumberoftasks', ...
          'A parallel job must contain 1 task prior to submission' );
end
if isinf( job.MaximumNumberOfWorkers )
    error( 'distcomp:simpleparalleljob:badnumberofworkers', ...
           'Please set the maximum number of workers to a finite value prior to submission of a parallel job' );
end

maxW        = job.MaximumNumberOfWorkers;
numToCreate = maxW - 1;
leadTask    = job.Tasks(1);
props       = { 'taskfunction', 'nargout', 'argsin', 'capturecommandwindowoutput' };

if maxW > 1
    jobloc   = job.pGetEntityLocation;
    proxies  = job.Serializer.Storage.createProxies( jobloc, numToCreate );
    tasks    = handle( -ones( 1, numToCreate) );
    values   = job.Serializer.getFields( leadTask, props );
    
    for ii=1:numToCreate
        tasks(ii) = distcomp.createObjectsFromProxies( ...
            proxies(ii), job.DefaultTaskConstructor, job, 'norootsearch' );
        tasks(ii).pInitialiseLocation( proxies(ii), [], [], [] );
    end
    job.Serializer.putFields( tasks, props, values );
end
