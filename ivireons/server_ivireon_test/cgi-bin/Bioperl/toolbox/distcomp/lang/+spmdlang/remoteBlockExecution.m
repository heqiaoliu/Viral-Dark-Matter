function [OK, out] = remoteBlockExecution( action, varargin )
%remoteBlockExecution - this function controls the SPMD block execution on the labs

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2009/03/25 21:54:48 $
    
    persistent EXECUTION_HANDLES BLOCK_COMM_HANDLE PREVIOUS_COMM_HANDLE FREE_COMM_ON_CLEANUP PRELUDE_EXCEPTION
    % EXECUTION_HANDLES    - stores the deserialized function handles sent across from the client
    % BLOCK_COMM_HANDLE    - the communicator handle used in the context of this SPMD block
    % PREVIOUS_COMM_HANDLE - the communicator handle in use outside this SPMD context
    % FREE_COMM_ON_CLEANUP - boolean flag to indicate whether or not we should free the block's communicator
    % PRELUDE_EXCEPTION    - MException thrown during prelude phase, if any.
    
    mlock;
    
    out = [];
    
    try
        switch action
          case 'prelude'
            % Grab the world labindex before we go any further.
            PREVIOUS_COMM_HANDLE = mpiCommManip( 'select', 'world' );
            worldLabIndex = labindex;
            mpiCommManip( 'select', PREVIOUS_COMM_HANDLE );
            
            % Set up defaults in case iPrelude errors out
            FREE_COMM_ON_CLEANUP = false;
            BLOCK_COMM_HANDLE = [];
            EXECUTION_HANDLES = [];
            PRELUDE_EXCEPTION = [];
            
            try
                [EXECUTION_HANDLES, BLOCK_COMM_HANDLE] = iPrelude( worldLabIndex, varargin{:} );
            catch E
                % Stash the exception - we'll throw this from interruptibleExecution
                PRELUDE_EXCEPTION = E;
                % Reset to the original communicator.
                mpiCommManip( 'select', PREVIOUS_COMM_HANDLE );
                rethrow( PRELUDE_EXCEPTION );
            end
          case 'interruptibleExecution'
            % In this case, we expect interruption, and so do not rely on modifying any
            % of the persistent data.
            if ~isempty( EXECUTION_HANDLES )
                bodyFcn = EXECUTION_HANDLES{1};

                feval( '_workspace_transparency', 1 );
                bodyFcn();
                feval( '_workspace_transparency', 0 );

                % Always call setidle here - if we've got this far, we know it's safe, and
                % it just might speed an error-exit.
                mpigateway( 'setidle' );
            else
                % Don't even try to execute the block
                if ~isempty( PRELUDE_EXCEPTION )
                    rethrow( PRELUDE_EXCEPTION );
                else
                    error( 'distcomp:spmd:PreludeError', ...
                           'An unknown error occurred during block setup.' );
                end
            end
          case 'postlude'
            % Always call setidle here - we may not have hit it because of error or
            % interruption during the body.
            mpigateway( 'setidle' );

            if ~isempty( EXECUTION_HANDLES )
                getOutFcn = EXECUTION_HANDLES{2};
                out = iPackOutputs( getOutFcn() );
                iDeadlockDetection( BLOCK_COMM_HANDLE, PREVIOUS_COMM_HANDLE, FREE_COMM_ON_CLEANUP );
            else
                % No block execution - bad setup
                out = distcompserialize( [] );
            end
          case 'doFreeComm'
            FREE_COMM_ON_CLEANUP = true;
        end
        OK = true;
    catch E
        OK = false;
        out = distcompserialize( E );
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fcnHandles, commHandle] = iPrelude( worldLabIndex, serCommHandleCell, ...
                                              serializedFcnHandles, arrayHolderToClear )
    pctPreRemoteEvaluation( 'mwmpi' );

    % Clear any keys that are no longer in use
    pClearIfNecessary( arrayHolderToClear );

    % Unpack the data we've been given
    [commHCell, fcnHandles, loadedRemote, functionNotFound] = ...
        iDeserializeInputs( serCommHandleCell, serializedFcnHandles );
    
    % Set up the communicators
    commHandle = iSelectCommunicator( worldLabIndex, commHCell );
    
    % If anything that was transferred was a Remote, set up an error message
    if loadedRemote
        %%% Already warned on client, don't do anything here.
    elseif functionNotFound
        error( 'distcomp:spmd:SourceCodeNotAvailable', ...
               'Lab %d unable to find file.', labindex );
    end
    
    % Unpack the inputs for later
    unpackInFcn = fcnHandles{3};
    unpackInFcn( @spmdlang.AbstractSpmdExecutor.unpack );
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iSelectCommunicator - deal with setting the communicator
function myComm = iSelectCommunicator( worldLabIndex, commHCell )

    myComm = commHCell{worldLabIndex};
    if ~mpiCommManip( 'isValid', myComm )
        % This ought to be a fatal error, as we can't recover (OTOH, I've never hit
        % this...)
        % XXX TODO MPI abort?
        error( 'distcomp:spmd:BadCommunicator', ....
               'An invalid communicator was supplied for remote execution.' );
    else
        mpiCommManip( 'select', myComm );
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iDeserializeInputs - unpack everything sent over, and return along with a
% flag indicating whether any Remote type objects were sent.
function [commHCell, fcnHandles, loadedRemote, functionNotFound] = iDeserializeInputs( serCommHandleCell, serializedFcnHandles )
    state = [];
    try
        commHSerMx = distcompByteBuffer2MxArray( serCommHandleCell.get );
        commHCell = distcompdeserialize( commHSerMx );
        
        spmdlang.AbstractRemote.saveLoadCount( 'clear' );

        state = warning('off', 'MATLAB:dispatcher:UnresolvedFunctionHandle');
        [lastMsg, lastID] = lastwarn('');
        
        fcnHandlesSerMx = distcompByteBuffer2MxArray( serializedFcnHandles.get );
        fcnHandles = distcompdeserialize( fcnHandlesSerMx );
        
        % Check lastwarn to see if the function was not found?
        [aMsg, anID] = lastwarn;
        functionNotFound = strcmp(anID, 'MATLAB:dispatcher:UnresolvedFunctionHandle');
        % Reset the lastwarn and warning state 
        lastwarn(lastMsg, lastID);
        E = [];
    catch E
        % E will be rethrown later.
    end
    
    if ~isempty( state )
        warning( state );
    end
    
    % Always free these to prevent memory leaks:
    serCommHandleCell.free;
    serializedFcnHandles.free;
    
    % Throw an error if we've got one.
    if ~isempty( E ), rethrow( E ); end
    
    loadedRemote = ( spmdlang.AbstractRemote.saveLoadCount( 'get' ) ~= 0 );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iPackOutputs - pack up and return the body outputs
