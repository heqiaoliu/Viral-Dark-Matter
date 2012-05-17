function sOut = mpiprofile(varargin)
% MPIPROFILE Profile parallel communication and execution times.
%   MPIPROFILE  enables or disables the parallel profiler data collection
%   on a MATLAB worker running a parallel job. MPIPROFILE aggregates
%   statistics on execution time and communication times. The statistics
%   are collected in a manner similar to running the profile command on
%   each matlab worker. By default the parallel profiling extensions
%   include array fields that collect information on communication with
%   each of the other labs. This command in general should be executed in
%   PMODE or as part of a task in a parallel job.
%
% MPIPROFILE ON <options> starts the profiler and clears previously recorded
%   profile statistics.
%
% MPIPROFILE OFF stops the parallel profiler. To reset the state of the
%   profiler and disable collecting communication information please also
%   call CLEAR.
%
% MPIPROFILE takes the following options:
%
%    -DETAIL <level>
%         This option specifies the set of functions for which
%         profiling statistics are gathered.  If <level> is MMEX
%         (the default), then information about MATLAB functions,
%         subfunctions, and MEX-functions is recorded.  If
%         <level> is BUILTIN, then in addition the profiler
%         records information about builtin functions such as
%         EIG.
%    -MESSAGEDETAIL <level>
%         The <level> can be DEFAULT, SIMPLIFIED or OFF. This option
%         specifies the detail at which communication information is
%         stored. By default information is collect on a per lab instance.
%         If you have a very large cluster, you may want to change the
%         level to simplified. This will reduce the profiling overhead.
%         However you will not get all the detailed inter-lab communication
%         plots in the viewer. SIMPLIFIED will turn off collection for
%         PerLab data fields. Note that changing the messagedetail will
%         clear any previously stored data.
%         See MPIPROFILE INFO.
%
%   The parallel profiler also supports these following options via the
%   standard profiler:
%
%    -HISTORY
%    -NOHISTORY
%    -HISTORYSIZE <size>
%    -DETAIL <level>
%
%   No other PROFILE options are supported by MPIPROFILE. Note that the
%   first three options have no effect on the data that is displayed by
%   MPIPROFILE VIEWER. See PROFILE for details.
%
% MPIPROFILE RESUME restarts the profiler without clearing
%   previously recorded function statistics. This works only in pmode or in
%   the same matlab session on a worker.
%
% MPIPROFILE CLEAR clears the profile information.
%
% MPIPROFILE STATUS returns a valid status when it runs on the worker.
%
% MPIPROFILE RESET turns off the parallel profiler and resets the
%   -MESSAGEDETAIL back to the standard profiler. If you do not call reset
%   a subsequent PROFILE ON command can continue to collect MPI information.
%   This action does not reset options that are available with PROFILE
%   (including those listed above).
%
% MPIPROFILE INFO returns a profiling data structure with additional fields
% to the one provided by the standard PROFILE INFO in the FunctionTable
% entry. All these fields are recorded on a per function and per line
% basis, except for the PerLab fields.
%
%     BytesSent           -- Records the quantity of Data Sent
%     BytesReceived       -- Records the quantity of Data Received
%     TimeWasted          -- Records Communication Waiting Time
%     CommTime            -- Records the Communication Time
%     CommTimePerLab      -- Vector of Communication Receive Time for each lab
%     TimeWastedPerLab    -- Vector of Communication Waiting Time for each lab
%     BytesReceivedPerLab -- Vector of Data Received from each lab
% The three PerLab fields are collected only on a per function basis, and
% can be turned off by typing the following command in PMODE:
% mpiprofile on -messagedetail simplified
%
% MPIPROFILE VIEWER
%   The VIEWER is readily used in pmode after running user code with MPIPROFILE
%   ON. Calling the viewer, stops the profiler and opens the graphical
%   profile browser with parallel options.
%   The output is an HTML report displayed in the Profiler window. The
%   file listing at the bottom of the function profile page shows four
%   columns to the left of each line of code. In the summary page
%   * Column 1 indicates the number of calls to that line.
%   * Column 2 indicates total time spent on the line in seconds.
%   * Column 3-6 contain the communication information specific to the
%        parallel profiler
%   Normally MPIPROFILE VIEWER is used in PMODE.
%   MPIPROFILE('viewer', <profinfoarray>) in function form can be used
%   from the client. A structure <profinfoarray> needs to be passed in as the
%   second argument, which is an array of MPIPROFILE INFO structures. See
%   pInfoVector in the example below.
%
% MPIPROFILE will not accept -TIMER CLOCK options. The timer will always be
% set to real and not cpu time.
%
%
% Examples:
%
%  * PMODE
%
%       mpiprofile on;
%       % call your function;
%       mpiprofile viewer;
%
%
%  * On the MATLAB client
%
%   If you want to obtain the profiler information from a parallel job
%   outside of pmode you need to return the MPIPROFILE INFO as output
%   arguments using the functional form of the command.
%   Submit your function foo() as a task in a parallel job:
%
%   function out = foo
%   mpiprofile on
%   yourResults = (rand(1e2)*rand(1e2));
%   out{1} = mpiprofile('info');
%   out{2} = yourResults;
%
%   % After foo() executes on your cluster, get the data using
%   A = job.getAllOutputArguments();
%   % on the client type
%   pInfoVector = cellfun(@(x) x{1}, A);
%   mpiprofile('viewer', pInfoVector);
%
% See also  profile, pmode, mpiprofview and mpiSettings

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2010/03/22 03:42:25 $

