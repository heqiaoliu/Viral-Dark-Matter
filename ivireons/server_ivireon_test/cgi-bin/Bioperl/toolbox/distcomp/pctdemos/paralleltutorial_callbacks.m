%% Using Callback Functions
% In this demo we see how to use callback functions in the Parallel Computing Toolbox(TM)
% to notify us when a task has completed and to update graphics when
% task results are available.  We also see how to use the |UserData| property of
% the job to pass data back and forth between the MATLAB(R) session and the
% callback functions.
%
% Prerequisites:
% 
% * <paralleltutorial_defaults.html
% Customizing the Settings for the Demos in the Parallel Computing Toolbox>
%
% For further reading, see: 
%
% * <paralleltutorial_dividing_tasks.html
% Dividing MATLAB Computations into Tasks>
% * <paralleltutorial_taskfunctions.html Writing Task Functions>
% * <paralleltutorial_network_traffic.html Minimizing Network Traffic>

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/22 03:42:35 $

%% Reviewing the Callbacks
% The Parallel Computing Toolbox offers us the ability to have a
% user-defined function be invoked when these events occur:
%
% * A job is queued
% * A job starts running
% * A task starts running
% * A task finishes
% * A job finishes
%
% Note, however, that callbacks are only available with the job manager, and not
% with other schedulers.  Consequently, we start this demo by making sure that
% we are using a job manager.
configName = defaultParallelConfig();
manager = findResource('scheduler', 'Configuration', configName);
if ~isa(manager, 'distcomp.jobmanager')
    error('distcomp:demo:NotJobmanager', ...
          ['This demo uses callbacks, which are only available with ' ...
           'a job manager.']);
end

%% Example: Creating a Trivial Task Finished Callback Function
% Let's start with creating a simple task finished callback function.  Its
% only purpose is to display the date and time of completion.  Because the task
% finished callback function is so simple, we will create it as an anonymous
% function instead of writing it in a separate MATLAB file.
callbackfcn = @(mytask, eventdata) disp(datestr(clock));

%%
% We can even invoke this function at the command line, and it will print the
% current day and time.
callbackfcn();

%%
% We can create a job and a task whose |FinishedFcn| property is set
% to be |callbackfcn|.  We then submit the job and wait for it to finish.
% MATLAB will then invoke the |callbackfcn| function when the task changes its
% status to finished.
job = createJob(manager);
task = createTask(job, @sqrt, 1, {2});
set(task, 'FinishedFcn', callbackfcn);
submit(job);
waitForState(job, 'finished');
destroy(job);

%% Example: Using the UserData Property to Track the Number of Remaining Tasks
% We now enhance the previous example to show how the task finished callback
% function can use the |UserData| property of the job to access the MATLAB
% workspace on the client computer.  Consider the following example: We use a
% counter to keep track of how many tasks are running, and the task finished
% callback function decrements this counter and displays its value.  We store
% the counter in the |UserData| property of the job, and the task finished
% function can access the job through the |Parent| property of the task.
type pctdemo_taskfin_callback1

%%
% Let's create a small job with |numTasks| tasks and see what the output of
% the task finished callback function looks like.
job = createJob(manager);
numTasks = 5;
set(job, 'UserData', numTasks);
for i = 1:numTasks
    task = createTask(job, @sqrt, 1, {i});
    set(task, 'FinishedFcn', @pctdemo_taskfin_callback1);
end
submit(job);
waitForState(job, 'finished');
destroy(job);

%% Example: Updating the Graphics in the Callback Function
% We now turn to a more advanced use of the task finished callback
% function, namely, using it to add data points to a graph depicting the
% task results.  Let's have a look at the callback function:
type pctdemo_taskfin_callback2;

%%
% The way we set up this example, we prepare the graph for plotting by invoking
% the function |pctdemo_taskfin_callback2_setup| to generate a figure with an
% empty graph.  Let us have a look at that function:
type pctdemo_taskfin_callback2_setup;
%%
% We now run the function to display the empty graph.
pctdemo_taskfin_callback2_setup();

%%
% For demonstration purposes, we let task |i| calculate |sqrt(i)|.  The task
% finished callback function then adds the task results to the graph that
% depicts all the results obtained so far.  We use a large number of tasks to
% emphasize how the graph is gradually built as the job results trickle in, and
% we perform a random shuffle on the sequence |1:numTasks| to make the values of
% the square root function arrive in a truly random order.
job = createJob(manager);
numTasks = 20;
seq = randperm(numTasks); % Random shuffle of the sequence 1:numTasks.
for i = seq
    task = createTask(job, @sqrt, 1, {i});
    set(task, 'FinishedFcn', @pctdemo_taskfin_callback2);
end
submit(job);
waitForState(job, 'finished');
destroy(job);


displayEndOfDemoMessage(mfilename)
