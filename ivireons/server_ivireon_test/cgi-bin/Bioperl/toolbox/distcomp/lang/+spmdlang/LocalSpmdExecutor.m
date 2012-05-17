%%
% LocalSpmdExecutor - control class to manage local execution of an SPMD block

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $   $Date: 2009/05/14 16:50:15 $

classdef LocalSpmdExecutor < spmdlang.AbstractSpmdExecutor

    properties ( Access = private, Hidden )
        % We could be using the LocalSpmdExecutor on the workers, so we must store
        % the MPI_Comm value to revert to on leaving this SPMD block
        PreviousCommunicators;
        
        % If the block encountered an exception, store that here.
        BlockException = [];
    end
    
    methods
        
        function obj = LocalSpmdExecutor( resSetH, bodyF, assignOutF, getOutF, unpackInF, initialOuts )
        % Simulate transfer by going through serialize/deserialize cycle. This also
        % allows us to disallow hidden variant transfers.
            spmdlang.AbstractRemote.saveLoadCount( 'clear' );
            
            warnStates = spmdlang.AbstractSpmdExecutor.disableRemoteSaveWarnings();
            try
                transferred = distcompdeserialize( distcompserialize( { bodyF, getOutF, unpackInF } ) );
            catch E
                spmdlang.AbstractSpmdExecutor.restoreRemoteSaveWarnings( warnStates );
                rethrow( E );
            end
            spmdlang.AbstractSpmdExecutor.restoreRemoteSaveWarnings( warnStates );

            if spmdlang.AbstractRemote.saveLoadCount( 'get' ) ~= 0
                pOneHiddenCompositeWarning;
            end

            obj = obj@spmdlang.AbstractSpmdExecutor( resSetH, transferred{1}, assignOutF, ...
                                                     transferred{2}, transferred{3}, initialOuts );

            % If mpi is initialized already, we need to stash the communicator state.
            if mpiInitialized
                obj.PreviousCommunicators = mpiCommManip( 'queryState' );
            else
                obj.PreviousCommunicators = [];
            end
        end
        
        % For local execution, we actually perform all the computation here.
        function initiateComputation( obj )
        % Unpack the inputs and execute the block
            if mpiInitialized
                mpiCommManip( 'select', 'self' );
            end
            obj.UnpackInFcn( @spmdlang.AbstractSpmdExecutor.unpack );
            try
                feval( '_workspace_transparency', 1 );
                obj.BodyFcn();
                feval( '_workspace_transparency', 0 );
            catch cause
                feval( '_workspace_transparency', 0 );
                
                except = MException( 'distcomp:spmd:ExecutionError', ...
                                     'An error occurred during SPMD body execution' );
                except = pctAddRemoteCause( except, cause );
                
                % Stash this for later.
                obj.BlockException = except;
            end
        end
        
        function throwBlockExceptions( obj )
            if ~isempty( obj.BlockException )
                throw( obj.BlockException );
            end
        end

        function yes = isComputationComplete( obj ) %#ok<MANU>
        % All the work is done in "initiateComputation" for local execution, so simply return true.
            yes = true;
        end
        
        function dispose( obj )
            try
                if ~isempty( obj.PreviousCommunicators )
                    mpiCommManip( 'select', obj.PreviousCommunicators );
                end
                E = [];
            catch E
                % We'll throw this later.
            end

            % Set disposed to "true" now - we don't need to go through here again under
            % any circumstances.
            obj.Disposed = true;

            outCell = obj.GetOutFcn();
            outCellDeref = cell( 1, length( outCell ) );
            
            %% "LAB"-side
            % ii is which variable we're dealing with
            for ii=1:length( outCell )
                if isempty( outCell{ii} )
                    outCellDeref{ii}{1} = [];
                else
                    % During remote execution, this parcelling is done in remoteBlockBody
                    data = outCell{ii}{1};
                    key  = spmdlang.ValueStore.store( data );
                    [fcn, data] = getRemoteFromSPMD( data );
                    outCellDeref{ii}{1} = spmdlang.ReturnableParcel( key, fcn, data );
                end
            end

            obj.callAssignOuts( outCellDeref );
            % Error caught during comm manip reversal
            if ~isempty( E )
                rethrow( E );
            end
        end
    end
end
