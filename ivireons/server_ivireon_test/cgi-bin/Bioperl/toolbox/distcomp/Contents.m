% Parallel Computing Toolbox
% Version 5.0 (R2010b) 03-Aug-2010
%
% General Toolbox Functions
%   batch                                 - Run script or function as batch job
%   clear                                 - Remove objects from MATLAB workspace
%   defaultParallelConfig                 - Control the default parallel computing configuration
%   dfeval                                - Evaluate function using a cluster of computers
%   dfevalasync                           - Evaluate function asynchronously using a cluster of computer
%   findResource                          - Find available distributed computing resources
%   get                                   - Return object properties
%   help                                  - Display help for toolbox functions in Command Window
%   importParallelConfig                  - Import a parallel computing configuration from file
%   inspect                               - Open Property Inspector
%   jobStartup                            - Job startup function for user-defined options
%   length                                - Return length of object array
%   matlabpool                            - Control an interactive matlabpool session
%   methods                               - List functions of object class
%   parfor                                - Parallel FOR-loop
%   pctconfig                             - Configure settings for Parallel Computing Toolbox client session
%   pmode                                 - Control an interactive pmode session
%   set                                   - Configure or display object properties
%   size                                  - Return size of object array
%   taskFinish                            - Task finish function for user-defined options
%   taskStartup                           - Task startup function for user-defined options
%
% Toolbox Functions Used in Parallel Jobs and pmode
%   labBarrier                            - Block execution until all labs have reached this call
%   labBroadcast                          - Send data to all labs or receive data sent to all lab
%   labindex                              - Index of this lab
%   labProbe                              - Test to see if messages are ready to be received
%   labReceive                            - Receive data from another lab
%   labSend                               - Send data to another specified lab
%   labSendReceive                        - Simultaneously send data to and receive data
%   mpiLibConf                            - Location of MPI implementation
%   mpiSettings                           - Configure options for MPI communication
%   numlabs                               - Total number of labs operating in parallel on current job
%   pmode                                 - Interactive parallel mode
%   spmd                                  - Single Program Multiple Data block allows 
%                                           more control over distributed arrays by 
%                                           providing access to them as codistributed 
%                                           arrays within the block  
%
% Scheduler and Job Manager Functions
%   batch                                 - Run script or function as batch job
%   createJob                             - Create job object
%   createParallelJob                     - Create parallel job object
%   createMatlabPoolJob                   - Create matlabpool job object
%   distcomp.jobmanager/findJob           - Find job objects stored in job queue
%   matlabpool                            - Control an interactive matlabpool session
%
% Job Manager-Specific Functions
%   distcomp.jobmanager/demote            - Demote job in job manager queue
%   distcomp.jobmanager/pause             - Pause job manager queue
%   distcomp.jobmanager/promote           - Promote job in job manager queue
%   distcomp.jobmanager/resume            - Resume processing queue in job manager
%
% Scheduler Functions Specific to Third Party Schedulers
%   distcomp.lsfscheduler/getDebugLog     - Read output messages from job or tasks (for LSF, CCS and mpiexec)
%
% Job Manager Properties
%   BusyWorkers                           - Workers currently running tasks
%   Configuration                         - Specify configuration to apply to object or toolbox function
%   HostAddress                           - IP address of host machine running job manager
%   HostName                              - Name of host machine running job manager
%   IdleWorkers                           - Workers currently idle and available to run tasks
%   Jobs                                  - Jobs contained in job manager service
%   Name                                  - Name of job manager
%   NumberOfBusyWorkers                   - Number of workers currently running tasks
%   NumberOfIdleWorkers                   - Number of workers available to run tasks
%   State                                 - Current state of job manager
%
% Scheduler Properties
%   ClusterMatlabRoot                     - Specify MATLAB root for cluster
%   ClusterName                           - Name of LSF cluster
%   ClusterOsType                         - Specify operating system of cluster computers
%   Configuration                         - Specify configuration to apply to object or toolbox function
%   DataLocation                          - Specify directory where job data is stored
%   EnvironmentSetMethod                  - Specify means of setting environment variables for mpiexec scheduler
%   HasSharedFilesystem                   - Specify whether nodes share DataLocation
%   Jobs                                  - Jobs contained in scheduler's DataLocation
%   MasterName                            - Name of LSF master node
%   MatlabCommandToRun                    - MATLAB command that generic scheduler runs to start lab
%   MpiexecFileName                       - Specify pathname of executable mpiexec command
%   ParallelSubmissionWrapperScript       - Specify function to run when parallel job submitted to scheduler
%   SchedulerHostname                     - Hostname of computer running CCS scheduler
%   SubmitArguments                       - Specify additional arguments to use when submitting job to scheduler
%   SubmitFcn                             - Specify function to run when job submitted to generic scheduler
%   Type                                  - Type of object
%
% Job Functions
%   distcomp.job/cancel                   - Cancel a pending, queued, or running job
%   distcomp.job/createTask               - Create new task in job
%   distcomp.job/destroy                  - Remove job object from a job manager and memory
%   distcomp.job/findTask                 - Get task objects belonging to job object
%   distcomp.job/getAllOutputArguments    - Retrieve output arguments from all tasks evaluated in job object
%   distcomp.job/submit                   - Queue job in job queue service
%   distcomp.job/waitForState             - Wait for job object to change state
%
% Job Properties
%   CreateTime                            - When job was created
%   Configuration                         - Specify configuration to apply to object or toolbox function
%   FileDependencies                      - Directories and files that worker can access
%   FinishedFcn                           - Specify callback to execute when job finishes running
%   FinishTime                            - When job finished
%   ID                                    - Object identifier
%   JobData                               - Data made available to all workers for job's tasks
%   MaximumNumberOfWorkers                - Specify maximum number of workers to perform tasks of a job
%   MinimumNumberOfWorkers                - Specify minimum number of workers to perform tasks of a job
%   Name                                  - Specify name for job object
%   Parent                                - Parent scheduler object of job
%   PathDependencies                      - Specify directories to add to MATLAB worker path
%   QueuedFcn                             - Specify function to execute when job is added to queue
%   RestartWorker                         - Specify whether to restart MATLAB on worker before it evaluates task
%   RunningFcn                            - Specify function to execute when job or task starts running
%   StartTime                             - When job started running
%   State                                 - Current state of job object
%   SubmitTime                            - When job was submitted to job queue
%   Tag                                   - Specify label to associate with job object
%   Tasks                                 - Tasks contained in job object
%   Timeout                               - Specify time limit for completion of job
%   UserData                              - Specify data to associate with job object
%   UserName                              - User who created job
%
% Task Functions
%   distcomp.task/cancel                  - Cancel a pending or running task
%   distcomp.task/destroy                 - Remove task object from job and from memory
%   distcomp.task/waitForState            - Wait for task object to change state
%
% Task Properties
%   CaptureCommandWindowOutput            - Specify whether to return command window output
%   CommandWindowOutput                   - Text produced by execution of task object's function
%   Configuration                         - Specify configuration to apply to object or toolbox function
%   CreateTime                            - When task was created
%   ErrorIdentifier                       - Task error identifier
%   ErrorMessage                          - Output message from task error
%   FinishedFcn                           - Specify callback to execute when task finishes running
%   FinishTime                            - When task finished
%   Function                              - Function called when evaluating task
%   ID                                    - Object identifier
%   InputArguments                        - Input arguments to task object
%   NumberOfOutputArguments               - Number of arguments returned by task function
%   OutputArguments                       - Data returned from the execution of task
%   Parent                                - Parent job object of task
%   RunningFcn                            - Specify function to execute when job or task starts running
%   State                                 - Current state of task object
%   StartTime                             - When task started running
%   Timeout                               - Specify time limit for completion of task
%   UserData                              - Specify data to associate with task object
%   Worker                                - Worker session that performed task
%
% Worker Properties
%   CurrentJob                            - Job whose task the worker is currently running
%   CurrentTask                           - Task that worker is currently running
%   HostAddress                           - IP address of host machine running worker session
%   HostName                              - Name of host machine running worker session
%   Name                                  - Name of worker object
%   PreviousJob                           - Job whose task the worker previously ran
%   PreviousTask                          - Task that worker previously ran
%
% Toolbox Functions Used in MATLAB Workers
%   getCurrentJob                         - Get job object whose task is currently being evaluated
%   getCurrentJobmanager                  - Get job manager object that sent current task
%   getCurrentTask                        - Get task object currently being evaluated
%   getCurrentWorker                      - Get worker object currently running
%
% See also DISTCOMP/PARALLEL.

% Copyright 2004-2010 The MathWorks, Inc.
% Generated from Contents.m_template revision 1.1.8.6  $Date: 2010/03/22 03:41:39 $
