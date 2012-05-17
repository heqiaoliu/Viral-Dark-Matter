function execute_in_java_thread( command )
%  Sneaky utility that takes advantage of Java Threads to run a 
%  MATLAB command in the background

%
%	J. Breslau
%   Copyright 1995-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $  $Date: 2007/09/21 19:16:30 $

if ischar(command) 
    command = {command};
end

if ~iscell(command) 
    error('Stateflow:UnexpectedError',['Command to execute must be a string: ' command]);
end

for i = 1:length(command)
    if ~ischar(command{i})
        error('Stateflow:UnexpectedError',['Command to execute must be a string: ' command{i}]);
    end
end

com.mathworks.toolbox.stateflow.util.ExecuteThread.execThread(command);
