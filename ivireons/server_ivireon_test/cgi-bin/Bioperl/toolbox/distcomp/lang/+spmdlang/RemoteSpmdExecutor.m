% RemoteSpmdExecutor - control class to manage remote execution of an SPMD
% block This class manages the M side of dealing with the Java controller,
% and in particular attempts to deal correctly with M-side interrupts.

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.8 $   $Date: 2009/07/18 15:50:31 $

classdef RemoteSpmdExecutor < spmdlang.AbstractSpmdExecutor

    properties ( Access = private, Hidden, Transient )
        % The java controller
        RemoteSpmdController;
        % An array of processes
        RemoteProcessArray;
        % A cell array of communicators for those processes
        RemoteCommCell;
        % The java session object
        Session;
        % Flag to indicate whether we have sent the block for execution
        SentBlockToLabs = false;
        % Stash how many output arguments to expect (can't access superclass data in destructor)
        SpmdNargout = 0;

        % Have we warned about the interrupt yet?
        WarnedAboutError = false;
        % Time at which we first spotted there was an error - we don't warn for a while
        TimeErrorFirstSeen = [];
    end
    
    properties ( GetAccess = private, Constant )
        % This is the timeout after noticing that a lab has encountered an error
        % (and therefore sending an interrupt) before we warn the users.
        TIMEOUT_BEFORE_WARNING_ABOUT_ERROR = 5; % seconds
    end

    methods ( Access = private, Hidden )
        function errorIfNoSession( rse )
        % Method used to bail out of various situations if we discover that the
        % session has shut down.
            if ~rse.Session.isSessionRunning()
                error( 'distcomp:spmd:SessionNotRunning', ...
                       'The matlabpool session that SPMD is using has shut down' );
            end
        end
    end

    methods

        function obj = RemoteSpmdExecutor( resSetH, bodyF, assignOutF, getOutF, unpackInF, initialOuts, session )

        % assert that we've got a remote resource set
            resSet = resSetH.getResourceSet();
            if ~isa( resSet, 'spmdlang.RemoteResourceSet' )
                error( 'distcomp:spmd:RemoteInconsistency', ...
                       ['An unexpected attempt was made to use a remote SPMD executor with\n', ...
                        'an invalid parallel resource set'] );
            end

            % Build the parent class - manages the closures/
            obj = obj@spmdlang.AbstractSpmdExecutor( resSetH, bodyF, assignOutF, ....
                                                     getOutF, unpackInF, initialOuts );

            % Build the java controller which will actually do the work
            obj.RemoteSpmdController = buildController( resSet.RemoteProcessArray, session );
            obj.RemoteProcessArray   = resSet.RemoteProcessArray;
            obj.RemoteCommCell       = resSet.RemoteCommCell;

            % stash the session
            obj.Session              = session;
            
            obj.SpmdNargout          = length( initialOuts );
        end


        function initiateComputation( obj )
            % Make sure we can detect save/load of Remote objects
            spmdlang.AbstractRemote.saveLoadCount( 'clear' );

            % Serialize communicator handles and function handles for transmission
            comms = distcompMakeByteBufferHandle( ...
                distcompserialize( obj.RemoteCommCell ) );
            
            warnStates = spmdlang.AbstractSpmdExecutor.disableRemoteSaveWarnings();
            try
                fcns  = distcompMakeByteBufferHandle( ...
                    distcompserialize( { obj.BodyFcn, obj.GetOutFcn, obj.UnpackInFcn } ) );
            catch E
                spmdlang.AbstractSpmdExecutor.restoreRemoteSaveWarnings( warnStates );
                rethrow( E );
            end
            spmdlang.AbstractSpmdExecutor.restoreRemoteSaveWarnings( warnStates );
            
            % Was the serialization OK?
            if spmdlang.AbstractRemote.saveLoadCount( 'get' ) ~= 0
                pOneHiddenCompositeWarning;
            end

            % Actually initiate the remote computation
            obj.RemoteSpmdController.initiateRemoteSpmdBlock( comms, fcns );
            comms.free;
            fcns.free;

            % Remember that we did actually send stuff - see delete()
            obj.SentBlockToLabs = true;
        end

        function tf = isComputationComplete( obj )
            obj.errorIfNoSession();

            % Simply query with a shortish timeout
            import java.util.concurrent.TimeUnit;
            tf = obj.RemoteSpmdController.awaitBlock( 200, TimeUnit.MILLISECONDS );

            % Take the opportunity to drain IO here - "false" because we expect to call
            % this again.
            obj.RemoteSpmdController.drainIO( false );

            obj.maybeWarnIfInterruptedAndWaiting();
        end

        function throwBlockExceptions( obj )
            % Look through what we received from executing the block, see if there are
            % any errors to throw.

            if ~obj.SentBlockToLabs
                % Can't possibly be in error.
                return;
            end

            % Retrieve the exceptions from the controller
            nlabs      = length( obj.RemoteProcessArray );
            excepts    = {};
            exceptLabs = [];

            for lab = 1:nlabs
                % get the FevalResult corresponding to remoteBlockBody
                result = obj.RemoteSpmdController.getBlockResult( obj.RemoteProcessArray( lab ) );
                if result.isError()
                    if ~isempty( result.getException() )
                        thisExcept        = distcompdeserialize( result.getException() );
                        excepts{end+1}    = obj.maybeTransformMissingSourceException( thisExcept ); %#ok<AGROW>
                        exceptLabs(end+1) = lab; %#ok<AGROW>
                    else
                        % Assumption is that this is an interrupted lab, don't report that.
                    end
                end
            end

            if ~isempty( excepts )
                labsStr = sprintf( '%d ', exceptLabs );
                labsStr = labsStr(1:end-1);
                except  = MException( 'distcomp:spmd:ExecutionError', ...
                                      'Error detected on lab(s) %s', labsStr );
                for ii=1:length( excepts )
                    except = pctAddRemoteCause( except, excepts{ii} );
                end
                throwAsCaller( except );
            end
        end

        function dispose( obj )
            
            % If we didn't even send the block to the labs, get out of here
            if ~obj.SentBlockToLabs
                if ~isempty( obj.RemoteSpmdController )
                    obj.RemoteSpmdController.dispose();
                end
                return;
            end

            if obj.Disposed
                return;
            end
            
            import java.util.concurrent.TimeUnit;

            % Stash the controller to (try to) ensure we dispose of it however we leave
            % this delete() method.
            cleanupHelper( obj.RemoteSpmdController );
            x = onCleanup( @cleanupHelper );

            % Set disposed to true - we don't need to go through here again.
            obj.Disposed = true;
            
            % First, we must ascertain whether or not we completed correctly.
            if ~obj.isComputationComplete()
                % The client must have hit CTRL-C or similar - send the interrupt to the labs
                obj.RemoteSpmdController.interrupt();
                
                % carry on waiting - for the block + interrupts to complete. If the user
                % gets bored, they might keep hitting CTRL-C, but the Java
                % layer will continue.
                while ~obj.isComputationComplete()
                    % Wait for the interrupt to take its course
                    obj.errorIfNoSession();
                end
            end

            % Normal completion, attempt to retrieve output arguments - long timeout, as
            % we're not doing anything really useful.
            while ~obj.RemoteSpmdController.awaitCleanup( 1000, TimeUnit.MILLISECONDS )
                % Wait a while
                obj.errorIfNoSession();
            end

            % Retrieve the deserialized parcels
            [deserParcels, E] = obj.extractReturnParcels();

            obj.RemoteSpmdController.drainIO( true );

            % Let the controller know that we're done with it.
            %obj.RemoteSpmdController.dispose();
            obj.callAssignOuts( deserParcels );

            % Now that we've overwritten the old values, flush any remotes - this makes
            % a remote call to remoteClear - but only on those labs that need it.
            obj.RemoteSpmdController.initiateKeyFlush();
            while ~obj.RemoteSpmdController.awaitKeyFlush( 1000, TimeUnit.MILLISECONDS )
                % Wait a while
                obj.errorIfNoSession();
            end
            obj.handleKeyFlushErrors();
            
            % Throw any errors relating to calling the cleanup method.
            if ~isempty( E )
                throw( E );
            end
        end
    end

    methods ( Access = private )
        
        function maybeWarnIfInterruptedAndWaiting( obj )
        % If an error has occurred on the labs, warn the users if we've been waiting
        % a long time for the labs to come back.
            
            if obj.WarnedAboutError
                % Seen an error, already warned about it, get out of here
                return;
            end
            
            if isempty( obj.TimeErrorFirstSeen )
                % Haven't seen an error, let's check
                proc = obj.RemoteSpmdController.getProcessCausingInterrupt();
                if ~isempty( proc )
                    obj.TimeErrorFirstSeen = clock();
                end
                % Can't possibly be time to warn, so get out of here
                return;
            end
            
            % Have seen an error - we must be in possession of a TimeErrorFirstSeen - was
            % it long enough ago for us to warn?
            if ( etime( clock(), obj.TimeErrorFirstSeen ) >= ...
                 spmdlang.RemoteSpmdExecutor.TIMEOUT_BEFORE_WARNING_ABOUT_ERROR ) 
                
                % Ensure we don't come back through
                obj.WarnedAboutError = true;
                
                % Get the information from the SpmdControllerImpl about the exception
                proc = obj.RemoteSpmdController.getProcessCausingInterrupt();
                msg = obj.RemoteSpmdController.getMessageCausingInterrupt();
                
                if ~isempty( msg ) && ~isempty( proc ) ...
                        && msg.isError() && ~isempty( msg.getException() )
                    % Got a real error
                    except = distcompdeserialize( msg.getException() );
                    
                    % Transform the error message
                    except = pctTransformRemoteException( except );
                    
                    warning( 'distcomp:spmd:WaitingForBlockInterruption', ...
                             ['An error has occurred during SPMD execution. An attempt has been made ', ...
                              'to interrupt execution on the labs. If this situation persists, ', ...
                              'it may be necessary to interrupt execution using CTRL-C and then ', ...
                              'restarting the matlabpool.\n\n', ....
                              'The error that occurred on lab %d is: \n%s\n'], ...
                             double( proc.getLabIndex() ), ...
                             except.getReport() );
                end
            end
        end


        function E = maybeTransformMissingSourceException( obj, origE )
        % If the lab threw a SourceCodeNotAvailable exception, transform that to
        % describe the source code that wasn't found.
            if strcmp( origE.identifier, 'distcomp:spmd:SourceCodeNotAvailable' )
                % Get the function info from our stashed body function
                info = functions( obj.BodyFcn );
                E    = MException( 'distcomp:spmd:SourceCodeNotAvailable', ...
                                   ['The source code (%s) \nfor the SPMD block that is trying to execute '...
                                    'on the worker could not be found'], info.file);
                E    = addCause( E, origE );
            else
                % No transformation
                E = origE;
            end
        end
        
        function handleKeyFlushErrors( obj )
        % dig through to see if anything bad happened during the remote call to remoteClear
            nlabs = length( obj.RemoteProcessArray );
            for lab = 1:nlabs
                % FevalResult corresponding to remoteClear
                res = obj.RemoteSpmdController.getKeyFlushResult( ...
                    obj.RemoteProcessArray( lab ) );
                if isempty( res )
                    % Nothing happened
                else
                    actResult = res.getResult();
                    if ~logical( actResult(1) )
                        except = distcompdeserialize( res(2) );
                        warning( 'distcomp:spmd:RemoteKeyFlush', ...
                                 'An error was detected on lab %d during remote data clearing: \n%s', ...
                                 getReport( except ) );
                    end
                end
            end
        end
        
        function [deserParcels, E] = extractReturnParcels( obj )
        % Process the results of the cleanup - return the parcels, and an error that
        % we think ought to be thrown.
            
            nlabs = length( obj.RemoteProcessArray );
            E     = [];
            
            % Pre-allocate the return:
            deserParcels = cell( 1, obj.SpmdNargout );
            for argout = 1:obj.SpmdNargout
                deserParcels{argout} = cell( 1, nlabs );
            end
            
            for lab = 1:nlabs
                % Retrieve FevalResult corresponding to remoteBlockCleanup
                res = obj.RemoteSpmdController.getCleanupResult( ...
                    obj.RemoteProcessArray( lab ) );

                if isempty( res )
                    resultOk = false;
                else
                    res = res.getResult;
                    resultOk = logical(res(1));
                end

                if resultOk
                    thisLabsReturn = distcompdeserialize( res(2) );
                    if ~iscell( thisLabsReturn ) || isempty( thisLabsReturn )
                        % If thisLabsReturn is completely empty - this means that the lab didn't
                        % execute any of the lines needed to produce
                        % output. If it's not even a cell, then the
                        % remoteBlockBody>iStashOutputs didn't get called.
                    else
                        for argout = 1:obj.SpmdNargout
                            deserParcels{argout}{lab} = thisLabsReturn{argout};
                        end
                    end
                else
                    E = obj.handleBadCleanupResult( E, res, lab );
                end
            end
        end

        function E = handleBadCleanupResult( obj, E, res, lab ) %#ok<MANU>
        % Called during extractReturnParcels() to handle an FevalResult object
        % returned from a lab which indicates problems
            if isempty( E )
                E = MException( 'distcomp:spmd:RemoteCleanup', ...
                                'An error occurred during the cleanup following remote execution' );
            end
            if isempty( res )
                % This is really serious - there was no remoteBlockCleanup return from the
                % lab, which may mean that the matlabpool is stuck.
                E = addCause( E, MException( 'distcomp:spmd:RemoteCleanup', ...
                                             'No cleanup return was received from lab %d', ...
                                             lab ) );
            else
                try
                    if ~logical( res(1) )
                        E = addCause( E, distcompdeserialize( res(2) ) );
                    end
                catch EE
                    E = addCause( E, EE );
                end
            end
        end

    end
end

function cleanupHelper( obj )
    persistent objStash
    if nargin == 1
        objStash = obj;
    else
        objStash.dispose();
        objStash = [];
    end
end

function ctrl = buildController( procArray, session )
    try
        ctrl = session.createSpmdController();
        ctrl.acquireLabs( procArray );
    catch E
        [isJE, type] = isJavaException( E );
        if isJE && isequal( type, 'com.mathworks.toolbox.distcomp.pmode.CannotAcquireLabsException' )
            % We're pretty sure what went wrong, so don't add the underlying exception
            % as a cause.
            except = MException( 'distcopm:spmd:NoLabsAvailable', ...
                                 ['No labs from the matlabpool were available for remote execution.', ...
                                'This could be because a previous SPMD block or PARFOR loop failed to complete correctly ', ...
                                'and was interrupted. If this problem persists, you may need to restart the ', ...
                                'matlabpool.'] );
            
        else
            except = MException( 'distcomp:spmd:SpmdCreationError', ...
                                 ['An error occurred during setup for SPMD execution.', ...
                                'If this problem persists, you may need to restart the\n', ...
                                'matlabpool.'] );
            except = addCause( except, E );
        end
        throw( except );
    end
end
