function pSubmitResult(task, output, m_exception, cmd_window_output)
; %#ok Undocumented
%pSubmitResult Submit result to jobmanager.
%
%  pSubmitResult(TASK, OUTPUT, MEXCEPTION, CMDWINOUTPUT)

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.9 $    $Date: 2008/10/02 18:40:52 $ 

% Get information about the current worker that is needed to submit 
% a result to the jobmanager.
root = distcomp.getdistcompobjectroot;
worker = root.CurrentWorker;
workerArray = dctJavaArray(worker.pReturnProxyObject, ...
    'com.mathworks.toolbox.distcomp.worker.Worker');

% Do not submit a result if the task has already been cancelled.
if ~worker.pOkayToSubmitResult
    return;
end
worker.pNotifyFunctionEvaluationComplete();

try
    % Submit the task result. The job manager can send a new task to the worker as soon as this call returns successfully.
    iSubmitResult(task, output, m_exception, cmd_window_output, workerArray);
catch err
    % Behave differently depending on the actual error thrown
    switch err.identifier
        case 'distcomp:task:TooMuchData'   
            % Send an empty result with an error message to indicate that the output data 
            % cannot be transferred to the job manager.
            output = [];
            iSubmitResult(task, output, err, cmd_window_output, workerArray);
        case 'distcomp:task:NotFound'
            % No action should be taken.
            % It is possible that the task has been cancelled or destroyed whilst the 
            % worker was working on it. This worker will become idle and work on the 
            % next task sent to it by the job manager.
        otherwise
            % This is a case that shouldn't be hit in practice. Try to submit an empty result. 
            % If it fails, just error out instead of retrying the submit result.
            output = [];
            newErr = MException('distcomp:task:UnableToSubmitResult', ...
                'Unable to return results to jobmanager. The reason is :\n%s', err.message);
            newErr.addCause(err);
            iSubmitResultNoRetry(task, output, newErr, cmd_window_output, workerArray);
    end
end


%--------------------------------------------------------------------------
% Internal function to submit the result of a task
%--------------------------------------------------------------------------
function iSubmitResult(task, output, exception, cmd_window_output, workerArray)
% Remember to call the special ByteBufferItem constructor that checks the
% size of the input and throws an appropriate error if it can get the
% results into the JVM
results = distcompserialize(output);
cmdWinOutBytes = distcompserialize(cmd_window_output);
% Put the data into a ByteBufferItem[] to pass to the proxy
import com.mathworks.toolbox.distcomp.util.ByteBufferItem;
outputItemArray = dctJavaArray(ByteBufferItem(distcompMxArray2ByteBuffer(results)), ...
                               'com.mathworks.toolbox.distcomp.util.LargeDataItem');
cmdWinOutItemArray = dctJavaArray(ByteBufferItem(distcompMxArray2ByteBuffer(cmdWinOutBytes)), ...
                               'com.mathworks.toolbox.distcomp.util.LargeDataItem');
% Get the error identifier and message
error_id = exception.identifier;
error_message = exception.message;
% Serialize the error struct
errorBytes = distcompserialize(exception);

% Loop until either the result is submitted or we detect that it is not possible to submit it.
while true
    proxyTask = task.ProxyObject;
    try
        proxyTask.submitResult(task.UUID, ...
                               outputItemArray, errorBytes, error_message, error_id, ...
                               cmdWinOutItemArray, workerArray);
        % Break out of the loop if the result was submitted successfully.
        break;
    catch err
        % Try to see what went wrong and obtain the error struct.
        err = distcomp.handleJavaException(task, err);
        if strcmp(err.identifier, 'distcomp:jobmanager:Unavailable')
            % The worker should wait until the job manager becomes available.
            task.pGetManager.pWaitForJobManager();
        else
            % The job manager is reachable but we cannot submit the result.
            throw(err);
        end
    end
end


%--------------------------------------------------------------------------
% Internal function to submit an empty result after a failure
%--------------------------------------------------------------------------
function iSubmitResultNoRetry(task, output, exception, cmd_window_output, workerArray)
% Remember to call the special ByteBufferItem constructor that checks the
% size of the input and throws an appropriate error if it can get the
% results into the JVM
results = distcompserialize(output);
cmdWinOutBytes = distcompserialize(cmd_window_output);
% Put the data into a ByteBufferItem[] to pass to the proxy
import com.mathworks.toolbox.distcomp.util.ByteBufferItem;
outputItemArray = dctJavaArray(ByteBufferItem(distcompMxArray2ByteBuffer(results)), ...
                               'com.mathworks.toolbox.distcomp.util.LargeDataItem');
cmdWinOutItemArray = dctJavaArray(ByteBufferItem(distcompMxArray2ByteBuffer(cmdWinOutBytes)), ...
                               'com.mathworks.toolbox.distcomp.util.LargeDataItem');
% Get the error identifier and message
error_id = exception.identifier;
error_message = exception.message;
% Serialize the error struct
errorBytes = distcompserialize(exception);

% Submit the result
proxyTask = task.ProxyObject;
proxyTask.submitResult(task.UUID, ...
                       outputItemArray, errorBytes, error_message, error_id, ...
                       cmdWinOutItemArray, workerArray);

