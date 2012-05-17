function decodePbsSimpleParallelTask( runprop )

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/10/12 17:28:48 $

TASK_ID = num2str(labindex);

storageConstructor = iDequote( getenv('MDCE_STORAGE_CONSTRUCTOR') );
storageLocation    = iDequote( getenv('MDCE_STORAGE_LOCATION') );
jobLocation        = iDequote( getenv('MDCE_JOB_LOCATION') );
schedType          = iDequote( getenv('MDCE_SCHED_TYPE') );
taskLocation       = [jobLocation filesep 'Task' TASK_ID ];

set(runprop, ...
    'StorageConstructor', storageConstructor, ...
    'StorageLocation', storageLocation, ...
    'JobLocation', jobLocation, ....
    'TaskLocation', taskLocation, ...
    'LocalSchedulerName', schedType);


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
