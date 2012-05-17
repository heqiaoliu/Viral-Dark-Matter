%% Dividing MATLAB(R) Computations into Tasks
% The Parallel Computing Toolbox(TM) enables us to execute our
% MATLAB(R) programs on a cluster of computers. In this demo, we look
% at how to divide a large collection of MATLAB operations into smaller
% work units, called tasks, which the workers in our cluster can execute.
% We will do this programmatically using the
% |pctdemo_helper_split_scalar| and
% |pctdemo_helper_split_vector| functions.
%
% Prerequisites:
% 
% * <paralleltutorial_defaults.html
% Customizing the Settings for the Demos in the Parallel Computing Toolbox>
%
% For further reading, see: 
%
% * <paralleltutorial_taskfunctions.html Writing Task Functions>
% * <paralleltutorial_network_traffic.html Minimizing Network Traffic>
% * <paralleltutorial_callbacks.html Using Callback Functions> 

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/11/07 20:52:29 $

%% Obtaining the Configuration
% Like every other demo in the Parallel Computing Toolbox, this demo needs to
% know what scheduler to use.  We use the scheduler identified by the default
% configuration.  See the
% <matlab:helpview(fullfile(docroot,'toolbox','distcomp','distcomp_ug.map'),'configurations_help')
% configurations documentation>
% for how to create new configurations and how to change the default
% configuration.
configName = defaultParallelConfig();

%% Starting with Sequential Code
% One of the important advantages of the Parallel Computing Toolbox is that
% it builds very well on top of existing sequential code.  It is actually
% beneficial to focus on sequential MATLAB code during the algorithm
% development, debugging and performance evaluation stages, because we then
% benefit from the rapid prototyping and interactive editing, debugging, and
% execution capabilities that MATLAB offers.  During the development of
% the sequential code, we should separate the computations from the pre- and the
% postprocessing, and make the core of the computations as simple and
% independent from the rest of the code as possible.  Once our code is somewhat
% stable, it is time to look at distributing the computations.  If we do a good
% job of creating modular sequential code for a coarse grained application, it
% should be rather easy to distribute those computations.

%% Analyzing the Sequential Problem
% The Parallel Computing Toolbox supports the execution of coarse grained
% applications, that is, independent, simultaneous executions of a single
% program using multiple input arguments.  We will now try to show examples of
% what coarse grained computations often look like in MATLAB code and explain
% how to distribute those kinds of computations.  We will focus on two common
% scenarios, arising when the original, sequential MATLAB code consists of
% either
%
% * Invoking a single function several times, using different values for the
% input parameter.  Computations of this nature area sometimes referred to as
% *parameter sweeps*, and the code often looks similar to the following MATLAB
% code:

%%
%         for i = 1:n
%           y(i) = f(x(i));
%         end

%%
% * Invoking a single stochastic function several times.  Suppose that the
% calculations of |g(x)| involve random numbers, and the function thus returns a
% different value every time it is invoked (even though the input parameter |x|
% remains the same).  Such computations are sometimes referred to as *Monte
% Carlo simulations*, and the code often looks similar to the following MATLAB
% code:

%%
%         for i = 1:n
%           y(i) = g(x);
%         end

%%
% It is quite possible that the parameter sweeps and simulations appear in a
% slightly different form in our sequential MATLAB code.  For example, if the
% function |f| is vectorized, the parameter sweep may simply appear as

%%
%         y = f(x);

%%
% and the Monte Carlo simulation may appear as

%%
%         y = g(x, n);

%% Example: Dividing a Simulation into Tasks
% We will use a very small example in what follows, using the |rand| function
% as our function of interest.  Imagine that we have a cluster with four
% workers, and we want to divide the function call |rand(1, 10);| between them.
% We will use four tasks, and have them generate random vectors of length 3, 3,
% 2, and 2.  We can do this in a single function call
y = dfeval(@rand, {[1, 3], [1, 3], [1, 2], [1, 2]}, ...
           'Configuration', configName);
celldisp(y)

%%
% or, alternatively, you can use |createJob| and |createTask| to achieve the
% same goal.  We have created a function called |pctdemo_helper_split_scalar|
% that helps divide the generation of the 10 random numbers between the 4 tasks:
numRand = 10; % We want this many random numbers.
numTasks = 4; % We want to split into this many tasks.
sched = findResource('scheduler', 'Configuration', configName);
job = createJob(sched);
[numPerTask, numTasks] = pctdemo_helper_split_scalar(numRand, numTasks);

