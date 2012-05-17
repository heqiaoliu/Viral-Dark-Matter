function tasks = pCreateTask(job, taskFcn, numArgsOut, argsIn, varargin)
; %#ok Undocumented
%pCreateTask protected create task method

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.13 $    $Date: 2009/02/06 14:16:49 $ 

% Need a dummy Uuid to create the UDD wrapper
persistent UUID;
if isempty(UUID)
    UUID = net.jini.id.UuidFactory.create(0, 0);
end


% Pre-define the tasks array
tasks = handle(-ones(numel(taskFcn), 1));

try 
    for i = 1:numel(tasks)
        % Create the UDD task wrapper with an empty Uuid that we will fill in later.
        tasks(i) = distcomp.createUncachedObjectsFromProxies(UUID, @distcomp.task, 'norootsearch');
    end
catch err
    % Only delete those that we have correctly created
    delete(tasks(ishandle(tasks)));
    throw(distcomp.handleJavaException(job, err));
end
try
    % Need to persist the serialized data until the end of this function
    taskData = cell(numel(tasks), 2);
    for i = 1:numel(tasks)
        taskData{i, 1} = distcompserialize(taskFcn{i});
        taskData{i, 2} = distcompserialize(argsIn{i});
        % Firstly fill in a base taskInfo
        taskInfo = iCreateTaskInfo(taskData{i, 1}, numArgsOut(i), taskData{i, 2});
        % Set the taskInfoTask TaskInfo property so that we can use set on the local machine
        tasks(i).pSetTaskInfo(taskInfo);
    end
    % If we have any extra parameters then set them here
    if numel(varargin) > 0
        % Catch the invalid input of a single char array as it would cause
        % set to return the possible values of the input
        if numel(varargin) == 1 && ischar(varargin{1})
            error('distcomp:job:InvalidArgument', '??? Invalid parameter/value pair arguments.');
        end
        set(tasks, varargin{:});    
    end
    taskInfo = cell(numel(tasks), 1);
    for i = 1:numel(tasks)
        % Get the taskInfo back from the persistent task and use it to create the actual
        % job - remember for memory reasons to not hold a reference to this on the persistent
        % object
        taskInfo{i} = tasks(i).pGetTaskInfo;
    end
    % Need to convert to an array before calling createTask
    taskInfoArray = dctJavaArray(taskInfo);    
    try
        % Need to correctly size the array of job UUID
        jobUUIDs = javaArray('net.jini.id.Uuid', numel(tasks));
        jobUUIDs(:) = job.UUID(1);
        % Create the java task
        proxyTasks = job.ProxyObject.createTask(jobUUIDs, taskInfoArray);
        for i = 1:numel(tasks)
            thisTask = tasks(i);
            % Clear the TaskInfo & cache
            thisTask.pClearTaskInfo;
            % Set my Uuid correctly
            thisTask.remoteobject(proxyTasks(i));
            % Add me to the cache tree - no need to search
            distcomp.cacheObjectsAndProxies(thisTask, proxyTasks(i), job, 'norootsearch');
            % And remember to carry out any post-construction task like attaching
            % the callback eventing correctly
            thisTask.pFinalizeConstruction
        end
    catch err 
        try
            % Lets attempt to clean up the tasks we've just created -
            % somehow. First get the TaskAccessProxy, then try and delete
            % the proxyTasks that we created.            
            job.Parent.pGetTaskAccessProxy.destroy(proxyTasks);
        catch
            % It was only an attempt to clean up - if it fails we still
            % want to do the standard error catching - so do nothing here
        end
        % Bubble error up to next catch
        rethrow(err);
    end
catch err
    delete(tasks);
    throw(distcomp.handleJavaException(job, err));
end

% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function taskInfo = iCreateTaskInfo(funcData, numArgsOut, inData)
import com.mathworks.toolbox.distcomp.workunit.TaskInfo;
import com.mathworks.toolbox.distcomp.util.ByteBufferItem;

timeout = intmax('int64');
cap = false;
maximumNumberOfRetries = 1;
logLevel = 0;

% Convert the inData and funcData to ByteBufferItem to pick up large input
% problems
inData   = ByteBufferItem(distcompMxArray2ByteBuffer(inData));
funcData = ByteBufferItem(distcompMxArray2ByteBuffer(funcData));

taskInfo = TaskInfo(timeout, cap, maximumNumberOfRetries, numArgsOut, ...
                    inData, funcData, logLevel, []);

