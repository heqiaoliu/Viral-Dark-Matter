function runprop = decodeMpiexecSingleTask( runprop )

% Copyright 2005-2009 The MathWorks, Inc.

storageConstructor = iDequote( getenv('MDCE_STORAGE_CONSTRUCTOR') );
storageLocation    = iDequote( getenv('MDCE_STORAGE_LOCATION') );
jobLocation        = iDequote( getenv('MDCE_JOB_LOCATION') );
taskLocation       = [jobLocation filesep 'Task' num2str( labindex ) ];

% Need to tell the job runner where it's dependency directory is
dependencyDir = [tempname '.' num2str( labindex ) '.mdce.temp' ];

set(runprop, ...
    'StorageConstructor', storageConstructor, ...
    'StorageLocation', storageLocation, ...
    'JobLocation', jobLocation, ....
    'TaskLocation', taskLocation, ...
    'DependencyDirectory', dependencyDir);

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