%%
% Notice how |pctdemo_helper_split_scalar| splits the work of generating 10
% random numbers between the |numTasks| tasks.  The elements of |numPerTask| are
% all positive, the vector length is |numTasks|, and its sum equals |numRand|:

disp(numPerTask)

%%
% We can now write a for-loop that creates all the tasks in the job. Task |i| is
% to create a matrix of the size 1-by-numPerTask(i). When all the tasks have
% been created, we submit the job, wait for it to finish, and then retrieve the
% results.
for i = 1:numTasks
   createTask(job, @rand, 1, {1, numPerTask(i)});
end
submit(job);
waitForState(job, 'finished');
y = getAllOutputArguments(job);
cat(2, y{:})   % Concatenate all the cells in y into one column vector.
destroy(job);

%% Example: Dividing a Parameter Sweep into Tasks
% For the purposes of this demo, let's use the |sin| function as 
% a very simple example. We let |x| be a vector of length 10:
x = 0.1:0.1:1;

%%
% and now we want to distribute the calculations of |sin(x)| on a
% cluster of 4 computers.  We would like the 4 workers to evaluate
% |sin(x(1:3))|, |sin(x(4:6))|, |sin(x(7:8))| and |sin(x(9:10))|
% simultaneously. Because this kind of a division of a parameter
% sweep into separate tasks occurs frequently in our demos, we have
% created a function that does exactly that:
numTasks = 4;
[split, numTasks] = pctdemo_helper_split_vector(x, numTasks);
celldisp(split);

%%
% and it is now easy to use either |dfeval|, or |createJob| and
% |createTask|, to perform the computations:
y = dfeval(@sin, split, 'Configuration', configName);
cat(2, y{:})  % Concatenate all the cells in y into one column vector.

%%
% or, alternatively:
job = createJob(sched);
for i = 1:numTasks
   createTask(job, @sin, 1, {split{i}});
end
submit(job);
waitForState(job, 'finished');
y = getAllOutputArguments(job);
destroy(job);
cat(2, y{:})  % Concatenate all the cells in y into one column vector.

%% More on Parameter Sweeps
% The example involving the |sin| function was particularly simple,
% because the |sin| function is vectorized.  We look at how to deal
% with nonvectorized functions in the 
% <paralleltutorial_taskfunctions.html Writing Task Functions> demo. 

%% Dividing MATLAB Operations into Tasks: Best Practices
% When we decide how to divide our computations into smaller tasks,
% we have to pay attention to the following:
%
% * The number of function calls we want to make
% * The time it takes to execute each function call
% * The number of workers that we want to utilize in our cluster
%
% We want at least as many tasks as there are workers so that we can possibly
% use all of them simultaneously, and this encourages us to break our work into
% small units.  On the other hand, there is an overhead associated with each
% task, and that encourages us to minimize the number of tasks.  Consequently,
% we arrive at the following:
%
% * If we only need to invoke our function a few times, and it takes only 
% one or two seconds to evaluate it, we are better off not using the Parallel
% Computing Toolbox.  Instead, we should simply perform our computations using
% MATLAB running on our local machine.
%
% * If we can evaluate our function very quickly, but we have to calculate many
% function values, we should let a task consist of calculating a number of
% function values.  This way, we can potentially use many of our workers
% simultaneously, yet the task and job overhead is negligible relative to the
% running time.  Note that we may have to write a new task function to do this,
% see the
% <paralleltutorial_taskfunctions.html Writing Task Functions> demo.
% The rule of thumb is: The quicker we can evaluate the function, the more  
% important it is to combine several function evaluations into a single task.
%
% * If it takes a long time to invoke our function, but we only need to
% calculate a few function values, it seems sensible to let one task consist
% of calculating one function value.  This way, the startup cost of the job
% is negligible, and we can have several workers in our cluster work 
% simultaneously on the tasks in our job.
%
% * If it takes a long time to invoke our function, and we need to calculate 
% many function values, we can choose either of the two approaches we
% have presented: let a task consist of invoking our function once or several
% times. 
% 
% There is a drawback to having many tasks in a single job: Due to network
% overhead, it may take a long time to create a job with a large number of
% tasks, and during that time the cluster may be idle.  It is therefore
% advisable to split the MATLAB operations into as many tasks as needed, but to
% limit the number of tasks in a job to a reasonable number, say never more than
% a few hundred tasks in a job.


displayEndOfDemoMessage(mfilename)
