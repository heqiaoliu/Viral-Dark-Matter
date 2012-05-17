function pSubmitJob( pbs, job )
; %#ok Undocumented

%pSubmitJob - submit a job to PBS. Handles all variants of jobarray/multiple
%jobs and shared/nonshared filesystems

% Copyright 2007-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $   $Date: 2010/03/22 03:41:56 $

tasks = job.Tasks;

% Check properties, and return the script extension on the cluster
clusterScriptExt = pPreSubmissionChecks( pbs, job, tasks );

% Ensure that the job has been prepared
job.pPrepareJobForSubmission;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generic things to do with setting up environment variables

storage = job.pReturnStorage;
% Ask the storage object how it would like to serialize itself and be
% reconstructed at the far end
[stringLocation, stringConstructor] = storage.getSubmissionStrings;
setenv('MDCE_STORAGE_LOCATION', stringLocation);
setenv('MDCE_STORAGE_CONSTRUCTOR', stringConstructor);

% Get the location of the storage
jobLocation = job.pGetEntityLocation;
setenv('MDCE_JOB_LOCATION', jobLocation);

[~, matlabExe, matlabArgs] = pbs.pCalculateMatlabCommandForJob( job );
setenv( 'MDCE_MATLAB_EXE', matlabExe );
if ispc && isempty( matlabArgs )
    % Work around problem whereby an empty setting for this causes PBS to think
    % that it cannot send the environment
    matlabArgs = ' ';
end
setenv( 'MDCE_MATLAB_ARGS', matlabArgs );

if pbs.HasSharedFilesystem
    setenv('MDCE_DECODE_FUNCTION', 'decodePbsSingleTask');
else
    setenv('MDCE_DECODE_FUNCTION', 'decodePbsSingleZippedTask');
end

% Store the scheduler type so the runprop on the far end can be correctly
% constructed. Ensure it's lower case for distcomp.getSchedulerUDDConstructor.
setenv( 'MDCE_SCHED_TYPE', lower( pbs.Type ) );

% Only use job arrays if there's more than one task. PBSPro cannot submit a
% single-element job array.
actuallyUseJobArrays = pbs.UseJobArrays && numel( tasks ) > 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Everything to do with setting up complex replacements for the templates
% and the other command-line arguments.

headerEls = iCalcHeaderElements( pbs, job, actuallyUseJobArrays );

% Define the location for logs to be returned
[logArgs, relLog, absLog] = pbs.pChooseLogLocation( storage, job );

cmdLineArgs = [ pbs.SubmitArguments, ' ', logArgs ];
if strcmp( pbs.ClusterOsType, 'pc' )
    directive   = 'REM PBS ';
    % PC doesn't automatically understand "REM PBS" for PBS directives. "-C
    % #PBS" is implied.
    cmdLineArgs = [ cmdLineArgs, ' -C "REM PBS"'];
else
    directive   = '#PBS ';
end

