% This class manages the various resource set objects that we need to
% implement SPMD. The main interface to this class is the static method
% chooseResourceSet
% <<singleton>>

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $   $Date: 2009/07/18 15:50:32 $

classdef ResourceSetMgr < handle

    properties ( Access = private )
        TrivialSet          % The one true "trivial" resource set
        WorldSet            % The "world" set from which an inner set can be built
        ActiveNonTrivialSet % The "inner" resource set.
    end

    methods ( Hidden, Static )
        % SPMD-specific size of matlabpool - this works during matlabpooljobs too.
        function [ps, sess] = poolSize()
            sess = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession();
            if ~isempty( sess ) && sess.isSessionRunning() && sess.isPoolManagerSession()
                ps = sess.getPoolSize();
            else
                ps = 0;
            end
        end
    end

    methods ( Access = private, Static )
        % Check one of the numeric arguments to SPMD
        function tf = sIsValidSpmdArg( x )
            tf = numel( x ) == 1 && ...
                 isnumeric( x ) && ...
                 isequal( x, round( x ) );
        end

        % return the singleton instance
        function obj = getMgr()
            persistent Singleton
            if isempty( Singleton )
                Singleton = spmdlang.ResourceSetMgr();
            end
            obj = Singleton;
        end
    end

    %% Most methods of the ResourceSetMgr are private, the public interface is the static one.
    methods (Access = private)
        function obj = ResourceSetMgr()
            obj.TrivialSet = spmdlang.TrivialResourceSet();
            obj.WorldSet   = [];          % This will be constructed on demand
            obj.ActiveNonTrivialSet = [];
        end
        
        % private function to actually choose a resource set
        % sendParcelCell - a cell array of any sendable parcels (transmission form of Remotes)
        % minN and maxN are the resolved integer arguments to the SPMD block.
        function rs = pChooseResourceSet( obj, sendParcelCell, minN, maxN )

        % If any of our stashed resource sets are no longer valid, drop them. (This
        % happens when the pool is closed
            if ~isempty( obj.WorldSet ) && ~isValid( obj.WorldSet )
                obj.WorldSet.invalidate( false ); % shouldn't really be necessary.
                obj.WorldSet = [];
            end
            if ~isempty( obj.ActiveNonTrivialSet ) && ~isValid( obj.ActiveNonTrivialSet )
                obj.ActiveNonTrivialSet.invalidate( false );
                obj.ActiveNonTrivialSet = [];
            end

            poolSize = spmdlang.ResourceSetMgr.poolSize();

            if isempty( obj.WorldSet ) && poolSize > 0
                obj.WorldSet = spmdlang.RemoteResourceSet.buildWorldSet();
            end

            %% Logic from flow chart in sect. 1.3.2.
            if ~isempty( sendParcelCell ) % "Does the block contain Remotes as input variables?"
                rs = obj.chooseResourceSetFromRemotes( sendParcelCell, minN, maxN );
            else
                if maxN == 0 % "Is this asking for spmd(0)?"
                    rs = obj.TrivialSet;
                else

                    if ~isempty( obj.ActiveNonTrivialSet ) % "Does there exist an inner parallel resource set?"
                        if ~obj.ActiveNonTrivialSet.isReferenced()
                            % Treat this case as if there wasn't really an active set
                            rs = obj.buildFromPoolIfPossibleOrTrivial( minN, maxN, poolSize );
                        else
                            rs = obj.ActiveNonTrivialSet;
                            if rs.satisfiesConstraints( minN, maxN ) % "Does it match the constraints?"
                                % OK
                            else
                                rs = obj.returnTrivialOrError( minN, maxN, poolSize );
                            end
                        end
                    else
                        rs = obj.buildFromPoolIfPossibleOrTrivial( minN, maxN, poolSize );
                    end
                end
            end
        end

        % Can we derive a resource set from a cell array of sendable Remote-type objects?
        % This will return either the active non-trivial set, or the trivial set, or error.
        % sendParcelCell is a cell array of sendable parcels
        % minN and maxN are the SPMD block constraints
        % Throws a variety of errors if there are mismatches, or the supplied
        function rs = chooseResourceSetFromRemotes( obj, sendParcelCell, minN, maxN )
            v1 = sendParcelCell{1}{1};
            rs = v1.getResourceSet();
            if ~rs.isValid()
                error( 'distcomp:spmd:InvalidRemote', ...
                       ['An invalid Composite or distributed array was passed to an SPMD block. ', ...
                        'The Composite or distributed array may have been saved and then loaded, ', ...
                        'or the matlabpool with which it was being used may have been closed'] );
                % If other Remotes have invalid resource sets, that'll be picked up
                % because of the mismatch between that resource set and "rs".
            end

            % Do all Remotes have the same resource set?
            if all( cellfun( @(x)( isequal( rs, getResourceSet(x{1}) ) ), sendParcelCell ) )
                %"...and does that resource set match the constraints?"
                if rs.satisfiesConstraints( minN, maxN )
                    % OK
                else
                    
                    if minN == maxN
                        blockSizeDescr = num2str( minN );
                    else
                        blockSizeDescr = sprintf( '(%d, %d)', minN, maxN );
                    end
                    
                    error( 'distcomp:spmd:RemoteMismatch', ...
                           ['A Composite or distributed array was passed to an SPMD block with which it is ', ...
                            'not compatible. The Composite or distributed array was created for use with ', ...
                            'an SPMD block of size %d. This was sent for use with an SPMD block of size ', ...
                            '%s'], rs.numlabs, blockSizeDescr );
                end
            else
                error( 'distcomp:spmd:RemoteMismatch', ...
                       ['Some of the Composites or distributed arrays passed to the SPMD block were ', ...
                        'not compatible with each other. Only Composites or distributed arrays created ', ...
                        'using the same size SPMD blocks can be passed into a single SPMD block'] );
            end
            if isequal( rs, obj.ActiveNonTrivialSet ) || isequal( rs, obj.TrivialSet )
                % Ok
            else
                error( 'distcomp:spmd:ResourceSetConsistency', ...
                       'An unexpected remote resource set was selected for remote execution' );
            end
        end

        % Return either a resource set built from the pool if we can match the
        % constraints, or else defer to returnTrivialOrError. In the special
        % case where an existing active set matches precisely what we'd
        % build, return that to avoid repeatedly destroying and re-creating
        % resource sets.
        function rs = buildFromPoolIfPossibleOrTrivial( obj, minN, maxN, poolSize )
            if poolSize > 0 && poolSize >= minN % "Can I use the pool to create a new resource set...?"
                
                sizeToCreate = min( maxN, poolSize );
                didReuseActive = false;

                % Must delete the old set here if it doesn't precisely match what we would build.
                if ~isempty( obj.ActiveNonTrivialSet )
                    if obj.ActiveNonTrivialSet.numlabs == sizeToCreate
                        % No need to re-create, we can re-use
                        rs = obj.ActiveNonTrivialSet;
                        didReuseActive = true;
                    else
                        % Don't invalidate the current "world" set though.
                        if ~isequal( obj.ActiveNonTrivialSet, obj.WorldSet )
                            % This may involve a remote call to free MPI comms
                            obj.ActiveNonTrivialSet.invalidate( true );
                        end
                        obj.ActiveNonTrivialSet = [];
                    end
                end

                if ~didReuseActive
                    % Split the world set to create the new set
                    rs = buildRemoteResourceSet( obj.WorldSet, sizeToCreate );
                    obj.ActiveNonTrivialSet = rs;
                end
            else
                rs = obj.returnTrivialOrError( minN, maxN, poolSize );
            end
        end
        
        % If the trivial resource set matches the constraints, use that - else
        % format a descriptive error message. This is the final failure mode
        % of resource set selection other than those to do with Remote
        % object mismatches.
        function rs = returnTrivialOrError( obj, minN, maxN, poolSize )
        % Function used to implement flow chart 1.3.2 "Does the trivial parallel resource set satisfy the constraints?"
            if obj.TrivialSet.satisfiesConstraints( minN, maxN )
                % Yes, we can simply use the trivial resource set
                rs = obj.TrivialSet;
            else
                % Format a descriptive error message, including the current active size.
                if isempty( obj.ActiveNonTrivialSet )
                    activeSetMsg = '';
                else
                    activeSetMsg = sprintf( ', the active SPMD context is of size: %d', obj.ActiveNonTrivialSet.numlabs );
                end
                
                if minN == maxN
                    requestedSizeStr = sprintf( '%d', minN );
                else
                    requestedSizeStr = sprintf( '(%d, %d)', minN, maxN );
                end
                
                error( 'distcomp:spmd:NoResource', ....
                       ['Could not create an SPMD block to match the requested size: %s. ', ...
                        'The matlabpool size is: %d%s.'], ...
                       requestedSizeStr, poolSize, activeSetMsg );
            end
        end

    end

    methods (Static, Hidden)

        % Sole public interface to ResourceSetMgr - pass me a cell array of Remotes,
        % and other SPMD args.
        % inputsCell - this is a cell array of SendableParcels that are going to be
        % transmitted to the SPMD block.
        % varargin - these are the SPMD "args", typically zero to two integer
        % values, but there's a backdoor where a resource set can be sent
        % in.
        function rs = chooseResourceSet( inputsCell, varargin )

             % Back-door for various resource set operations:
            if nargin == 2 && isa( varargin{1}, 'spmdlang.AbstractResourceSet' )
                rs = varargin{1};
                return
            end


            error( nargchk( 1, 3, nargin, 'struct' ) );
            switch nargin
              case 1
                minN = 0; maxN = Inf;
              case 2
                minN = varargin{1}; maxN = minN;
              case 3
                minN = varargin{1}; maxN = varargin{2};
            end

            try
                if spmdlang.ResourceSetMgr.sIsValidSpmdArg( minN ) && ...
                        spmdlang.ResourceSetMgr.sIsValidSpmdArg( maxN )
                    
                    if minN > maxN
                        error( 'distcomp:spmd:BadResourceSpecification', ...
                               ['Minimum value of numlabs specified (%d) was larger than the \n', ...
                                'specified maximum (%d)'], minN, maxN );
                    else
                        % ok
                        obj = spmdlang.ResourceSetMgr.getMgr();
                        % Pick out Remotes from inputs cell array (they *are* packed at this stage)
                        varIdxs = cellfun( @(x)(~isempty( x ) && isa( x{1}, 'spmdlang.SendableParcel' )), inputsCell );
                        rs  = obj.pChooseResourceSet( inputsCell(varIdxs), minN, maxN );
                    end
                else
                    error( 'distcomp:spmd:BadResourceSpecification', ...
                           ['The numlabs constraints for SPMD must be specified as zero to two \n', ...
                            'scalar integers'] );
                end
            catch E
                % Strip stack of internals
                throw( E );
            end
        end
    end
end

