function pPostJobEvaluate(job)
; %#ok Undocumented
%pPostJobEvaluate
%
%  pPostJobEvaluate(JOB)

% Copyright 2005-2007 The MathWorks, Inc.

% $Revision: 1.1.10.9 $    $Date: 2008/12/29 01:48:15 $ 

% We shall try and determine if this job should be treated as finished.
try
    % This method 
    
    task = getCurrentTask;
    if ~isempty( task.ErrorMessage )
        serializer = job.Serializer;
        % This is a race for all the workers to try and put the job state 
        % and finish time in the job file - so we need to lock the serializer
        % beforehand
        aLock = serializer.lock(job);
        if ~strcmp(job.State, 'finished')
            % An error occurred - abort!
            serializer.putFields(job, {'state' 'finishtime'}, ...
                                 {'finished' char(java.util.Date)});            
        end
        serializer.release(aLock);
        % This quits MATLAB hard on all the workers, providing workers were started
        % using mpiexec.
        mpigateway( 'abort' );
    end
    
    % Get the parent of this job and make sure it's an abstract scheduler
    scheduler = job.Parent;
    if ~isa(scheduler, 'distcomp.abstractscheduler')
        return
    end


    % Ensure all tasks get here, with error detection
    mpigateway( 'setidle' );
    mpigateway( 'setrunning' );
    labBarrier;

    % Decide now whether this task should modify the job state, because after
    % we've called mpiParallelSessionEnding, we wont be able to tell (all
    % tasks will then think that they have labindex==1)
    shouldSetJobState = (scheduler.HasSharedFilesystem && job.pCanModifyJobOnWorker);

    % This is the end of a parallel session
    mpiParallelSessionEnding;
    mpiFinalize;
    
    % Now that all tasks are here, we can define the job to be finished. (This is
    % different to how a standard job behaves)
    if shouldSetJobState
        job.Serializer.putFields( job, {'state', 'finishtime'}, ...
                                  {'finished', char( java.util.Date )} );
    end

catch e %#ok<NASGU>
    % Do nothing with the caught exception
end