% We always need to know the skipIDs even in non-jobarray mode, as this is
% also how we go from PBS identifier to Task. skipString is needed by the
% templates.
[skipString, skipIDs] = iCalcSkipString( get( job.Tasks, {'ID'} ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build the submission script from template elements
submissionScript = pbs.pJobSpecificFile( job, sprintf( 'Job%d_script%s', ...
                                                  job.ID, clusterScriptExt ), true );
fhSubScript = fopen( submissionScript, 'wt' );
if fhSubScript == -1
    error( 'distcomp:pbsscheduler:cantwritescript', ...
           'Couldn''t write the submission script "%s"',submissionScript );
end

try
    iAddHeader( pbs, job, fhSubScript, clusterScriptExt, headerEls, directive );

    if actuallyUseJobArrays
        iAddJobArrayPrologue( pbs, job, fhSubScript, clusterScriptExt, skipString );
        submissionFcn = @iSubmitJobArray;
    else
        submissionFcn = @iSubmitJobs;
    end

    if ~pbs.HasSharedFilesystem
        iAddCopyIn( pbs, job, fhSubScript, clusterScriptExt );
    end
    
    iAddExecution( pbs, job, fhSubScript, clusterScriptExt );

    if ~pbs.HasSharedFilesystem
        iAddCopyOut( pbs, job, fhSubScript, clusterScriptExt );
    end

    % Ensure script has a trailing newline
    fprintf( fhSubScript, '\n' );

    err = [];
catch exception
    err = exception;
end

fclose( fhSubScript );

if ~isempty( err )
    rethrow( err );
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Actual submission

% Before submitting we need to ensure that certain environment variables
% are no longer set otherwise PBS will copy them across and break the
% remote MATLAB startup - these are used by MATLAB startup to pick the
% matlabroot and toolbox path and they explicitly override any local
% settings.
storedEnv = distcomp.pClearEnvironmentBeforeSubmission();

if ~pbs.HasSharedFilesystem
    storage = pbs.pReturnStorage;
    storage.serializeForSubmission( job );
end

try
    % Make the shelled out call to qsub
    
    [FAILED, out, jobIDs] = submissionFcn( pbs, job, submissionScript, cmdLineArgs );
catch err
    FAILED = true;
    out = err.message;
end

distcomp.pRestoreEnvironmentAfterSubmission( storedEnv );

if FAILED
    error('distcomp:pbsscheduler:UnableToFindService', ...
          'Error executing the PBS script command ''qsub''. The reason given is \n %s', out);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build the scheduler data
schedulerData = struct( 'type', 'pbs', ...
                        'usingJobArray', actuallyUseJobArrays, ...
                        'pbsJobIds', {jobIDs}, ...
                        'skippedTaskIDs', skipIDs, ...
                        'absLogLocation', absLog, ...
                        'relLogLocation', relLog );

job.pSetJobSchedulerData( schedulerData );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Release the hold on the jobs
for ii = 1:length( jobIDs )
    [FAILED, out] = pbs.pPbsSystem( sprintf( 'qalter -h n "%s"', jobIDs{ii} ) );
end

if FAILED
    error('distcomp:pbsscheduler:UnableToFindService', ...
        'Error executing the PBS script command ''qalter''. The reason given is \n %s', out);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FAILED, out, jobIDs] = iSubmitJobArray( pbs, job, scriptName, cmdLineArgs )
% Define the function that will be used to decode the environment variables
setenv( 'MDCE_TASK_ID', '0' ); % Dummy value required for "-v"

pbsJobName = pbs.pChoosePBSJobName( sprintf( 'Job%d', job.ID ) );
submitString = sprintf( 'qsub %s -N %s "%s"', ...
                        cmdLineArgs, pbsJobName, scriptName );

pbs.pAppendSubmitString( scriptName, submitString );

[FAILED, out] = pbs.pPbsSystem( submitString );

if ~FAILED
    jobIDs = { pbs.pExtractJobId( out ) };
else
    jobIDs = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FAILED, out, jobIDs] = iSubmitJobs( pbs, job, scriptName, cmdLineArgs )
% Define the function that will be used to decode the environment variables

jobIDs = cell( 1, numel( job.Tasks ) );

for ii = 1:numel( job.Tasks )

    setenv( 'MDCE_TASK_ID', num2str( job.Tasks(ii).ID ) );

    % Log location will contain ^array_index^ which we must manually change
    thisCmdLineArgs = strrep( cmdLineArgs, '^array_index^', num2str( ii ) );
    
    pbsJobName = pbs.pChoosePBSJobName( sprintf( 'Job%dTask%d', job.ID, job.Tasks(ii).ID ) );
    submitString = sprintf( 'qsub %s -N %s "%s"', ...
                            thisCmdLineArgs, pbsJobName, scriptName );
    if ii == 1
        pbs.pAppendSubmitString( scriptName, submitString );
    end
    
    [FAILED, out] = pbs.pPbsSystem( submitString );

    if ~FAILED
        jobIDs{ii} = pbs.pExtractJobId( out );
    else
        jobIDs = [];
        % Return the fail status, the outer layer will deal with this
        return
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iReadTemplate - read a given template
function str = iReadTemplate( pbs, shortName, clusterScriptExt ) %#ok<INUSL>
fname = fullfile( toolboxdir('distcomp'), 'bin', 'util', 'pbs', ...
                  [shortName, clusterScriptExt] );

