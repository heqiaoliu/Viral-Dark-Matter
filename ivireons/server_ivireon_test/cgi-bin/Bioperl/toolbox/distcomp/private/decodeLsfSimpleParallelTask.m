function decodeLsfSimpleParallelTask( runprop )

% Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $   $Date: 2010/03/22 03:42:47 $

JOB_ID  = getenv('LSB_JOBID');
TASK_ID = num2str(labindex);
% Get a function handle to set status messages for lsf on this particular
% task - this will set the default message handler to be lsfSet
if ~isempty(getenv('MDCE_DEBUG'))
    setSchedulerMessageHandler(lsfMessageHandler(JOB_ID, []));
end
dctSchedulerMessage(2, 'In decodeLsfSimpleParallelTask with JOB_ID : %s and labindex : %d', JOB_ID, labindex);

storageConstructor = iDequote( getenv('MDCE_STORAGE_CONSTRUCTOR') );
storageLocation    = iDequote( getenv('MDCE_STORAGE_LOCATION') );
jobLocation        = iDequote( getenv('MDCE_JOB_LOCATION') );
taskLocation       = [jobLocation filesep 'Task' TASK_ID ];

set(runprop, ...
    'StorageConstructor', storageConstructor, ...
    'StorageLocation', storageLocation, ...
    'JobLocation', jobLocation, ....
    'TaskLocation', taskLocation, ...
    'LocalSchedulerName', 'lsf');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iDequote - remove leading / trailing quotes
function str = iDequote( str )

if ~isempty( str )
    if str(1) == '''' || str(1) == '"'
        str = str(2:end);
    end
    if str(end) == '''' || str(end) == '"'
        str = str(1:end-1);
    end
end
