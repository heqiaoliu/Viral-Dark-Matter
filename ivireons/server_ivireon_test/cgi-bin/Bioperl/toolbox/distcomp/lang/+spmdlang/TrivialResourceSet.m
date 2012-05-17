% Trivial resource set - the resource set used for SPMD(0) calls


% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2009/01/20 15:31:29 $
classdef TrivialResourceSet < spmdlang.AbstractResourceSet
    methods ( Access = public, Hidden )
        
        function tf  = isValid( obj ) %#ok<MANU>
            tf = true;
        end
        
        function tf  = canAccessLabs( obj ) %#ok<MANU>
            tf = internal.matlab.getParallelFunctionDepth == 0;
        end

        function obj = TrivialResourceSet()
            obj@spmdlang.AbstractResourceSet( 1 );
        end
        
        function tf = satisfiesConstraints( obj, minN, maxN ) %#ok<MANU,INUSD>
        % Trivial resource set only satisfies constraints if minN is zero
            tf = ( minN == 0 );
        end
        
        function blockEx = buildBlockExecutor( obj, bodyF, assignOutF, getOutF, unpackInF, initialOuts )
            blockEx = spmdlang.LocalSpmdExecutor( spmdlang.ResourceSetHolder( obj ), ...
                                                 bodyF, assignOutF, getOutF, unpackInF, initialOuts );
        end
        
        function val = getFromLab( obj, labidx, key ) %#ok<MANU>
            if labidx ~= 1
                error( 'distcomp:spmd:Consistency', ...
                       ['An unexpected index was supplied to getFromLab for the trivial resource set.\n', ...
                        'The index was: %d'], labidx );
            end
            val = spmdlang.ValueStore.retrieve( key );
            % Ensure that hidden Composites are turned into broken
            % Composites. Serializing and de-serializing in this way may be
            % somewhat inefficient, but it's the only way to ensure
            % consistency between local and remote operation.
            val = distcompdeserialize( distcompserialize( val ) );
        end
        
        function newKey = setOnLab( obj, labidx, newValue ) %#ok<MANU>
            if labidx ~= 1
                error( 'distcomp:spmd:Consistency', ...
                       ['An unexpected index was supplied to setOnLab for the trivial resource set.\n', ...
                        'The index was: %d'], labidx );
            end
            newKey = spmdlang.ValueStore.store( newValue );
        end
        
        function keyUnreferenced( obj, labidx, key ) %#ok<MANU>
            if labidx ~= 1
                error( 'distcomp:spmd:Consistency', ...
                       ['An unexpected index key become unreferenced for the trivial resource set.\n', ...
                        'The index was: %d'], labidx );
            end
            spmdlang.ValueStore.remove( key );
        end
        
    end
end
