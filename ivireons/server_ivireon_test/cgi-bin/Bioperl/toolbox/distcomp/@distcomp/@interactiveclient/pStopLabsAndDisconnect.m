function pStopLabsAndDisconnect(obj, closeGUI)
; %#ok Undocumented.
%stopLabsAndDisconnect Stop all the labs and perform client cleanup
%  Send the stop signal to all the labs so they exit and the parallel job 
%  finishes.  Clean up sockets and streams.  Closes the GUI unless closeGUI 
%  is false.

%   Copyright 2006-2009 The MathWorks, Inc.


% This method does not throw any errors.  

if (nargin < 2)
    closeGUI = true;
end

constants = distcomp.getInteractiveConstants();
timeToWait = constants.clientTimeBetweenStopAndDestroyJob;

canLabsStop = false;
if ~isempty(com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession)
    % Rely on this method not throwing any errors.  The disp statement at the end 
    % will therefore always print the newline matching this fprintf statement.
    fprintf('Sending a stop signal to all the labs ... ');
    canLabsStop = com.mathworks.toolbox.distcomp.pmode.SessionFactory.destroyClientSession;
end

try
    % Disable the command input window.
    com.mathworks.toolbox.distcomp.parallelui.ParallelUI.suspend();
catch err
    dctSchedulerMessage(1, ['Failed to disable the GUI due to the following ', ...
                        'error:\n%s'], err.message);
end    

if ~isempty(obj.ParallelJob)
    if canLabsStop
        % Give the labs a few seconds to finish their labBarrier and exit before
        % destroying the job.
        try
            obj.ParallelJob.waitForState('finished', timeToWait);
        catch err
            dctSchedulerMessage(2, ['Failed to wait for job to finish due to the ', ...
                                'following error:\n%s'], err.message);
        end
    end

    try
        [~, undoc] = pctconfig();
        if ~undoc.preservejobs
            obj.ParallelJob.destroy;
        end
    catch err
        dctSchedulerMessage(2, ['Failed to destroy the job due to the ', ...
                            'following error:\n%s'], err.message);
    end
end
% We have finished with this parallel job - so forget about it
obj.ParallelJob = [];

if ~isempty(obj.ConnectionManager)
    try
        obj.ConnectionManager.close;
    catch err
        dctSchedulerMessage(2, ['Failed to close the server socket due to the ', ...
                            'following error:\n%s'], err.message);
    end
end
% Finished with the ConnectionManager - forget about it
obj.ConnectionManager = [];

if closeGUI && obj.IsGUIOpen
    try
        com.mathworks.toolbox.distcomp.parallelui.ParallelUI.stop();
    catch err
        dctSchedulerMessage(1, ['Failed to stop the GUI due to the ', ...
                            'following error:\n%s'], err.message);        
    end    
    obj.IsGUIOpen = false;
end
% Finally set the current interactive type to 'none' to 
% indicate that no-one is using the current client
obj.CurrentInteractiveType = 'none';

% This disp statement adds a newline that complement messages printed above.
disp('stopped.');
