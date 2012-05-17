function job = generalCreateJob(jobConstructorMethod, argsin)
%generalCreateJob  Create job object using the specified constructor
%
%  job = generalCreateJob(constructorFcn, jobVarargin)
%
% This function will check the jobArargin for the existence of a 
% configuration property. If set it will be used, else the default
% parallel configuration will be used. A scheduler will be found from
% whatever configuration is supplied and then the requested
% job construction method will be called on that scheduler.

%  Copyright 2007-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $    $Date: 2010/02/25 08:02:19 $ 


% Need to parse the inputs to find if we have been sent a configuration
[allProps, allValues] = parallel.internal.convertToPVArrays(argsin{:});
% Get the last configuration specified 
ind = find(strcmpi(allProps, 'Configuration'), 1, 'last');
% Didn't find a configuration then use the default
if isempty(ind)
    configuration = defaultParallelConfig;
    % We will ALWAYS specify a configuration to create the job - this behaviour will 
    % be slightly different to the object method createJob, but reflects the slightly
    % higher level that this function represents. Note also that configuration is the
    % first parameter so that all specified args in override the configuration.
    argsin = [{'Configuration' configuration} argsin];
else
    configuration = allValues{ind};
end
% Get the scheduler to use
scheduler = distcomp.pGetScheduler(configuration);
% Now call the correct method on the scheduler
job = jobConstructorMethod(scheduler, argsin{:});
