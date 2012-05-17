function createSubmitScript(outputFilename, jobName, quotedLogFile, quotedScriptName, ...
    environmentVariables, additionalSubmitArgs)
% Create a script that sets the correct environment variables and then 
% executes the LSF bsub command.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2010/03/22 03:43:27 $

% Open file in binary mode to make it cross-platform.
fid = fopen(outputFilename, 'w');
if fid < 0
    error('distcompexamples:LSF:FileError', ... 
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

commandToRun = getSubmitString(jobName, quotedLogFile, quotedScriptName, ...
    additionalSubmitArgs);   
fprintf(fid, '%s\n', commandToRun);

% Close the file
fclose(fid);

