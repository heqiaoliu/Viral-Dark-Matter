function pctdemo_taskfin_bench(task, eventData)
%PCTDEMO_TASKFIN_BENCH Collect task results and update output graph.
%   The function performs the task postprocessing for the Parallel Computing
%   Toolbox Benchmarking demo.  It acquires the output data from the task and 
%   stores it.  It also updates a graph depicting all the results obtained so 
%   far.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:06:02 $
    
    % Get the output data for the task from the job manager.
    if isempty(task.OutputArguments)
        warning('distcomp:demo:EmptyTaskOutput', ...
                'Could not obtain task results');
        return;
    end
    outargs = task.OutputArguments{1};
    
    currWorker = task.Worker.Name;

    % The UserData property of the job stores the results of all the tasks
    % that have finished thus far.
    job = task.parent;
    jobdata = job.UserData;
    if isempty(jobdata)
        % The current task is the first task to finish.  Initialize the 
        % list of workers to the empty list and the measured times to the 
        % empty matrix.
        jobdata = { {}, [] };
    end
    workers = jobdata{1};
    times = jobdata{2};
    % Average over number of rows and produce a column vector of run times.
    currTime = mean(outargs, 1)';
    % Append the current results to the previous results.
    workers{end + 1} = currWorker;
    times(:, end + 1) = currTime;
    % Save all the results in the UserData property of the job.
    job.UserData = {workers, times};
    
    % Get the output figure.
    fig = get(task, 'UserData');
    if ishandle(fig)
        % Plot the updated results.
        pctdemo_plot_bench(fig, workers, times);
    end    
end % End of pctdemo_taskfin_bench.
