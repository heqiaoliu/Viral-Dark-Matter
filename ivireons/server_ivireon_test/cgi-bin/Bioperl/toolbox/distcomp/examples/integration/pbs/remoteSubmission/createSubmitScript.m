function createSubmitScript(outputFilename, jobName, quotedLogFile, quotedScriptName, ...
    environmentVariables, additionalSubmitArgs)
% Create a script that sets the correct environment variables and then 
% executes the PBS qsub command.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2010/03/22 03:43:27 $

% Open file in binary mode to make it cross-platform.
fid = fopen(outputFilename, 'w');
if fid < 0
    error('distcompexamples:PBS:FileError', ... 
        'Failed to open file %s for writing', filename);
end

% Specify Shell to use
fprintf(fid, '#!/bin/sh\n');

% Write the commands to set and export environment variables
for ii = 1:size(environmentVariables, 1)
    fprintf(fid, '%s=%s\n', environmentVariables{ii,1}, environmentVariables{ii,2});
    fprintf(fid, 'export %s\n', environmentVariables{ii,1});
end

% Generate the command to run and write it.
% We will forward all environment variables with this job in the call
% to qsub
variablesToForward = environmentVariables(:,1);
commandToRun = getSubmitString(jobName, quotedLogFile, quotedScriptName, ...
    variablesToForward, additionalSubmitArgs);   
fprintf(fid, '%s\n', commandToRun);

% Close the file
fclose(fid);