% iAddProfilerFileFilters ensures profiler commands are not profiled.
iAddProfilerFileFilters();
[action, argsForProfile, comDetailLevel, errmsg, option] = iParseInputs( varargin{:});

if ~isempty(errmsg)
    error('distcomp:mpiprofile:InvalidInput', errmsg);
end

% insure output is initialised to empty if user request output argument
if nargout > 1
    sOut = [];
end
action = lower(action);
% only viewer and status can be run from both client and worker
if ~any(strcmp(action, {'viewer', 'status'}));
    iEnsureOnWorker(action);
end
% send the arguments that are set by profile to profile command
if ~isempty(argsForProfile)
    profile(argsForProfile{:});
end

switch action

    case 'on'
        % Does not execute on the client
        % Only set timer and message details option if profiler is
        % already off
        if ~iIsProfilerOn()
            iTurnMpiLogOn(comDetailLevel);
        end

        profile('on');

    case 'off'
        % do not execute on the client
        iTurnMpiLogOff();
        profile('off');


    case 'resume'
        % we need to check to make sure mpiprofile is on before we can resume
        if iIsProfilerOn();
            profile('resume');
        else
            %turn on the parallel profiler
            iTurnMpiLogOn(comDetailLevel);
            profile('resume');
        end

    case 'clear'
        % clear profiler info
        profile('clear');

    case 'reset'
        % resets everything back to normal profiler
        profile ('off');
        profile('-timer', 'cpu'); % reset timer back to cpu
        iClearParallelMessageLogging();
        iTurnMpiLogOff();

    case 'status'
        % for backward compatibility we just output a structure with
        % the options that we use for the profiler.
        if iIsOnClient()
            % The viewer needs this structure to show consistent
            % output. Currently only DetailLevel and Timer are used
            justStatus.ProfilerStatus = 'off';
            justStatus.Timer = 'real';
            sOut = justStatus;
        else
            sOut = profile('status');
            % calls callstats('message') with no args to get current state of
            % parallel options
            switch( iGetParallelMsgDetail() )
                case 0
                    detailString= 'off';
                case 1
                    detailString = 'simplified';
                case 2
                    detailString = 'default';
                otherwise
                    detailString = 'unknown';
            end
            sOut.MpiMessageDetail = detailString;
        end

    case 'info'
        % top level ensures we are on a worker
        sOut = profile('info');

    case 'viewer'
        % gather the data and display in Profiler window
        if iIsOnClient()
            % dont do anything if you run viewer on client unless you have
            % the profinfo vector
            iVerifyArgsOutsidePmode(action, option);
        else
            % generate profile info vector
            % gather to a single lab as vector as gcat is more efficient than
            % socket based lab2client
            if ~isempty(option)
                if ischar(option)
                    argString = upper(option);
                else
                    argString = ['of ' upper(class(option))];
                end
                warning('distcomp:mpiprofile:InsidePmodeWarning',...
                    'MPIPROFILE VIEWER does not take any arguments %s inside pmode. Ignoring all additional arguments.', argString);
            end
            profile('off');
            iTurnMpiLogOff();
            profInfo = profile('info');
            MPI_PROF_VECTOR = gcat(profInfo, 1, 1);
            mpiVarString = 'MPI_PROF_VECTOR';
            assignin('base', mpiVarString, MPI_PROF_VECTOR);
            pmode('lab2client', mpiVarString, '1', mpiVarString);
            % then copy to client and run mpiprofview once
            if labindex == 1
                iRunCmdOnClient(sprintf('mpiprofview(0, %s);clear %s;', mpiVarString, mpiVarString));
            end
        end

    case ''
        % no caught action input in command line so we
        % do nothing and pass the arguments to profile at end of switch
        % function

    otherwise
        % error unknown action
        error('distcomp:mpiprofile:InvalidArguments',...
            'Unknown or illegal <action> argument. MPIPROFILE must be called with a valid argument in PMODE or as part of a parallel job.');

