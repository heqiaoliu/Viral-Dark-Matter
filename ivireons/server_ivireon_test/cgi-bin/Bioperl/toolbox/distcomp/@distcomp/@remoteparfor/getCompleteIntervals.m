function [tags,  results] = getCompleteIntervals(obj, numIntervals)
; %#ok Undocumented

%   Copyright 2007-2008 The MathWorks, Inc.

%   $Revision: 1.1.6.4 $  $Date: 2008/06/24 17:01:52 $

q = obj.IntervalCompleteQueue;
% Function to display the Strings in a Java String array.
dispStringArray = @(msgs) cellfun(@(msg) disp(char(msg)), cell(msgs));
output = obj.ParforController.getDrainableOutput;

tags = ones(numIntervals, 1);
results = cell(numIntervals, 1);
for i = 1:numIntervals
    r = [];
    while isempty(r)
        r = q.poll(1, java.util.concurrent.TimeUnit.SECONDS);
        dispStringArray(output.drainOutput());
        % Only test to see if the session is failing if we didn't get a
        % results from the queue
        if isempty(r) && ~obj.session.isSessionRunning
            error('distcomp:remoteparfor:SessionNotRunning', 'The session that parfor is using has shut down');
        end
    end
    % Check to see if the interval result has an error
    if r.hasError
        % Java code has already interrupted the remote execution of the parfor 
        % body and halted the receipt of further IO.  Before throwing an error,
        % we perform the normal cleanup activities.
        obj.complete();
        intervalError = r.getError;
        if ischar(intervalError) 
            error('distcomp:remoteparfor:UnexpectedError', intervalError);
        else
            origErr = distcompdeserialize(distcompByteBuffer2MxArray(intervalError.get));
            intervalError.free;

            % Do the re-writing that used to happen here to get better diagnostics
            if ~isempty( origErr.stack )
                
                % Build the an "Error in ==>" piece
                frame = origErr.stack(1);
                [junk, displayFile] = fileparts( frame.file );
                
                % Choose how to display the function
                if ~strcmp( displayFile, frame.name )
                    displayItem = sprintf( '%s>%s', displayFile, frame.name );
                else
                    displayItem = displayFile;
                end
                
                % Throw an MException - this automatically handles the case where
                % origErr.identifier is empty.
                throw( MException( origErr.identifier, 'Error in ==> %s at %d\n%s', ...
                                   displayItem, frame.line, origErr.message ) );
            else
                throw( origErr );
            end
        end
    else
        tags(i) = r.getTag;
        data = r.getResult;
        results{i} = distcompdeserialize(distcompByteBuffer2MxArray(data(2).get));
        data(2).free;
    end
end
