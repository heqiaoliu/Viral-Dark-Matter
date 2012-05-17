function pmode(action, varargin)
%PMODE Interactive parallel command window
%   PMODE allows interactive parallel execution of MATLAB commands.  PMODE
%   achieves this by defining and submitting a parallel job, and it opens a
%   Parallel Command Window connected to the labs running the job.  The labs
%   receive commands entered in the Parallel Command Window, process them,
%   and send the command output back to the Parallel Command Window.
%
%   SYNTAX
%
%     PMODE START
%     PMODE START CONF <numlabs>
%     PMODE QUIT or PMODE EXIT or PMODE CLOSE
%     PMODE CLIENT2LAB CLIENTVAR <labs> LABVAR
%     PMODE LAB2CLIENT LABVAR <lab> CLIENTVAR
%     PMODE CLEANUP CONF
%
%   PMODE START  starts pmode using the default parallel configuration and 4
%   local labs.  You can also specify the number of labs using PMODE START
%   <numlabs>, but note that most schedulers have a maximum number of processes 
%   that they can start.
%
%   PMODE START CONF <numlabs> starts pmode using the parallel configuration
%   CONF to locate the scheduler.  If the number of labs is specified, it
%   overrides the minimum and maximum number of workers specified in the
%   configuration.
%
%   PMODE QUIT or PMODE EXIT or PMODE CLOSE stops the parallel job, destroys
%   it, and closes the Parallel Command Window.
%
%   PMODE CLIENT2LAB CLIENTVAR <labs> LABVAR  copies the variable CLIENTVAR from
%   the MATLAB client to the variable LABVAR on labs <labs>.  If LABVAR is
%   omitted, the copy is named CLIENTVAR.  The destination labs can be
%   either a single lab index or a vector of lab indices.
%
%   PMODE LAB2CLIENT LABVAR <lab> CLIENTVAR  copies the variable LABVAR from
%   lab <lab> to the variable CLIENTVAR on the MATLAB client.  If CLIENTVAR is
%   omitted, the copy is named LABVAR.
%
%   PMODE CLEANUP CONF  destroys all parallel jobs created by pmode for the
%   current user using the scheduler specified by the configuration CONF.  This
%   includes jobs that are currently running.  The configuration is optional,
%   and the default parallel configuration is used if none is provided.
%
%   PMODE can be invoked as either a command or a function.  For example, the
%   following are equivalent:
%       PMODE START CONF 4 
%       PMODE('START', 'CONF', 4)
%
%   EXAMPLES
%   1. Start pmode using the default parallel configuration:
%       >> pmode start 
%   2. Execute the command    X = 2*labindex;    on all labs:
%       P>> X = 2*labindex;
%   3. Copy the variable X from lab 3 to the MATLAB client:
%       >> pmode lab2client X 3
%   4. Copy the variable y from the MATLAB client to labs 1-4:
%       >> pmode client2lab y 1:4
%
%   See also findResource, createParallelJob, defaultParallelConfig.

%   Copyright 2006-2010 The MathWorks, Inc.