end

end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function iTurnMpiLogOn(comDetailLevel)
% no need to throw warning as action commands ensure this can only be
% executed on client

callstats('message', comDetailLevel);
profile('-timer', 'real');
% set callback from gateway to profiler
mpigateway( 'logprof' );
% turn on logging of mpi primitives
mpigateway( 'logon' );


end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function iTurnMpiLogOff
if mpiInitialized
    mpigateway( 'logoff' );
end
end

%--------------------------------------------------------------------------
% parses the inputs and gets the action and arguments to pass to profile
%--------------------------------------------------------------------------
function [action argsForProfile detailLevel msg vieweroptions] = iParseInputs(varargin)
% default outputs
argsForProfile = {};
% get the user setable default message detail from private function
detailLevel = userMessageDetail();
msg = nargchk(1,Inf,nargin);
vieweroptions = '';
action = '';

if ~isempty(msg)
    return;
end

isPairedArg = false;

% The last action will take precedence
% no error is thrown just like profile on off;
for k = 1:length(varargin)
    if isPairedArg
        % second argument has already been consumed
        isPairedArg = false;
        % hence skip this argument
        continue;
    end
    arg = varargin{k};
    if ( (~ischar(arg) && ~isPairedArg) || isempty(arg))
        msg = 'Invalid input to mpiprofile.';
        return;
    end
    switch lower(arg)

        case 'viewer'
            % This is the only action we deal with that is also dealt with
            % by parser since it can be paired.
            % Here we look for a potential followup profile info argument
            action = arg;
            if numel(varargin)> k
                vieweroptions =  varargin{k+1};
            end
            % if its a profiler structure
            if isstruct(vieweroptions)
                % we have a profile info vector input
                % so consume the following argument
                isPairedArg = true;
            end

        case '-messagedetail'
            detailLevel = iVerifyNumAndTypeOfArgs(varargin, k, k + 1, 'detaillevel');
            isPairedArg = true;
            msg = iSetParallelMsgDetailAndEnsureOnWorker( detailLevel );


            % *******arguments to pass to standard profile command*******
        case {'-historysize', '-detail'}
            % lets profile ensure the type of the second argument
            iVerifyNumAndTypeOfArgs(varargin, k, k+1,'');
            % type empty means the type of the second(k+1) argument is not checked
            argsForProfile{end+1} = arg; %#ok
            argsForProfile{end+1} =  varargin{k+1}; %#ok
            isPairedArg = true;

        case {'-history', '-nohistory'}
            argsForProfile{end+1} = arg; %#ok
            % *******END arguments to pass to standard profile command*******

        case '-timer'
            iVerifyNumAndTypeOfArgs(varargin, k, k + 1,'string');
            isPairedArg = true;
            iDealWithUnSupportedOption(arg);

        case '-reset'
            % removes parallel profiler message collection and resets
            % profile info
            profile('off');
            iClearParallelMessageLogging();

        otherwise
            isOption = arg(1)=='-';
            if isOption
                % dont store the argument as action and error out
                msg = 'Unsupported or invalid option';
            else
                if ~isempty(action)
                    warning('distcomp:mpiprofile:UnsupportedNumberOfActions',...
                        'MPIPROFILE %s should not be mixed with another action %s.', upper(action), upper(arg));
                end
                action = arg;
            end
    end
end
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function msg = iSetParallelMsgDetailAndEnsureOnWorker(comDetailLvl)
% returns an error message if it fails to set the comDetailLevel because
% the profile is on
if ~iIsProfilerOn()
    callstats( 'message', comDetailLvl );
    userMessageDetail(comDetailLvl);
    msg = '';
else
    % This message will eventually be thrown at the top level
    msg = sprintf(['The profiler has already been started.'...
        'MESSAGEDETAIL cannot be changed until you turn MPIPROFILE OFF or CLEAR.']);
end
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function detailLvl = iGetParallelMsgDetail()
% get the message detail level from the profiler
detailLvl = callstats('message');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function iClearParallelMessageLogging()
% stops profiler from collecting communication information

try
    callstats( 'message', 0 );
    err = [];
catch exception
    err = exception;
end

% reset the user persistent messagedetail setting back to default which currently is 2.
userMessageDetail(-1);
if ~isempty(err)
    rethrow(err);
