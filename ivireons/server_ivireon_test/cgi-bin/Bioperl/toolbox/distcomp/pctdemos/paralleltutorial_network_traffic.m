%% Minimizing Network Traffic
% In this demo, we look at how we can reduce the run time of our jobs in the
% Parallel Computing Toolbox(TM) by minimizing the network traffic.  It is
% likely that the network bandwidth is severely limited, especially when
% considered relative to memory transfer speeds, and we therefore have a strong
% incentive to make the most efficient use of it.  Additionally, the Parallel
% Computing Toolbox has limitations on the sizes of the MATLAB(R) objects that the
% tasks can receive and return, and we will look at how we can work around them.
% In particular, we will discuss how to use the file system and show some of the
% advantages and the disadvantages of using it.
%
% Prerequisites:
% 
% * <paralleltutorial_defaults.html
% Customizing the Settings for the Demos in the Parallel Computing Toolbox>
% * <paralleltutorial_dividing_tasks.html
% Dividing MATLAB Computations into Tasks>
% * <paralleltutorial_taskfunctions.html Writing Task Functions>
%
% For further reading, see: 
%
% * <paralleltutorial_callbacks.html Using Callback Functions>

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:07 $

%% Reducing the Amount of Data Returned
% If heavy network traffic is causing our jobs to slow down, the first question
% is whether we really need all the data that is being transmitted.  If not, we
% should write a wrapper task function that drops the redundant data and only
% returns what is necessary.  You can see an example of that in 
% the <paralleltutorial_taskfunctions.html Writing Task Functions> demo.

%% Using the JobData Property of the Job
% When using a job manager, it is possible to use the JobData property of the
% job to minimize the job and the task creation times by reducing the data
% transfer over our network. If the task input data is large and it is shared
% between all the tasks in a job, we may benefit from passing it to the task
% functions through the |JobData| property of the job rather than as an input
% argument to all the task functions.  This way, the data is only transmitted
% once to the job manager instead of being passed once for each task.

%%
% Let's use a simple example to illustrate the syntax involved.  We let
% the task function consist of calculating |x.^p|, where |x| is a fixed
% vector and |p| varies.  This implies that |x| will be stored in the
% |JobData| property of the job and |p| will be passed as the input argument
% to the task function.   
% The task function uses the |getCurrentJob| function to obtain the job
% object, and obtains the |JobData| through that job object.
type pctdemo_task_tutorial_network_traffic;
%%
% We can now create a job whose |JobData| property is set to |x|.
configName = defaultParallelConfig();
sched = findResource('scheduler', 'Configuration', configName);
set(sched, 'Configuration', configName);
job = createJob(sched);
x = 0:0.1:10;
set(job, 'JobData', x);

%%
% We create the tasks in the job, one task for each value of |p|.  Note that 
% the tasks' function only has |p| as its input argument.
pvec = [0.1, 0.2, 0.3, 0.4, 0.5];
for p = pvec
    createTask(job, @pctdemo_task_tutorial_network_traffic, 1, {p});
end
submit(job);
%%
% We can now return to the MATLAB prompt and continue working while waiting for
% the job to finish.  Alternatively, we can block the prompt until the job has
% finished:
waitForState(job, 'finished');

%%
% Since we have finished using the job object, we destroy it.
destroy(job);

%% When to Use a Shared File System
% If we want the workers to process data that already exists on a shared file
% system, we use the |PathDependencies| property of the job.  All the directory
% names that we put into that cell array are added to the path on the workers,
% thereby making them easy for us to access.  The user that the workers run as
% must have the permissions required to read from those directories.

%%
% Regarding the question of when it is appropriate to write data to the shared
% file system in the MATLAB client to make it available to the workers, or vice
% versa, we have to keep in mind that shared file systems often have high
% latency.  Consequently, if we have followed the advice given above and we are
% transferring only objects that are a few hundred kilobytes in size, we are
% probably better off not using the file system explicitly, but instead relying
% on the transfer mechanism that is built into the Parallel Computing
% Toolbox.  However, when using the job manager, it is probably better to use
% the file system when transferring objects that are tens of megabytes in size
% or larger.

%% Handling Delayed Updates of a Shared File System
% Some network file systems trade off latency for network efficiency through
% delayed updates.  Delayed updates can cause problems if the client computer
% expects files generated on the workers to be immediately available.  For this
% reason, we recommend avoiding reading task output files in the task finished
% callback functions.  As a rule of thumb, we  should not expect files written 
% on one computer to be immediately available on all other computers.

%% Writing to a Shared File System on a Homogeneous Cluster
% It is easy to communicate through a shared filesystem on a homogeneous
% cluster by using the |load| and |save| functions in MATLAB.  Of course, the
% client and the workers must have permission to read and write the input
% and output files.  If the cluster consists of Windows(R) machines, we also have
% to remember to use only UNC paths and not the names of mapped network
% drives. That is, we can only use full filenames of the form
f = '\\mycomputer\user\subdir\myfile.mat';
%%
% and not
f = 'h:\subdir\myfile.mat'; 

%%
% because network mappings, such as that of |\\mycomputer\user| to |h:|, may
% only work on the client machine and MATLAB may not have access to those
% mappings on the workers.

%% Writing to a Shared File System on a Heterogeneous Cluster
% Using a shared file system can be more difficult if it does not look the same
% from the workers and the clients.  The Parallel Computing Toolbox demos
% show one way of solving that problem in the case of a mixed environment of
% Windows and UNIX(R) computers.  Let's assume that the path names
pcdir = '\\mycomputer\user\subdir';
unixdir = '/home/user/subdir';

%%
% refer to the same directory on the file server, and that the former is valid
% on all of our Windows computers and the latter is valid on all of our UNIX
% computers.  We can tell the Parallel Computing Toolbox demos about this
% association and allow it to use this directory for writing temporary files by
% issuing the command
orgconf = paralleldemoconfig();
paralleldemoconfig('NetworkDir', struct('pc', pcdir, 'unix', unixdir));

%%
% When the demos need to write a file to the file system, they look at the
% |NetworkDir| field of the |paralleldemoconfig| structure: 
conf = paralleldemoconfig();
netDir = conf.NetworkDir

%%
% Given a filename, such as |'myfile.mat'| from above, the demos pass the 
% |netDir| structure and |'myfile.mat'| to the workers.  The workers can then
% choose whether to use
%
%   fullfile(netDir.pc, 'myfile.mat')
%
% or
%
%   fullfile(netDir.unix, 'myfile.mat')
%
% according on what platform they are on.  This platform-dependent choice has
% been wrapped into the demo function |pctdemo_helper_fullfile|:
type pctdemo_helper_fullfile;

%%
% so that the workers actually call only
f = pctdemo_helper_fullfile(netDir, 'myfile.mat');

%%
% and they will then receive the correct, full filename of |myfile.mat|.

%% Restoring the Original Settings
% We do not want this tutorial to change the default demo settings, so we
% restore their original values.
paralleldemoconfig(orgconf);

displayEndOfDemoMessage(mfilename)