%  $Revision: 1.1.8.14 $  $Date: 2010/05/03 16:03:33 $

    iVerifyJava();
    
    msgValidActions = ['Valid actions are: start open exit quit close ' ...
                       'client2lab lab2client cleanup'];
    % The action is a required input.
    if nargin == 0
        error('distcomp:pmode:InvalidInput', 'No action specified.\n%s', ...
              msgValidActions);
    end
    % Check that action is a 1xN char array.
    if ~(ischar(action) && (size(action, 2) == numel(action)))
        error('distcomp:pmode:InvalidInput', ...
              'The action parameter must be a string.\n%s', msgValidActions);
    end
    client = distcomp.getInteractiveObject();
    action = lower(action);
    switch action
      case {'start' 'open'}
        iVerifyOnClient(action);
        [nlabs, config] = iParseStartArgs(varargin{:});
        if isempty(config)
            % Use the default config if one was not specified
            config = defaultParallelConfig;
        end
        sched = distcomp.pGetScheduler(config);
        client.start('pmode', nlabs, sched, 'opengui');
      case {'exit', 'quit', 'close'}
        % Exit and quit take no additional arguments.            
        iVerifyNoArgs(action, numel(varargin));
        if iIsOnClient()
            client.stopLabsAndDisconnect('pmode');
        else
            % We allow all the labs to send this command back to the client, to
            % ensure that the command is run.  
            cmd = 'pmode exitnoerrors';
            iRunCmdOnClient(action, cmd);
        end
      case 'exitnoerrors'
            % Put into a try-catch block so that the numlabs - 1 times it is run
            % unnecessarily, we do not throw a visible error in the MATLAB
            % command window.
        try
            client.stopLabsAndDisconnect('pmode');
        catch e %#ok<NASGU>
        end
            
      case 'exitleaveguiopen' % Undocumented.
        % exitleaveguiopen takes no additional arguments.
        iVerifyNoArgs(action, numel(varargin));
        iVerifyOnClient(action);
        dctPathAndClearNotification('off');
        client.stopLabsAndDisconnect('force', 'leaveguiopen');
      case 'lab2client'
        [labvarname, lab, clientvarname] = iParseTransferArgs(...
            action, varargin{:});
        if ~iIsIntegerScalar(lab, 1, iGetNumLabs(action))
            error('distcomp:pmode:InvalidInput', ...
                  'The source lab must be an integer between 1 and %d.', ...
                  iGetNumLabs(action));
        end
        if iIsOnClient()
            client.lab2client(labvarname, lab, clientvarname);
        else
            if labindex == lab
                cmd = sprintf('pmode(''%s'', ''%s'', %s, ''%s'');', ...
                              action, labvarname, num2str(lab), clientvarname);
                iRunCmdOnClient(action, cmd);
            end
        end
      case 'client2lab'
        [clientvarname, labs, labvarname] = iParseTransferArgs( ...
            action, varargin{:});
        if ~iIsIntegerVector(labs, 1, iGetNumLabs(action)) || isempty(labs)
            error('distcomp:pmode:InvalidInput', ...
                  ['The destination lab(s) must be integer(s) between 1 ' ...
                   'and %d.'], iGetNumLabs(action));
        end
        if iIsOnClient() 
            client.client2lab(clientvarname, labs, labvarname);
        else
            if min(labs) == labindex
                cmd = sprintf('pmode(''%s'', ''%s'', [%s], ''%s'');', ...
                              action, clientvarname, num2str(labs), labvarname);
                iRunCmdOnClient(action, cmd);
            end
        end
      case 'cleanup'
        config = iParseCleanupArgs(varargin{:});
        if iIsOnClient()
            client.cleanup('pmode', config);
        else
            % We always want this action to be performed, even if it is 
            % executed on only one lab.  We must therefore allow all labs to 
            % send it back to the client.
            cmd = sprintf('pmode(''%s'', ''%s'');', action, config);
            iRunCmdOnClient(action, cmd);
        end
      otherwise
        error('distcomp:pmode:InvalidInput', ...
              'Invalid action: ''%s''.\n%s', action, msgValidActions);
    end
end

function [nlabs, config] = iParseStartArgs(varargin)
%iParseStartArgs Parse the input arguments to pmode start.    
%   Varargin should be one of:
%   {}, {config, numlabs}, {config}, {numlabs}
%   Return the number of labs and the configuration.  These are empty if
%   not specified in the input.
%   We perform no input checking on the configuration, but rely on the error
%   messages from findResource.
    if numel(varargin) > 2
        error('distcomp:pmode:InvalidInput', ...
               'pmode start takes 0 to 2 arguments.');
    end
    config = '';
    nlabs = [];
    if isempty(varargin)
        return;
    end
    if numel(varargin) == 1
        % Only one input argument.  It can be either the number of labs or
        % the configuration.  If we can convert the input to an integer, it
        % must be the number of labs, otherwise it must be the
        % configuration.
        if isnumeric(varargin{1})
            nlabs = varargin{1};
        else
            % Try to convert varargin{1} to double.
            nlabs = str2double(varargin{1});
            if ~isfinite(nlabs)
                % Conversion to double failed, so varargin{1} must be a 
                % configuration.
                config = varargin{1};
                nlabs = [];
            end
        end
    else
        config = varargin{1};
        nlabs = varargin{2};
        if ~isnumeric(nlabs)
            nlabs = str2double(nlabs); 
            % Now nlabs is either a double or a NaN.
        end
    end
    if ~isempty(nlabs) && ~iIsIntegerScalar(nlabs, 1, realmax)
        error('distcomp:pmode:InvalidInput', ...
              'The number of labs must be a finite, positive, integer.');
    end
end