end
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function isOn = iIsProfilerOn()
% Error if we are not on the worker. The action is only used to generate a more
% customised error.
pStatus = profile('status');
isOn = strcmpi(pStatus.ProfilerStatus,'on');
% throw warning if its on but no communication fields are being recorded
% because profile on was used.
if isOn && iGetParallelMsgDetail()==0 && userMessageDetail ~= 0
    warning('distcomp:mpiprofile:NotInParallelMode', ...
        'Warning you appear to be using MPIPROFILE after calling PROFILE. Communication fields will not be recorded.');
end
end



%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function iEnsureOnWorker(action)

if iIsOnClient()
   error('distcomp:mpiprofile:OnClientError',...
        ['MPIPROFILE %s must run in pmode or as part of a parallel job.\n'...
        'See doc for MPIPROFILE in the Parallel Computing Toolbox.'], action);
end
end


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function verifiedVal = iVerifyNumAndTypeOfArgs(varargin, argNum, valNum, valType)
% iVerifyNumAndTypeOfArgs(varargin, inK, Type)
% verifies the type and number of options to output a relevant message.
ERROR = -1;
if numel(varargin) < valNum
    error('distcomp:mpiprofile:InvalidNumArgs', ...
        '%s requires at least one following %s argument',...
        upper(varargin{argNum}), valType);
else
    switch(valType)

        case 'integer'
            thenum = varargin{valNum};
            if ischar(thenum)
                thenum = str2double(thenum);
            end
            if iIsValidInteger(thenum)
                verifiedVal = thenum;
            else
                verifiedVal = ERROR;
            end
            % case deal with message detail enumeration
        case 'detaillevel'
            msgDetail = varargin{valNum};
            if any(strcmpi(msgDetail, {'simplified', 'novectorfields'}))
                verifiedVal = 1;
            elseif any(strcmpi(msgDetail, {'default', 'withvectorfields'}))
                verifiedVal = 2;
            elseif strcmpi(msgDetail, 'off')
                verifiedVal = 0;
            else
                % indicate error
                verifiedVal = ERROR;
                valType = 'default | simplified | off';
            end

        case 'string'
            if ischar( varargin{argNum})
                verifiedVal = 1;
            else
                verifiedVal = ERROR;
            end

        otherwise
            verifiedVal = true;
    end

    if verifiedVal == ERROR
        error('distcomp:mpiprofile:InvalidInputType', ...
            '%s requires a following %s argument.', upper(varargin{argNum}), upper(valType));
    end


end
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function onclient = iIsOnClient()
onclient = ~system_dependent('isdmlworker');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function iRunCmdOnClient(cmd)
%iRunCmdOnClient Send a command back to the client for asynchronous evaluation.
session = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession;
if isempty(session)
    error('distcomp:mpiprofile:pmodeNotRunning', ...
        'Cannot execute %s from pmode as the session isempty!', cmd);
end
% Error messages will only be displayed in the main MATLAB command window, and
% the command will only be executed in the MATLAB client when it is idle.
c = session.getClient;
c.evalConsoleOutput(cmd);
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function iVerifyArgsOutsidePmode(action, option)

switch (action)
    case 'viewer'
        hasProfInfoVector = ~isempty(option) && isstruct(option);
        if ~hasProfInfoVector
            fprintf(2, 'Refer to the Parallel Computing Toolbox documentation for MPIPROFILE.\n');
            error('distcomp:mpiprofile:InvalidInput', ...
                'MPIPROFILE(''%s'', profInfoVector) takes an array of profile info objects when not in PMODE.', action);
        else
            % try running the profile viewer
            mpiprofview(0, option);
        end
    otherwise
        error('distcomp:mpiprofile:OnClientError', ...
            'MPIPROFILE(''%s'') does not work outside of PMODE or parallel jobs.', action);

end

end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function valid = iIsValidInteger(value)
valid = isnumeric(value) && isreal(value) && ~isnan(value);
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function iDealWithUnSupportedOption(arg)
warning('distcomp:mpiprofile:UnsupportedOptions',...
    'Changing %s option is not supported in mpiprofile', arg);
end

%--------------------------------------------------------------------------
% This function ensures the mpriprofile commands are not profiled.
% It is based on function add_profiler_file_filters in profile.m from March
% 2007
%--------------------------------------------------------------------------
function iAddProfilerFileFilters()
% make sure the profiler filters out functions and files used M profiler
% interface.
persistent didadd;
if isempty(didadd)
    didadd = true;
    files = { 'mpiprofile.m', 'mpiprofview.m', 'private/userMessageDetail.m' };
    for i = 1:length(files)
        fname = fullfile(toolboxdir('distcomp'), 'mpi', files{i});
        callstats('ffilter', 'add', fname);
    end
end
end