function out = iPackOutputs( getOutFcn )
    outCell = getOutFcn();
    outCellParcel = cell( 1, length( outCell ) );
    for ii=1:length( outCell )
        try
            if isempty( outCell{ii} )
                % Do nothing - cell already empty
            else
                data = outCell{ii}{1};
                key = spmdlang.ValueStore.store( data );
                [fcn, data] = getRemoteFromSPMD( data );
                outCellParcel{ii} = spmdlang.ReturnableParcel( key, fcn, data );
            end
        catch E
            warning( 'distcomp:spmd:SpmdOutputs', ...
                     ['An error was thrown while attempting to return SPMD \n', ...
                      'block outputs from the labs: %s'], ...
                     getReport( E ) );
        end
    end
    out = distcompserialize( outCellParcel );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iDeadlockDetection - perform deadlock detection postlude stage
function iDeadlockDetection( blockComm, prevComm, freeBlockComm )
    try
        mpiCommManip( 'select', blockComm );
        mpigateway( 'setidle' );
        mpigateway( 'setrunning' );
    catch E %#ok
            % Ignore
    end
    
    % Unconditionally reset parfor_depth, as we do for PMODE (in
    % distcomp.pInterPPromptFcn)
    parfor_depth( 0 );
    
    mpiCommManip( 'select', prevComm );
    
    if freeBlockComm
        mpiCommManip( 'free', blockComm );
    end
end