fh = fopen( fname, 'rt' );

if fh == -1
    error( 'distcomp:pbsscheduler:cantReadTemplate', ...
           'Failed to read from PBS template script "%s"', fname );
end

try
    % Read whole file in one huge slurp
    str = fread( fh, Inf, 'char' );
    % Strip ^M
    str( str == sprintf( '\r' ) ) = [];
    % Convert to a normal string
    str = char( str(:).' );
    err = [];
catch exception
    err = exception;
end

fclose( fh );
if ~isempty( err )
    rethrow( err );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iCalculateRcpPieces - return the slashes to use locally and on the
% cluster, and the rcp prefix
function [rcpPrefix, clusterSlash, taskIdEnv] = iCalculateRcpPieces( pbs )

cfg = pctconfig;
localhost = cfg.hostname;

storage = pbs.pReturnStorage;

if ~isa( storage, 'distcomp.filestorage' )
    % hmm, this isn't a great error message. But it should "never happen"
    error( 'distcomp:pbsscheduler:fileStorageForNonShared', ...
           ['The PBS scheduler must be used with file storage if there ', ...
            'is no shared filesystem'] );
end

clientStorage = pbs.DataLocation;

switch pbs.ClusterOsType
  case 'pc'
    clusterSlash = '\';
    taskIdEnv = '%MDCE_TASK_ID%';
  case 'unix'
    clusterSlash = '/';
    taskIdEnv = '${MDCE_TASK_ID}';
end

rcpPrefix = sprintf( '%s:%s%s', localhost, clientStorage, clusterSlash );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iBuildRcp - build an RCP command
function str = iBuildRcpCommand( pbs, from, to, clusterExt )

tmpl = iReadTemplate( pbs, 'rcp', clusterExt );

tmpl = strrep( tmpl, '<IN>', from );
tmpl = strrep( tmpl, '<OUT>', to );
str  = strrep( tmpl, '<RCP>', pbs.RcpCommand );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iAddCopyIn - copy files into cluster
function iAddCopyIn( pbs, job, fh, clusterExt )

tmpl = iReadTemplate( pbs, 'nonshared-copyin', clusterExt );

[rcp, clusterSlash, taskIdEnv] = iCalculateRcpPieces( pbs );

jobCopy  = iBuildRcpCommand( pbs, sprintf( '%sJob%d.zip', rcp, job.ID ), 'Job.zip', clusterExt );
taskCopy = iBuildRcpCommand( pbs, sprintf( '%sJob%d%sTask%s.zip', rcp, job.ID, filesep, taskIdEnv ), ...
                             sprintf( 'Task.%s.zip', taskIdEnv ), clusterExt );

replacement = sprintf( '%s\n%s\n', jobCopy, taskCopy );

fprintf( fh, '%s\n', strrep( tmpl, '<COPY_FILES>', replacement ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iAddCopyOut - add the rcp lines to copy out files back to client
function iAddCopyOut( pbs, job, fh, clusterExt )

tmpl = iReadTemplate( pbs, 'nonshared-copyout', clusterExt );

[rcp, clusterSlash, taskIdEnv] = iCalculateRcpPieces( pbs );

jobPieces  = { '.common.mat', '.out.mat', '.state.mat' };
taskPieces = { '.common.mat', '.out.mat', '.state.mat' };

strs = {};

for ii = jobPieces
    fname = sprintf( 'Job%d%s', job.ID, ii{1} );
    strs{end+1} = iBuildRcpCommand( pbs, fname, [rcp, fname], clusterExt ); %#ok<AGROW>
end

for ii = taskPieces
    fname = sprintf( 'Job%d%sTask%s%s', ...
                     job.ID, clusterSlash, taskIdEnv, ii{1} );
    strs{end+1} = iBuildRcpCommand( pbs, fname, [rcp fname], clusterExt ); %#ok<AGROW>
end

copy_files = sprintf( '%s\n', strs{:} );

tmpl = strrep( tmpl, '<COPY_FILES>', copy_files );

fprintf( fh, '%s', tmpl );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iAddHeader - add the header elements to the script
% Stuff like:
% "#PBS -h" or "REM PBS -j oe"
function iAddHeader( pbs, job, fh, clusterExt, headerEls, directive ) %#ok<INUSL>

tmpl = iReadTemplate( pbs, 'header', clusterExt );
fmt  = [directive, '%s\n'];
replacement = sprintf( fmt, headerEls{:} );

fprintf( fh, '%s\n', strrep( tmpl, '<HEADERS>', replacement ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iAddJobArrayPrologue - add the loop which remaps task ID from PBS_ARRAY_INDEX
function iAddJobArrayPrologue( pbs, job, fh, clusterExt, skipString ) %#ok<INUSL>
prologue = iReadTemplate( pbs, 'job-array-prologue', clusterExt );
prologue = strrep( prologue, '<SKIP_LIST>', skipString );

fprintf( fh, '%s\n', prologue );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iAddExecution - add the piece which actually runs MATLAB
function iAddExecution( pbs, job, fh, clusterExt ) %#ok<INUSL>

execute = iReadTemplate( pbs, 'execute', clusterExt );
if pbs.UsePbsAttach
    replacement = 'pbs_attach -j ${PBS_JOBID} ';
else
    replacement = '';
end
execute = strrep( execute, '<PBS_ATTACH>', replacement );

fprintf( fh, '%s\n', execute  );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the "skip string". To encode the missing tasks, we build a
% string which will be inserted into the resulting script to map
% PBS_ARRAY_INDEX back to a real task index.
function [skipString, skipIDs] = iCalcSkipString( taskIds )

taskIds = cell2mat( taskIds );

% Given the taskIds, calculate the missing ones
allTasks = 1:max( taskIds );
skipIDs = setdiff( allTasks, taskIds );

% Calculate the array needed by the wrapper scripts - skipByArray - which
% encodes how many missing tasks there are after each given array index
diffTasks = diff( [0; taskIds] ) - 1;
skipByArray = [];
for ii=1:length( diffTasks )
    % Grow the skipByArray array dynamically - we don't expect this to be very
    % large.
    if diffTasks(ii) > 0
        skipByArray = [ skipByArray, repmat( ii, 1, diffTasks(ii) ) ]; %#ok<AGROW>
    end
end

skipString = sprintf( '%d ', skipByArray );
skipString = skipString(1:end-1);

% Assert that we got this (somewhat) tricky stuff right. If we got it wrong,
% then the shell scripts will break. Note that the calculation below is
% mirrored in the job-array-prologue.* scripts.
for ii=1:length( taskIds )
    thisId = ii;
    for jj = skipByArray
        if ii >= jj
            thisId = thisId + 1;
        end
    end
    if thisId ~= taskIds(ii)
        error( 'distcomp:pbsscheduler:skipCalculation', ...
               'An internal error occurred while checking job array missing tasks' );
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iCalcHeaderElements - calculate the header elements needed in the
% submission script.
function headerEls = iCalcHeaderElements( pbs, job, useJA )
headerEls = { '-h', '-j oe' };

if ~isempty( pbs.ResourceTemplate )
    headerEls{end+1} = strrep( pbs.ResourceTemplate, '^N^', '1' );
end

if useJA
    headerEls{end+1} = sprintf( '-J 1-%d', numel( job.Tasks ) );
end
