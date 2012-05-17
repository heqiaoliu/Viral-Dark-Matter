function str = pctdemo_helper_getUniqueErrors(job)
%PCTDEMO_HELPER_GETUNIQUEERRORS Get task error messages from a job object.
%   allErrors = pctdemo_helper_getUniqueErrors(job) returns a string containing
%   all the unique task error messages from the given job.
%   If all the task error messages and error message identifiers are empty 
%   (i.e., if no task errors occurred), returns the empty array.
    
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:24 $
    
    % Validate the number of input arguments.
    error(nargchk(1, 1, nargin, 'struct'));
    % Check that we have a valid job object.
    tc = pTypeChecker();
    if ~(tc.isJobObject(job) || tc.isParallelJobObject(job))
        error('distcomp:demo:InvalidArgument', ...
              'Input argument must be a single job or parallel job object');
    end

    tasks = job.Tasks;
    if isempty(tasks)
        str = '';
        return;
    end
    % Get the error message and error IDs and store them in cell arrays of 
    % strings. 
    msgs = get(tasks, {'ErrorMessage'});
    ids = get(tasks, {'ErrorIdentifier'}); 

    % Only look at the actual errors.
    nonempty = ~cellfun('isempty', msgs) | ~cellfun('isempty', ids);
    msgs = msgs(nonempty);
    ids = ids(nonempty);
    if isempty(ids)
        % There were no task errors.
        str = '';
        return;
    end

    % Find the unique error ids and messages, and return one message for each of
    % them.  We determine uniqueness based on both the error ID and the error 
    % message.
    combined = strcat(ids, msgs);
    [tmp, ind] = unique(combined); %#ok Tell mlint we don't need the first output arg.
    % Get the unique error messages.
    allErrors = msgs(ind);
    % Add newlines at the end of all but the last error message.
    allErrors(1:end - 1) = strcat(allErrors(1:end - 1), {sprintf('\n\n')});
    % Concatenate all the error messages into one long string.
    str = [allErrors{:}]; 
end % End of pctdemo_helper_getUniqueErrors.
