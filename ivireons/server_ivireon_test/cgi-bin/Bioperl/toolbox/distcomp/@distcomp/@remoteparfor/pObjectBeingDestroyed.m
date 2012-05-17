function pObjectBeingDestroyed(obj, ~)
; %#ok Undocumented

%   Copyright 2007-2009 The MathWorks, Inc.

%   $Revision: 1.1.6.3 $  $Date: 2009/03/05 18:46:35 $

% Interrupt the remote execution and display all the command window output that
% we receive.

% Function to display the Strings in a Java String array.
dispStringArray = @(msgs) cellfun(@(msg) disp(char(msg)), cell(msgs));
output = obj.ParforController.getDrainableOutput;

% Send a Ctrl+C to remote end.
if obj.CaughtError
    obj.ParforController.interruptOnError;
else
    obj.ParforController.interrupt;
end    

% Continue displaying command window output for as long we are waiting for the
% original parfor iterations to complete.
while ~obj.ParforController.awaitCompleted(100, java.util.concurrent.TimeUnit.MILLISECONDS) ...
        &&  obj.session.isSessionRunning
    dispStringArray(output.drainOutput());    
end

% Parfor loop has completed, so display all the remaining lines, including
% partial lines.
dispStringArray(output.drainAllOutput());