function [srcvarname, labs, destvarname] = iParseTransferArgs(action, varargin)
%iParseTransferArgs Parse the input arguments to pmode client2lab and pmode
%lab2client.
%   srcStr is a string describing the source variable.  E.g. CLIENTVAR.
%   destStr is a string describing the destination variab.e  E.g. LABVAR.
%   Parses the arguments, verifies that pmode is running.  Returns the
%   names of the source and the destination variables.  
%   The labs argument is returned with almost no argument checking.  We try
%   to convert it to a vector of doubles.  Caller must verify that it is a
%   vector and that it only contains ints in the range [1, numlabs].
    if ~(2 <= numel(varargin) && numel(varargin) <= 3)
        error('distcomp:pmode:InvalidInput', ...
              'pmode %s requires 2 or 3 arguments.', action);
    end
    srcvarname = varargin{1};
    labs = varargin{2};
    if numel(varargin) > 2
        destvarname = varargin{3};
    else
        destvarname = srcvarname;
    end
    if ~isvarname(srcvarname)
        error('distcomp:pmode:InvalidInput', ...
              'Invalid name of source variable.');
    end
    if ~isvarname(destvarname)
        error('distcomp:pmode:InvalidInput', ...
              'Invalid name of target variable.');
    end
    if iIsOnClient()
        client = distcomp.getInteractiveObject();
        pmodeRunning = client.isPossiblyRunning();
    else
        pmodeRunning = ~isempty(com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession);
    end
    if ~pmodeRunning
        error('distcomp:pmode:NotRunning', ...
              'Cannot execute pmode %s when pmode is not running.', action);
    end
    if ischar(labs)
        labs = str2num(labs); %#ok Allow arrays of integers.
    end
end

function config = iParseCleanupArgs(varargin)
%iParseCleanupArgs Parse the input arguments to pmode cleanup.
%   Varargin should be one of:
%   {}, {config}
%   Return the configuration.  It is empty if not specified in the input.
%   We perform no input checking on the configuration, but rely on the error
%   messages from findResource.
    if numel(varargin) > 1
        error('distcomp:pmode:InvalidInput', ...
               'pmode cleanup takes 0 or 1 argument.');
    end
    config = '';
    if ~isempty(varargin)
        config = varargin{1};
    end
 end

function iVerifyNoArgs(action, nargs)
    if nargs ~= 0
        error('distcomp:pmode:InvalidInput', ...
              'pmode %s takes no arguments.', action);
    end
end

function valid = iIsIntegerScalar(value, lowerBound, upperBound)
%iIsIntegerScalar Check if input is a scalar integer within the specified
%bounds.
    valid = iIsIntegerVector(value, lowerBound, upperBound) ...
            && isscalar(value);
end

function valid = iIsIntegerVector(value, lowerBound, upperBound)
%iIsIntegerScalarVector Check if input is a vector of integers within the
%specified bounds.
    valid = isnumeric(value) && isreal(value) && isvector(value) ...
            && all((value >= lowerBound)) ...
            && all(value <= upperBound) && ~any(isnan(value)) ...
            && all(fix(value) == value);
end

function iVerifyOnClient(action)
%iVerifyOnClient A noop on the MATLAB client.
%   Error if trying to execute pmode with this action on the labs.
    if ~iIsOnClient()
        error('distcomp:pmode:RunOnLabs', ...
              'Cannot execute    pmode %s    on the labs.', action);
    end
end

function onclient = iIsOnClient()
    onclient = ~system_dependent('isdmlworker');
end

function iVerifyJava()
%iVerifyJava Error if swing is not present.    
    if iIsOnClient()
        error(javachk('swing', 'pmode'));
    end
end

function iRunCmdOnClient(action, cmd)
%iRunCmdOnClient Send a command back to the client for asynchronous evaluation.
    session = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession; 
    if isempty(session)
        error('distcomp:pmode:NotRunning', ...
              'Cannot execute pmode %s when pmode is not running.', action);
    end
    % Error messages will only be displayed in the main MATLAB command window, and
    % the command will only be executed in the MATLAB client when it is idle.
    fprintf('Sending  pmode %s  to the MATLAB client for asynchronous evaluation.', action);
    c = session.getClient;
    c.evalConsoleOutput(cmd);
end

function nlabs = iGetNumLabs(action)
%iGetNumLabs Can be called both on the client and the labs to get numlabs.
    if ~iIsOnClient()
        nlabs = numlabs;
        return;
    end
    try
        session = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession;
        nlabs = session.getPoolSize();
    catch err
        newEx = MException('distcomp:pmode:NotRunning', ...
                           'Cannot execute pmode %s when pmode is not running.', action);
        newEx = newEx.addCause(err);
        throw(newEx);
    end
end
