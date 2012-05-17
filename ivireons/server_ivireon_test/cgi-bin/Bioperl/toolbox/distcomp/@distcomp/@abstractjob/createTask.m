function tasks = createTask(job, varargin)
; %#ok Undocumented

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/05/05 21:35:33 $ 

try
    [taskFcns, numArgsOut, argsIn, setArgs] = distcomp.pCreateTaskArgumentCheck(job, varargin{:});
catch err
    throw(err);
end

try
    tasks = job.pCreateTask(taskFcns, numArgsOut, argsIn);
catch err
    % TODO - what sort of error here?
    rethrow(err)
end

try
    % If we have any extra parameters then set them here
    if numel(setArgs) > 0
        % Catch the invalid input of a single char array as it would cause
        % set to return the possible values of the input
        if numel(setArgs) == 1 && ischar(setArgs{1})
            error('distcomp:job:InvalidArgument', '??? Invalid parameter/value pair arguments.');
        end
        set(tasks, setArgs{:});
    end
catch err
    % Invalid parameter or value
    destroy(tasks);
    rethrow(err);
end

