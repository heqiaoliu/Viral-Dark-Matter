function tasks = createTask(job, varargin)
%createTask  Create a new task in a job
%
%    t = createTask(j, F, N, {x1,..., xn}) creates a new task object in job j,
%    and returns a reference, t, to the added task object. This task evaluates
%    the function specified by a function handle or function name, F, with the
%    given arguments, x1,...,xn, returning N output arguments.
%
%    t = createTask(j, F, N, {C1,...,Cm}) uses a cell array of m cell arrays 
%    to create m task objects in job j, and returns a vector of references, t,
%    to the new task objects.  Each task evaluates the function specified by a
%    function handle or function name F.  The cell array C1 provides the input 
%    arguments to the first task, C2 to the second task, and so on, so that
%    there is one task per cell array.  Each task returns N output arguments.  
%    If F is a cell array, each element of F specifies a function for each 
%    task in the vector; it must have m elements.  If N is an array of doubles,
%    each element specifies the number of output arguments for each task in the
%    vector.  Multidimensional matrices of inputs F, N and {C1,...,Cm}  are 
%    supported; if a cell array is used for F, or a double array for N, its 
%    dimensions must match those of the input arguments cell array of cell 
%    arrays. The output t will be a vector with the same number of elements as
%    {C1,...,Cm}.
%    
%    t = createTask(..., 'p1',v1,'p2',v2, ...) creates a task object with the
%    specified property values. If an invalid property name or property value
%    is specified, the object will not be created and an error will be thrown.
%    
%    t = createTask(..., 'configuration', 'ConfigurationName', ...)
%    creates a task job object with the property values specified in the
%    configuration ConfigurationName. 
%
%    Examples:
%    Create and submit two jobs.  The first job has a task that generates a
%    10-by-10 random matrix, the second has a task to execute the function 
%    [y1, y2, y3] = foo(6.98, 7.65) on a worker and return the three output 
%    arguments in the task property OutputArguments.
%    % Create the first job object.
%    jm = findResource('scheduler', 'type', 'jobmanager', ...
%                      'LookupURL', 'JobMgrHost');
%    j = createJob(jm);
%    % Add a task object that generates a 10-by-10 random matrix.
%    t = createTask(j, @rand, 1, {10,10});
%    % Run the job.
%    submit(j);
%    % Get the output from the task evaluation.
%    taskoutput = get(t, 'OutputArguments');
%    % Show the 10-by-10 random matrix.
%    disp(taskoutput{1});
%    % Destroy the job object.
%    destroy(j).
%    % Create the second job and its task.
%    j = createJob(jm);
%    createTask(j, @foo, 3, {6.98, 7.65})
%    submit(j);
%    
%    Create a job with 3 tasks, each of which creates a 10-by-10 random 
%    matrix.
%    jm = findResource('scheduler', 'type', 'jobmanager', ...
%                        'LookupURL', 'JobMgrHost');
%    j = createJob(jm);
%    t = createTask(j, @rand, 1, {{10,10} {10,10} {10,10}});
% 
%    See also distcomp.jobmanager/createJob, distcomp.job/findTask

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.8 $    $Date: 2008/05/05 21:36:11 $ 

try
    [taskFcns, numArgsOut, argsIn, setArgs] = distcomp.pCreateTaskArgumentCheck(job, varargin{:});
catch err
    throw(err);
end


try
    % Defer to the internal pCreateTask method that might be overloaded
    tasks = pCreateTask(job, taskFcns, numArgsOut, argsIn, setArgs{:});
catch err
    rethrow(err);
end
