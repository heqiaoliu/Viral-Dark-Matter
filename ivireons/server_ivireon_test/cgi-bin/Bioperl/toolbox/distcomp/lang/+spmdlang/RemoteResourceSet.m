% Remote resource set object - gateway to remote SPMD execution. Manages a
% cell array of MPI communicator handles, and a corresponding array of
% process objects and can build the appropriate SPMD block executor


% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $   $Date: 2009/03/25 21:54:45 $

classdef RemoteResourceSet < spmdlang.AbstractResourceSet

    properties ( SetAccess = private, Transient )
        % Cell array of remote communicator handles. (Might be strings or uint64s).
        RemoteCommCell;
        
        % Java array of process instances
        RemoteProcessArray;
    end
    
    properties ( Access = private, Transient )
        % Am I the current "world"
        IsWorld = false;
        
        % session object
        Session = [];
    end

    methods ( Access = public, Static )

        % This function exists mainly to support matlabpooljobs, where the effective
        % world isn't 'world'. 
        function x = getWorldCommsCell( nlabs )
            [wc, labIdFirst] = spmdlang.commForWorld( 'get' );
            
            % Need to pad the cell array so that the labs can index into it by their
            % "World" labindex.
            padCells = cell( 1, labIdFirst - 1 );
            
            if ischar( wc ) % probably 'world'
                x = repmat( {wc}, 1, nlabs );
            else
                x = wc;
            end
            x = [padCells, x]; % in matlabpooljob, this is e.g.: {[], 6, 6, 6}
        end
        
        % Bootstrap - this static method builds the "world" set from the pool, and
        % requires no communication or remote execution to achieve that.
        function worldSet = buildWorldSet()
            [ps, sess] = spmdlang.ResourceSetMgr.poolSize();
            if ps == 0
                error( 'distcomp:spmd:NoSession', ...
                       ['An unexpected attempt was made to build a remote', ...
                        ' SPMD resource set with no matlabpool'] );
            end
            worldSet = spmdlang.RemoteResourceSet( ...
                1:ps, spmdlang.RemoteResourceSet.getWorldCommsCell( ps ), sess );
            
            worldSet.IsWorld = true;
        end
    
    end
    
    methods ( Access = public, Hidden )
        function obj = RemoteResourceSet( processIndices, remoteCommCell, session )
            obj = obj@spmdlang.AbstractResourceSet( length( processIndices ) );
            obj.RemoteCommCell = remoteCommCell;
            
            % Build the process instance array from the "labindex" vector.
            import com.mathworks.toolbox.distcomp.pmode.shared.ProcessInstance;
            allLabs = ProcessInstance.getAllLabs( max( processIndices ) );
            obj.RemoteProcessArray = allLabs( processIndices );
            obj.Session = session;
        end
        
        % "Factory method" to build a remote resource set of a specific size from the
        % open pool. It does that by splitting the base set. 
        % "sz" is simply the required size of the subset
        function subSetObj = buildRemoteResourceSet( obj, sz )
            
            if sz == obj.numlabs
                subSetObj = obj;
            elseif sz < obj.numlabs

                % Build from the base set, 
                newComms = spmd_feval_fcn( @iBuildCommHandle, { sz }, obj );

                % Pad as necessary to handle mismatch between MPI 'world' labindex and
                % processes. (Happens in matlabpool jobs)
                [junk, labIdFirst] = spmdlang.commForWorld( 'get' );
                padCells = cell( 1, labIdFirst - 1 );
                newComms = {padCells{:}, newComms{:}}; %#ok<CCAT> Dereference the Composite returned from the spmd_feval_fcn
                
                subSetObj = spmdlang.RemoteResourceSet( 1:sz, newComms(:), obj.Session );
            else
                % Should never get here because there's already a check that will not let us
                % build a resource set greater than the size of the base set
                error( 'distcomp:spmd:InvalidResourceSelection', ...
                       ['An unexpected attempt to build a resource set of size %d \n', ...
                        'was made.'], sz );
            end
        end

        
        function tf = isValid( obj )
            tf = obj.Session.isSessionRunning();
        end
        
        function tf = canAccessLabs( obj )
            % Need to test if we are allowed to access the lab and ask it
            % to do and operation - currently this is simply the same as
            % asking are we in parallel_function but might become much more
            % complex in the future when labs (MUE's) have actual
            % allocation undertaken.
            if obj.isValid()
                tf = internal.matlab.getParallelFunctionDepth == 0;
            else
                tf = false;
            end
        end
        
        function tf = satisfiesConstraints( obj, minN, maxN )
            obj.errorIfInvalid();
            tf = ( obj.numlabs <= maxN && obj.numlabs >= minN );
        end
        
        function val = getFromLab( obj, labidx, key )
        % Talk to the lab, get the value
            obj.errorIfInvalid();

            % Make sure we can detect transfer of Remote objects
            spmdlang.AbstractRemote.saveLoadCount( 'clear' );

            val = remoteRetrieval( obj, obj.RemoteProcessArray( labidx ), key );

            if spmdlang.AbstractRemote.saveLoadCount( 'get' ) ~= 0
                warning( 'distcomp:RemoteTransfer:RemoteObjectSentToLabs', ...
                         ['A distributed array or Composite was retrieved from the labs. This object will be ', ...
                          'unusable.'] );
            end
        end
        
        function newKey = setOnLab( obj, labidx, newValue )
        % Talk to the lab, send the value, retrieve the key
            obj.errorIfInvalid();

            % Make sure we can detect transfer of Remote objects
            spmdlang.AbstractRemote.saveLoadCount( 'clear' );

            newKey = remoteSet( obj, obj.RemoteProcessArray( labidx ), newValue );

            if spmdlang.AbstractRemote.saveLoadCount( 'get' ) ~= 0
                warning( 'distcomp:RemoteTransfer:RemoteObjectSentToLabs', ...
                         ['A distributed array or Composite was sent to the labs. This object will be ', ...
                          'unusable.'] );
            end
        end
        
        function keyUnreferenced( obj, labidx, key )
        % Push the key onto the stack of things to clear for the particular lab -
        % don't worry if we're not valid (that means the lab has probably
        % gone away)
            if isValid( obj )
                remoteClear( obj, obj.RemoteProcessArray( labidx ), key );
            end
        end
        
        function blockEx = buildBlockExecutor( obj, bodyFcn, assignOutFcn, getOutFcn, ...
                                               unpackInFcn, initialOuts )
            obj.errorIfInvalid();
            blockEx = spmdlang.RemoteSpmdExecutor( spmdlang.ResourceSetHolder( obj ), ...
                                                  bodyFcn, assignOutFcn, getOutFcn, ...
                                                  unpackInFcn, initialOuts, obj.Session );
        end
        
        function invalidate( obj, labsStillAvailable )
            if ~obj.IsWorld && labsStillAvailable
                % Use SPMD itself to release the communicators
                spmd_feval_fcn( @iFreeMyComm, {}, obj );
            end
            % Finally, call the superclass invalidation
            invalidate@spmdlang.AbstractResourceSet( obj, labsStillAvailable );
        end
    end
    
    %% Methods to do with Remote retrieval
    methods ( Access = private, Hidden )
        function errorIfSessionClosed( obj )
            if ~obj.Session.isSessionRunning()
                error( 'distcomp:spmd:NoSession', ...
                       'The matlabpool session being used by SPMD has been closed' );
            end
        end
        
        function val = remoteRetrieval( obj, remoteProc, key )
            import java.util.concurrent.TimeUnit;
            obj.errorIfSessionClosed();

            obs = obj.Session.getCompositeAssistant.retrieveCompositeValue( remoteProc, ...
                                                              distcompserialize( key ) );
            
            % Note that disposing the observer frees the byte buffers
            x = onCleanup( @()(obs.dispose()) );
            while ~obs.await( 100, TimeUnit.MILLISECONDS );
                % Allow CTRL-C out of lengthy retrieval. The bytebuffer will be disposed of
                % immediately.
                obj.errorIfSessionClosed();
            end
            
            result = obs.getResult().getResult();
            thing  = distcompdeserialize( distcompByteBuffer2MxArray( result(2).get ) );
            % Also note - don't call "free" here since the observer will do that for me.
            if logical( result(1) )
                val = thing;
            else
                except = thing;
                ME = MException( 'distcopm:spmd:RemoteRetrievalError', ...
                                 'An error occurred during remote data retrieval' );
                ME = addCause( ME, except );
                throw( ME );
            end
        end
        
        function newKey = remoteSet( obj, remoteProc, newValue )
            import java.util.concurrent.TimeUnit;
            obj.errorIfSessionClosed();
            
            rca = obj.Session.getCompositeAssistant;
            
            bbufh = distcompMakeByteBufferHandle( distcompserialize( newValue ) );
            obs = rca.sendCompositeValue( remoteProc, bbufh );
            
            % Free the byte buffer handle immediately - the java layer has already taken
            % its copy, and will free that
            bbufh.free;
            
            % Note that disposing the observer frees the byte buffer
            x = onCleanup( @()(obs.dispose()) );
            while ~obs.await( 100, TimeUnit.MILLISECONDS );
                % Allow CTRL-C out of lengthy set. 
                obj.errorIfSessionClosed();
            end
            
            result = obs.getResult().getResult();
            thing  = distcompdeserialize( distcompByteBuffer2MxArray( result(2).get ) );
            if logical( result(1) )
                newKey = thing;
            else
                except = thing;
                ME = MException( 'distcomp:spmd:RemoteSet', ...
                                 'An error occurred during remote data storage' );
                ME = addCause( ME, except );
                throw( ME );
            end
        end

        function remoteClear( obj, remoteProc, key )
            obj.errorIfSessionClosed();
            import com.mathworks.toolbox.distcomp.pmode.RemoteCompositeAssistant;
            obj.Session.getCompositeAssistant.notifyRemoteClear( remoteProc, key );
        end
    end
    
end

% Used by RemoteResourceSet::invalidate on the labs to free a given communicator.
function iFreeMyComm()
    % Use a special back-door to free communicators - the block cleanup needs to
    % use them for error checking.
    spmdlang.remoteBlockExecution( 'doFreeComm' );
end

% Used by RemoteResourceSet::buildRemoteResourceSet to split the world communicator.
function val = iBuildCommHandle( newSz )
    if newSz > numlabs
        % Should never get here - two layers of previous checks would have to fail
        % to catch this...
        error( 'distcomp:spmd:InvalidComms', ...
               ['An unexpected attempt was made to build an MPI communicator\n', ...
                'of size %d when the current value of numlabs is %d'], ...
               newSz, numlabs );
    end
    
    % All labs <= labindex get colour 1, others get colour -1 (so they get COMM_NULL)
    colour = (2 * double(labindex <= newSz)) - 1;
    key    = labindex;
    
    val    = mpiCommManip( 'split', colour, key );
end



