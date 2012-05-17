% Base SPMD executor class - encapsulates local and remote common
% functionality. This mostly involves stashing the related function handles,
% and the inputs and outputs. It also defines the public interface for the executor

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $   $Date: 2009/05/14 16:50:14 $

classdef AbstractSpmdExecutor < handle
    properties ( Access = protected, Hidden )
        % Whether or not dispose() has been called
        Disposed = false;
        
        % A resource set holder - we need the resource set to persist while we execute the block
        ResourceSetHolder;
        
        % The 3 related function handles:
        BodyFcn;     % The body of the SPMD block
        GetOutFcn;   % Call this to return the block outputs
        UnpackInFcn; % Call this to unpack the inputs for BodyFcn

        % Call this with the output values from the SPMD block
        AssignOutFcn;
        
        % A cell array containing either {value} or [] if one of the output values
        % had a pre-existing client-side value.
        InitialOutCell;
    end
    
    properties ( GetAccess = private, Constant )
        % A list of warning identifiers to suppress around the serialization of
        % remote execution function handles.
        RemoteSerializationWarningsToSuppress = { 'distcomp:spmd:CompositeSave', ...
                            'distcomp:spmd:DistributedSave' };
    end

    methods ( Abstract )
        % Called by spmd_feval when it's time to start running
        initiateComputation( obj );
        
        % Polled by spmd_feval - it's acceptable to block for a short while.
        tf = isComputationComplete( obj );
        
        % spmd_feval gives the opportunity to throw exceptions that result from
        % block body execution.
        throwBlockExceptions( obj );
        
        % Call assign outputs from here
        dispose( obj );
    end
    
    methods ( Access = protected, Hidden )
        
        function obj = AbstractSpmdExecutor( resSetH, bodyF, assignOutF, getOutF, unpackInF, initialOuts )
            obj.ResourceSetHolder = resSetH;
            obj.BodyFcn           = bodyF;
            obj.AssignOutFcn      = assignOutF;
            obj.GetOutFcn         = getOutF;
            obj.UnpackInFcn       = unpackInF;
            obj.InitialOutCell    = initialOuts;
        end
        
        
        % Common code path for calling the assign-outputs code with a bunch of
        % serialized return parcels.

        % deserReturnParcels is a cell array of length of the number of output
        % arguments. Each element in that cell array is a cell array of
        % length numlabs
        function callAssignOuts( obj, deserReturnParcels )

            resSet = obj.ResourceSetHolder.getResourceSet();
            nlabs  = resSet.numlabs;
            remotesToAssign = cell( 1, length( deserReturnParcels ) );

            % Loop over return parcels, and unpack them.
            buildExceptions = {};
            for ii=1:length( deserReturnParcels )
                try
                    remotesToAssign{ii} = spmdlang.AbstractSpmdExecutor.buildComposite( deserReturnParcels{ii}, ...
                                                                      nlabs, resSet, ...
                                                                      obj.InitialOutCell{ii} );
                catch E
                    buildExceptions{end+1} = E; %#ok<AGROW> - we don't expect to grow these
                                                % arrays much, and only in
                                                % exceptional circumstances
                    
                    % Build an invalid composite to return
                    remotesToAssign{ii} = {spmdlang.InvalidRemote};
                    
                    % If we didn't build a particular output, we should make sure that it gets
                    % freed here by directly informing the resource set that
                    % the key should be freed.
                    for jj = 1:length( deserReturnParcels{ii} )
                        if ~isempty( deserReturnParcels{ii}{jj} )
                            resSet.keyUnreferenced( jj, getKey( deserReturnParcels{ii}{jj} ) );
                        end
                    end
                end
            end
            
            % Call the AssignOutFcn with the unpacked output values. These will all be
            % some type of Remote.
            try
                obj.AssignOutFcn( remotesToAssign{:} );
            catch E %#ok<NASGU>
                % Swallow. Get here if something went bad during block execution, and we
                % don't have enough results to supply.
            end
            
            % After assigning what we can, throw an exception if necessary
            if ~isempty( buildExceptions )
                E = MException( 'distcomp:spmd:buildError', ...
                                'An error occurred building remote objects on return from an SPMD block' );
                for ii=1:length( buildExceptions )
                    E = addCause( E, buildExceptions{ii} );
                end
                throw( E );
            end

        end

        % Destructor for AbstractSpmdExecutor ensures that dispose() is called on
        % the actual executor. It is the subclasses responsibility to ensure
        % that dispose() is idempotent, using the Disposed flag.
        function delete( obj )
            if ~obj.Disposed
                dispose( obj );
            end
        end
    end

    methods ( Access = protected, Static, Hidden )
        function states = disableRemoteSaveWarnings()
        % Call this prior to serializing a bunch of stuff that might have hidden
        % Composites/distributed etc. This turns of the saveobj warnings,
        % and leaves the user with the one useful save/load count warning.
            ws = spmdlang.AbstractSpmdExecutor.RemoteSerializationWarningsToSuppress;
            states = cell( 1, length( ws ) );
            for ii=1:length( ws )
                states{ii} = warning( 'off', ws{ii} );
            end
        end
        function restoreRemoteSaveWarnings( states )
        % Call this after serialization to restore the warning state correctly.
            for ii=1:length( states )
                warning( states{ii} );
            end
        end
    end
    
    methods ( Access = private, Static, Hidden )
        
        function returnVar = buildComposite( deserParcels, nlabs, resSet, initOut )
        % Logic to attempt to match the flowchart in 1.13
            
        % Lots of places need to know which returns we got
            gotReturnBool = ~cellfun( @isempty, deserParcels );
            
            % Work out what to do based on what returns we got. Calculate some flags:
            fullReturn     = all( gotReturnBool );
            onlyPartReturn = ~fullReturn && any( gotReturnBool );
            noReturn       = ~fullReturn && ~onlyPartReturn;

            % If we got any return at all, we need to check the factory functions

            % XXX TODO: Also check against initOut iff onlyPartReturn && initOut
            % parallel resource set matches.
            if ~noReturn
                ffun_cell = cellfun( @getFactoryFcn, deserParcels(gotReturnBool), ...
                                     'UniformOutput', false );
                % Check all match
                for ii=2:length( ffun_cell )
                    if ~isequal( ffun_cell{1}, ffun_cell{ii} )
                        % Because this is now called via the dispose() method, "normal" (i.e. no
                        % other errors in the block) will cause this to trigger a real error.
                        error( 'distcomp:spmd:FactoryMismatch', ...
                               ['The remote object cannot be created because there is\n', ...
                                'a mismatch between the returned factory functions %s and %s'], ...
                               func2str( ffun_cell{1} ), func2str( ffun_cell{ii} ) );
                    end
                end
                factoryFcn = ffun_cell{1};
            else
                % In this case, we may or may not (policy decision) build an empty Composite -
                % let's get the factory function in any case.
                factoryFcn = @spmdlang.plainCompositeBuilder;
            end
            
            if fullReturn
                returnVar = {spmdlang.AbstractSpmdExecutor.buildNewComposite( factoryFcn, ...
                                                                  deserParcels, gotReturnBool, ...
                                                                  nlabs, resSet )};
                
            else
                % partial or empty return. 
                if onlyPartReturn
                    returnVar = {spmdlang.AbstractSpmdExecutor.handlePartialReturn( factoryFcn, ...
                                                                      deserParcels, gotReturnBool, ...
                                                                      nlabs, resSet, initOut )};
                else
                    if ~noReturn
                        error( 'distcomp:spmd:UnexpectedReturn', ...
                               'A consistency error was detected on remote object return' );
                    end
                    % In this case (no return at all), default to a plain Remote.
                    % factoryFcn = @spmdlang.plainCompositeBuilder;
                    % Actually, return nothing at all if nothing was assigned on the labs
                    returnVar = [];
                end
            end
        end
        
        % This function is called when there are some returns, but not all. This may error
        function returnVar = handlePartialReturn( factoryFcn, deserParcels, gotParcelIdx, nlabs, resSet, initOut )

            % In the case of partial (but not full) return, check if we've got a
            % compatible pre-existing Remote
            canMergeComposite = false;
            gotPlainClientValue = false;
            if ~isempty( initOut )
                if isa( initOut{1}, 'spmdlang.AbstractRemote' )
                    canMergeComposite = isMergable( initOut{1}, factoryFcn, resSet );
                else
                    % Is the pre-existing value suitable for Composite::setClientValue?
                    gotPlainClientValue = true;
                end
            end
            
            % XXX TODO: Currently, not throwing an error in the case where parallel
            % resource sets match but factory functions do not. (also need
            % to build new composite with all values)
            
            if canMergeComposite
                % Turn deserParcels into cell of new keys
                keyVector = cell( 1, nlabs );
                keyVector( gotParcelIdx ) = cellfun( @getKey, deserParcels( gotParcelIdx ), ...
                                                     'UniformOutput', false );
                % Then merge
                returnVar = mergeNewReturns( initOut{1}, keyVector );
            else
                % Cannot merge, so build a new one
                returnVar = spmdlang.AbstractSpmdExecutor.buildNewComposite( factoryFcn, ...
                                                                  deserParcels, gotParcelIdx, nlabs, resSet );

                % We can only set the client value on a "Composite"
                if gotPlainClientValue && isa( returnVar, 'Composite' )
                    returnVar = setClientValue( returnVar, initOut{1} );
                end
            end
        end
        
        function var = buildNewComposite( factoryFcn, deserParcelsCell, gotParcelIdx, nlabs, resSet )
            vectorOfUserData = cell( 1, nlabs );
            vectorOfUserData( gotParcelIdx ) = cellfun( @getUserData, deserParcelsCell( gotParcelIdx ), ...
                                                        'UniformOutput', false );
            var = factoryFcn( vectorOfUserData );
            
            keyVector = cell( 1, nlabs );
            keyVector( gotParcelIdx ) = cellfun( @getKey, deserParcelsCell( gotParcelIdx ), ...
                                                 'UniformOutput', false );
            var = init( var, keyVector, spmdlang.ResourceSetHolder( resSet ), factoryFcn );
        end
        
    end
    
    methods ( Static, Hidden )
        % Common code to perform lab-side unpackaging of Remotes
        function unpacked = unpack( q )
            if isa( q, 'spmdlang.SendableParcel' )
                unpacked = q.unpack();
            else
                unpacked = q;
            end
        end
    end
end
