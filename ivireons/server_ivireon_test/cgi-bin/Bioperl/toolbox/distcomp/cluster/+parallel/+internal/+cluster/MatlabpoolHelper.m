classdef MatlabpoolHelper
% Helper class for actitivities related to matlabpool

%  Copyright 2010 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2010/02/25 08:01:57 $

    properties (Constant)
        % The valid actions for matlabpool.  Be sure to update the 
        % getAllActions() method if this list of actions changes.
        OpenAction = 'open';
        CloseAction = 'close';
        SizeAction = 'size';
        ExitLeaveGuiOpenAction = 'exitleaveguiopen';
        AddFileDependenciesAction = 'addfiledependencies';
        UpdateFileDependenciesAction = 'updatefiledependencies';
        
        FoundNoParseActionErrorIdentifier = 'distcomp:matlabpool:FoundNoParseAction';
    end
    
    methods (Static)
        % -------------------------------------------------------------------------
        % getAllActions
        % -------------------------------------------------------------------------
        function validActions = getAllActions
            import parallel.internal.cluster.MatlabpoolHelper;
            validActions = {MatlabpoolHelper.OpenAction, ...
                MatlabpoolHelper.CloseAction, ...
                MatlabpoolHelper.SizeAction, ...
                MatlabpoolHelper.ExitLeaveGuiOpenAction, ...
                MatlabpoolHelper.AddFileDependenciesAction, ...
                MatlabpoolHelper.UpdateFileDependenciesAction};
        end

        % -------------------------------------------------------------------------
        % parseMatlabpoolInputs
        % -------------------------------------------------------------------------
        % testAndReturnConfigurationFcn is a function handle that takes in a 
        % configuration name and returns the configuration name to use (if a 
        % configuration is allowed), and errors if the configuration is not allowed.
        function parsedArgs = parseMatlabpoolInputs(actionsToParse, testAndReturnConfigurationFcn, varargin)
            import parallel.internal.cluster.MatlabpoolHelper;
            % Ensure that actionsToParse is a cell array of strings
            if ischar(actionsToParse)
                actionsToParse = cellstr(actionsToParse);
            end
            
            validActions = MatlabpoolHelper.getAllActions();
            
            assert(all(ismember(actionsToParse, validActions)));
            msgValidActions = sprintf('Valid actions for matlabpool are:%s', ...
                sprintf('\n\t%s', actionsToParse{:}));
            
            % Want a way to distinguish between a supplied action and an inferred
            % action (where the first argument isn't a validAction and so open is
            % deduced)
            actionFound = true;
            % No action at all means it defaults to 'open'
            if numel(varargin) == 0
                action = MatlabpoolHelper.OpenAction;
                actionFound = false;
            else
                action = varargin{1};
                % Now check if the first element of varargin is a valid action
                if ischar(action) && (size(action, 2) == numel(action)) && any(strcmpi(action, validActions))
                    % Remove varargin{1} because it was a valid action
                    varargin(1) = [];
                else
                    % If it isn't then set the action to be start
                    action = MatlabpoolHelper.OpenAction;
                    actionFound = false;
                end
            end
            
            action = lower(action);
            % Error here if the action we identified is not one of the ones 
            % we wish to continue parsing
            if ~any(strcmpi(action, actionsToParse))
                error(MatlabpoolHelper.FoundNoParseActionErrorIdentifier, ...
                    'Action %s is not in list of actions to parse', action);
            end

            % Action args will always have Configuration field, whether or not it was user supplied, and the 
            % corresponding scheduler object.
            actionArgs = struct('Configuration', '', ...
                'UserSuppliedConfiguration', false, ...
                'Scheduler', []);
                
            switch action
                case MatlabpoolHelper.OpenAction
                    MatlabpoolHelper.errorIfNotOnClient(action);
                    [nlabs, config, filedeps] = MatlabpoolHelper.parseOpenArgs(actionFound, msgValidActions, varargin{:});

                    % Determine upfront whether or not the user supplied a config - need to 
                    % do this before the configuration test because the test may return a 
                    % non-empty configuration.
                    userSuppliedConfiguration = ~isempty(config);
                    % do the configuration test - this will error if the config doesn't pass the test
                    config = testAndReturnConfigurationFcn(config);
                    
                    % Now set the action args
                    actionArgs.Configuration = config;
                    actionArgs.UserSuppliedConfiguration = userSuppliedConfiguration;
                    actionArgs.NumLabs = nlabs;
                    actionArgs.FileDependencies = filedeps;
                    
                    % Get the scheduler from the configuration, if available
                    % Note that open is the only action that requires a scheduler
                    if ~isempty(actionArgs.Configuration)
                        % Get the scheduler from the configuration
                        actionArgs.Scheduler = distcomp.pGetScheduler(actionArgs.Configuration);
                    end

                case MatlabpoolHelper.CloseAction
                    MatlabpoolHelper.errorIfNotOnClient(action);
                    [isForce, config] = MatlabpoolHelper.parseCloseArgs(varargin{:});

                    % Determine upfront whether or not the user supplied a config - need to 
                    % do this before the configuration test because the test may return a 
                    % non-empty configuration.
                    userSuppliedConfiguration = ~isempty(config);
                    % do the configuration test - this will error if the config doesn't pass the test
                    config = testAndReturnConfigurationFcn(config);

                    % Now set the action args
                    actionArgs.Configuration = config;
                    actionArgs.UserSuppliedConfiguration = userSuppliedConfiguration;
                    actionArgs.IsForce = isForce;
                    
                    % Don't get the scheduler from the configuration because we don't need it for the
                    % close action.
                    
                case MatlabpoolHelper.SizeAction
                    MatlabpoolHelper.errorIfArgs(action, numel(varargin));
                    
                case MatlabpoolHelper.AddFileDependenciesAction
                    MatlabpoolHelper.errorIfNotOnClient(action);
                    MatlabpoolHelper.errorIfNotSingleCellString(action, varargin{:});
                    actionArgs.ListOfFiles = varargin{1};
                    
                case MatlabpoolHelper.UpdateFileDependenciesAction
                    MatlabpoolHelper.errorIfNotOnClient(action);
                    % UpdateFileDependencies takes no additional arguments.
                    MatlabpoolHelper.errorIfArgs(action, numel(varargin));
                    
                case MatlabpoolHelper.ExitLeaveGuiOpenAction % Undocumented.
                    MatlabpoolHelper.errorIfNotOnClient(action);
                    % exitleaveguiopen takes no additional arguments.
                    MatlabpoolHelper.errorIfArgs(action, numel(varargin));
                    
                otherwise
                    error('distcomp:matlabpool:InvalidInput', ...
                        'Invalid action: ''%s''.\n%s', action, msgValidActions);
            end

            parsedArgs.Action = action;
            parsedArgs.ActionArgs = actionArgs;
        end
        
        % -------------------------------------------------------------------------
        % doMatlabpool
        % -------------------------------------------------------------------------
        % Actually run the relevant matlabpool command.  sched is only required if 
        % parsedArgs.Action is OpenAction.
        function argsout = doMatlabpool(parsedArgs, sched)
            import parallel.internal.cluster.MatlabpoolHelper;
            argsout = {};
            switch parsedArgs.Action
                case MatlabpoolHelper.OpenAction
                    assert(~isempty(sched), 'distcomp:MatlabpoolHelper:NoSchedulerSupplied', ...
                        'A scheduler must be supplied for matlabpool %s.', ...
                        MatlabpoolHelper.OpenAction);
                    MatlabpoolHelper.doOpen(sched, parsedArgs.ActionArgs);
                case MatlabpoolHelper.CloseAction
                    MatlabpoolHelper.doClose(parsedArgs.ActionArgs);
                case MatlabpoolHelper.SizeAction
                    argsout{1} = MatlabpoolHelper.doSize();
                case MatlabpoolHelper.AddFileDependenciesAction
                    MatlabpoolHelper.doAddFileDependencies(parsedArgs.ActionArgs);
                case MatlabpoolHelper.UpdateFileDependenciesAction
                    MatlabpoolHelper.doUpdateFileDependencies();
                case MatlabpoolHelper.ExitLeaveGuiOpenAction % Undocumented.
                    MatlabpoolHelper.doExitLeaveGuiOpen();
                otherwise
                    error('distcomp:matlabpool:InvalidAction', ...
                        'Invalid action: ''%s''.', parsedArgs.Action);
            end
        end
    end
    
    
    methods (Static, Access = private) % Methods that actually run the matlabpool stuff
        % -------------------------------------------------------------------------
        % doOpen
        % -------------------------------------------------------------------------
        % Opens a matlabpool on the supplied scheduler
        function doOpen(sched, parsedOpenArgs)
            client = distcomp.getInteractiveObject();
            client.start('matlabpool', parsedOpenArgs.NumLabs, sched, 'nogui', parsedOpenArgs.FileDependencies);
            dctPathAndClearNotificationGateway('on');
            % Endeavor to force the remote workers to pick-up the same working
            % directory as we are in - this is used for all schedulers other than
            % the local one, which starts out in the right place.
            cd(pwd);
        end
        
        % -------------------------------------------------------------------------
        % doClose
        % -------------------------------------------------------------------------
        function doClose(parsedCloseArgs)
            client = distcomp.getInteractiveObject();
            
            if parsedCloseArgs.IsForce
                dctPathAndClearNotificationGateway('off');
                client.cleanup('matlabpool', parsedCloseArgs.Configuration);
            else
                % Exit and quit take no additional arguments.
                dctPathAndClearNotificationGateway('off');
                client.stopLabsAndDisconnect('matlabpool');
            end
        end
        
        % -------------------------------------------------------------------------
        % doSize
        % -------------------------------------------------------------------------
        function sz = doSize()
            % doSize Return the size of the matlabpool or 0 if it is not open.
            session = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession;
            if ~isempty( session ) && session.isSessionRunning() && session.isPoolManagerSession()
                client = distcomp.getInteractiveObject();

                % Size of a pmode interactive client is ALWAYS zero - otherwise ask the
                % session how big its pool is.
                if isa( client, 'distcomp.interactiveclient' ) && strcmp( client.CurrentInteractiveType, 'pmode' )
                    sz = 0;
                else
                    sz = session.getPoolSize();
                end
                return;
            end 
            sz = 0;
        end

        % -------------------------------------------------------------------------
        % doExitLeaveGuiOpen
        % -------------------------------------------------------------------------
        function doExitLeaveGuiOpen()
            client = distcomp.getInteractiveObject();
            dctPathAndClearNotificationGateway('off');
            client.stopLabsAndDisconnect('force', 'leaveguiopen');
        end
        
        % -------------------------------------------------------------------------
        % doAddFileDependencies
        % -------------------------------------------------------------------------
        function doAddFileDependencies(parsedAddFileDependenciesArgs)
            import com.mathworks.toolbox.distcomp.pmode.*
            % First canonicalize the list
            listOfFiles = distcomp.pCanonicalizeFileDependenciesList(parsedAddFileDependenciesArgs.ListOfFiles);
            isDir = false(numel(listOfFiles), 1);
            % Check each correctly references a file or directory
            for i = 1:numel(listOfFiles)
                thisFile = listOfFiles{i}; 
                if ~exist(thisFile, 'file')
                    error('distcomp:matlabpool:InvalidDependency', ...
                        'The dependency %s does not reference a valid file or directory', thisFile);
                end
                % If it exists then check if it is a dir or a file
                isDir(i) = exist(thisFile, 'dir');
            end
            % Get the FileDependenciesAssistant from the current session
            session = SessionFactory.getCurrentSession;
            if isempty(session) || ~session.isSessionRunning
                error('distcomp:matlabpool:PoolNotRunning', ...
                    'matlabpool is not currently active.\nUse   matlabpool open   to start an interactive session');
            end
            fda = session.getFileDependenciesAssistant;
            % Create a linked list to track the list of completion observers
            lo = java.util.LinkedList();
            % Loop backwards because we expect the first added to be at the top of the
            % path not the end
            cwd = pwd;
            for i = numel(listOfFiles):-1:1
                thisFile = listOfFiles{i};
                if isDir(i)
                    % Send directories by zipping them up and sending the zip. Note
                    % that the cleanup object will take responsibility for removing the zip file
                    % once the message has been received by all
                    [zipName, cleanupObject] = distcomp.pCreateZipfileFromDependencies({thisFile}); %#ok<NASGU>
                    obs = fda.addNewDirectoryDependency( zipName, cwd, thisFile );
                else
                    % Send files as is.
                    obs = fda.addNewFileDependency( cwd, thisFile );
                end
                % Make sure we retain the observer for each requested transfer
                lo.add( obs );
            end
            % Create a linked list to track the completion of the file sends
            lf = java.util.LinkedList();
            % Wait for all the transfers to complete - but ALWAYS loop so that this is
            % interruptable
            while ~FileTransferObserver.waitForCompletionOfObserverList(lo, lf, 1, java.util.concurrent.TimeUnit.SECONDS)
            end
            % Convert to an array for handling in MATLAB - now that java is finished
            % with the variable
            lf = lf.toArray;
            errorDetected = false;
            for i = 1:numel(lf)
                % Get the transfer errors from this file send to see if we should
                % indicate something went wrong.
                errors = parallel.internal.cluster.MatlabpoolHelper.getTransferError( lf(i) );    
                if ~isempty(errors)
                    % If we haven't already created the top level error then make it
                    if ~errorDetected 
                        errorDetected = true;
                        errorToThrow = MException('distcomp:matlabpool:FileTransferError', 'Error detected whilst transferring files to labs.');
                    end
                    % Which file were we trying to send across.
                    file = char(lf(i).getFile);
                    % Add a cause to the overall error we are going to throw
                    errorToThrow = errorToThrow.addCause( MException('distcomp:matlabpool:FileTransferError', ...
                        'Unable to complete transfer for local file %s\nRemote error message is:%s', ...
                        file, errors));
                end
            end
            % If we did detect an error then throw it here - having look over all
            % observers.
            if errorDetected
                throw(errorToThrow);
            end
        end
        
        % -------------------------------------------------------------------------
        % doUpdateFileDependencies
        % -------------------------------------------------------------------------
        function doUpdateFileDependencies()
            import com.mathworks.toolbox.distcomp.pmode.*
            % Get the FileDependenciesAssistant from the current session
            session = SessionFactory.getCurrentSession;
            if isempty(session) || ~session.isSessionRunning
                % Do nothing if there isn't a session running - simply return
                return
            end
            fda = session.getFileDependenciesAssistant;
            % Find files that have changed since we last looked 
            mapFiles = fda.findChangedFiles;
            if mapFiles.isEmpty()
                % If there is nothing to change then we can return early
                return
            end
            % Ask the FileDependenciesAssistant to send this list of changed files -
            % getting back a list of observers to those sends
            lo = fda.sendChangedFiles(mapFiles);
            % Create a linked list to track the completion of the file sends
            lf = java.util.LinkedList();
            % Wait for all the transfers to complete - but ALWAYS loop so that this is
            % interruptable
            while ~FileTransferObserver.waitForCompletionOfObserverList( lo, lf, 1, java.util.concurrent.TimeUnit.SECONDS )
            end
            % Convert to an array for handling in MATLAB - now that java is finished
            % with the variable
            lf = lf.toArray;
            for i = 1:numel(lf)
                % Get the transfer errors from this file send to see if we should
                % indicate something went wrong.
                errors = parallel.internal.cluster.MatlabpoolHelper.getTransferError( lf(i) );
                if ~isempty(errors)
                    % Which file were we trying to send across.
                    file = char(lf(i).getFile);
                    warning('distcomp:matlabpool:FileUpdateWarning', ...
                        'Unable to complete update for local file %s\nRemote error message is:%s', ...
                        file, errors);
                end
            end
            % If all was successful then update the time that we last checked at.
            fda.fLastCheckTime = floor(java.lang.System.currentTimeMillis/1000);
        end
    end
    
    
    methods (Static, Access = private)
        % -------------------------------------------------------------------------
        % parseOpenArgs
        % -------------------------------------------------------------------------
        % Parse the input arguments to matlabpool open.
        %   Varargin should be one of:
        %   {}, {config, numlabs}, {config}, {numlabs}
        %   Potentially followed by PV pair - 'FileDependencies', {filedeps}
        %   Return the number of labs, the configuration and the specified FileDependencies.
        %   These are empty if not specified in the input.
        function [nlabs, config, filedeps] = parseOpenArgs(OPEN_ACTION_SUPPLIED, msgValidActions, varargin)
            import parallel.internal.cluster.MatlabpoolHelper;
            config = '';
            nlabs = [];
            filedeps = {};
            if isempty(varargin)
                return;
            end

            % Allowed to specify FileDependencies via param/value pair:
            % - Full string matching
            % - Case sensitive
            % - Must be as param/value pair - CAN NOT be a struct or cell
            allowedProps = {'FileDependencies'};
            allowedPropsMsg = sprintf('Valid parameters for %s are:%s.', MatlabpoolHelper.OpenAction, sprintf(' %s', allowedProps{:}));
            % If matlabpool was called without open it is possible that the user
            % mis-typed the action, and we need to let them know the valid actions.
            if ~OPEN_ACTION_SUPPLIED
                openAssumedMsg = sprintf('You did not explicitly specify an action as the first argument to "matlabpool" so "%s" was assumed.', ...
                    MatlabpoolHelper.OpenAction);
                allowedPropsMsg = sprintf( '%s\n%s\n%s', allowedPropsMsg, openAssumedMsg, msgValidActions );
            end
            % Split inputs into "initial" and "P-V" args at first allowedProp
            initialArgs = {};
            pvArgs = {};
            % Since varargin is not a cellstr have to do this the long way.
            if any( strcmp( varargin{1}, allowedProps ) )
                pvArgs = varargin;
            elseif length( varargin ) > 1 && any( strcmp( varargin{2}, allowedProps ) )
                initialArgs = varargin(1);
                pvArgs = varargin(2:end);
            elseif length( varargin ) > 2
                initialArgs = varargin(1:2);
                pvArgs = varargin(3:end);
            else
               initialArgs = varargin;
            end

            % initialArgs has length 0, 1 or 2
            if length( initialArgs ) == 1
                if isnumeric( initialArgs{1} )
                    nlabs = initialArgs{1};
                else
                    nlabs = str2double( initialArgs{1} );
                    if ~isfinite( nlabs )
                        nlabs = [];
                        config = initialArgs{1};
                    end
                end
            elseif length( initialArgs ) == 2
                config = initialArgs{1};
                if isnumeric( initialArgs{2} )
                    nlabs = initialArgs{2};
                else
                    nlabs = str2double( initialArgs{2} );
                    % What if this didn't convert to a double
                    if ~isfinite( nlabs )
                        if ischar( initialArgs{2} ) 
                            err = MException( 'distcomp:matlabpool:InvalidInput',...
                                '"%s" is not a valid parameter at this location for "matlabpool %s". %s ', ...
                                initialArgs{2}, MatlabpoolHelper.OpenAction, allowedPropsMsg );
                        else
                            err = MException( 'distcomp:matlabpool:InvalidInput', ...
                                'Found invalid parameter for %s. %s',  MatlabpoolHelper.OpenAction, allowedPropsMsg );
                        end
                        throw(err);
                    end
                end
            end

            try
                [allProps, allValues] = parallel.internal.convertToPVArrays( pvArgs{:} );
            catch err
                newErr = MException( 'distcomp:matlabpool:InvalidInput', ...
                    'Found invalid parameter for %s. %s',  MatlabpoolHelper.OpenAction, allowedPropsMsg );
                newErr = newErr.addCause(err);
                throw(newErr);
            end

            for n = 1:length(allProps)
                thisProp = allProps{n};
                thisValue = allValues{n};
                switch thisProp 
                    case 'FileDependencies'
                        filedeps = thisValue;
                    otherwise
                        err = MException( 'distcomp:matlabpool:InvalidInput',...
                            '"%s" is not a valid parameter at this location for "matlabpool %s". %s', ...
                            thisProp, MatlabpoolHelper.OpenAction, allowedPropsMsg );
                        throw(err);
                end
            end
              
            if ~isempty(nlabs) && ~iIsIntegerScalar(nlabs, 1, realmax)
                err = MException('distcomp:matlabpool:InvalidInput', ...
                    'The pool size input to matlabpool must be a finite, positive, integer.');
                throw(err);
            end
        end    
        
        % -------------------------------------------------------------------------
        % parseCloseArgs
        % -------------------------------------------------------------------------
        % Parse the input arguments to matlabpool close.
        %   Varargin should be one of:
        %   {}, {config} {force}
        %   Return the configuration.  It is empty if not specified in the input.
        %   We perform no input checking on the configuration, but rely on the error
        %   messages from findResource.
        function [isForce, config] = parseCloseArgs(varargin)
            import parallel.internal.cluster.MatlabpoolHelper;
            if numel(varargin) > 2
                err = MException('distcomp:matlabpool:InvalidInput', ...
                    'matlabpool %s takes between zero and two string arguments.', ...
                    MatlabpoolHelper.CloseAction);
                throw(err);
            end
            config = '';
            isForce = false;
            % No input arguments is a normal close
            if nargin == 0
                return;
            end
            % OK - check that all inputs are row strings
            if ~all(cellfun(@ischar, varargin) & cellfun(@(C) size(C, 2), varargin) == cellfun(@numel, varargin))
                err = MException('distcomp:matlabpool:InvalidInput', ...
                    'matlabpool %s takes between zero and two string arguments', ...
                    MatlabpoolHelper.CloseAction);
                throw(err);
            end
            % The first string must be 'force'
            if ~strcmpi(varargin{1}, 'force')
                err = MException('distcomp:matlabpool:InvalidInput', ...
                    'Expected syntax is : ''matlabpool %s'' or  ''matlabpool %s force''. The string ''%s'' is not correct', ...
                    MatlabpoolHelper.CloseAction, MatlabpoolHelper.CloseAction, varargin{1});
                throw(err);
            end
            isForce = true;
            if nargin > 1
                config = varargin{2};
            end
        end
    end
    
    methods (Static, Access = protected) % Methods for generating errors
        % -------------------------------------------------------------------------
        % errorIfNotSingleCellString
        % -------------------------------------------------------------------------
        function errorIfNotSingleCellString(action, varargin)
            % Ensure only two inputs 
            error(nargchk(2, 2, nargin));
            % Get the cellstring - we know there is only one input
            cellOfStrings = varargin{1};
            % Check it is a cell that contains only strings
            if ~iscellstr(cellOfStrings)
                error('distcomp:matlabpool:InvalidArgument', ...
                    'The input to matlabpool %s must be a cell array of strings', action);
            end
        end

        % -------------------------------------------------------------------------
        % errorIfArgs
        % -------------------------------------------------------------------------
        function errorIfArgs(action, nargs)
            if nargs ~= 0
                error('distcomp:matlabpool:InvalidInput', ...
                    'matlabpool %s takes no arguments.', action);
            end
        end
        
        % -------------------------------------------------------------------------
        % errorIfNotOnClient
        % -------------------------------------------------------------------------
        function errorIfNotOnClient(action)
            if system_dependent('isdmlworker')
                error('distcomp:matlabpool:RunOnLabs', ...
                    'Cannot execute    matlabpool %s    on the labs.', action);
            end
        end    

        % -------------------------------------------------------------------------
        % getTransferError
        % -------------------------------------------------------------------------
        function err = getTransferError( messageObserver )
            % Get the transfer errors from this file send to see if we should
            % indicate something went wrong.
            transferErrors = messageObserver.getSourceAndTransferErrors.toArray;
            if isempty(transferErrors)
                err = '';
            else
                % Get all the transfer errors as strings in a cell array. This will
                % contain the ProcessInstance first and the Exception error message
                % second
                messages = cell(2, numel(transferErrors));
                for j = 1:numel(transferErrors)
                    % Get the char version of the ProcessInstance from the Pair
                    messages{1, j} = char(transferErrors(j).getFirst);
                    % Get the char version of the ProcessInstance from the Pair
                    messages{2, j} = char(transferErrors(j).getSecond.getMessage);
                end
                err = sprintf('\n%s: %s', messages{:});
            end
        end
    end
end

% -------------------------------------------------------------------------
% iIsIntegerScalar
% -------------------------------------------------------------------------
function valid = iIsIntegerScalar(value, lowerBound, upperBound)
%iIsIntegerScalar Check if input is a scalar integer within the specified
%bounds.
valid = iIsIntegerVector(value, lowerBound, upperBound) ...
    && isscalar(value);
end
% -------------------------------------------------------------------------
% iIsIntegerVector
% -------------------------------------------------------------------------
function valid = iIsIntegerVector(value, lowerBound, upperBound)
%iIsIntegerScalarVector Check if input is a vector of integers within the
%specified bounds.
valid = isnumeric(value) && isreal(value) && isvector(value) ...
    && all((value >= lowerBound)) ...
    && all(value <= upperBound) && ~any(isnan(value)) ...
    && all(fix(value) == value);
end
