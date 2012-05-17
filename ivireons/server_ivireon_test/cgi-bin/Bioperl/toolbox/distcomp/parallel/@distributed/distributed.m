
%DISTRIBUTED Distributed array data type
%
%   A distributed array uses the memory of MATLAB pool workers to store the
%   elements of an array. In this way, an array too large to fit into the
%   memory of a single machine can be created and manipulated.
%
%   Distributed arrays can be constructed directly either using the
%   constructor DISTRIBUTED, or by using one of the static constructor
%   methods such as DISTRIBUTED.ONES. Distributed arrays are also created
%   automatically when CODISTRIBUTED arrays return from the body of an SPMD
%   block.
%
%   Example: various means of constructing distributed arrays
%   Nsmall = 50;
%   Nlarge = 1000;
%   % method 1: use the constructor directly with local data
%   D1 = distributed( magic( Nsmall ));
%   % method 2: use a static method
%   D2 = distributed.ones( Nlarge );
%   % method 3: D3 is returned as a distributed array from the SPMD block
%   spmd
%     D3 = codistributed.ones( Nlarge );
%   end
%   class( D3 )       % returns 'distributed'
%   isequal( D2, D3 ) % returns true
%
%   Many mathematical and plotting methods are defined for distributed
%   arrays. Call METHODS( 'DISTRIBUTED' ) to see a full listing. The following
%   lists contain only the intrinsic methods of distributed arrays.
%
%   distributed methods:
%   DISTRIBUTED     - construct from local data
%   ISDISTRIBUTED   - return true for distributed arrays
%   GATHER          - retrieve data from the labs to the client
%   classUnderlying - return the class of the elements
%   isaUnderlying   - return true if elements are of a given class 
%
%   distributed static methods:
%   CELL    - build distributed cell array
%   COLON   - build distributed vector of form a:[d:]b
%   EYE     - build distributed identity matrix
%   FALSE   - build distributed array containing 'false'
%   INF     - build distributed array containing 'Inf'
%   NAN     - build distributed array containing 'NaN'
%   ONES    - build distributed array containing ones
%   RAND    - build distributed array containing rand
%   RANDN   - build distributed array containing randn
%   SPALLOC - build empty sparse distributed array
%   SPEYE   - build sparse distributed identity matrix
%   SPRAND  - build sparse distributed array containing rand
%   SPRANDN - build sparse distributed array containing randn
%   TRUE    - build distributed array containing 'true'
%   ZEROS   - build distributed array containing zeros
%
%   See also DISTRIBUTED.DISTRIBUTED, SPMD, MATLABPOOL, CODISTRIBUTED

% Copyright 2006-2010 The MathWorks, Inc.
classdef distributed < spmdlang.AbstractRemote

    properties ( Access = private, Hidden, Transient )
        Size = [0 0];
        ClassUnderlying = 'Invalid';
        SparseFlag = 0;
        RemoteBytes = 0;
    end

    methods ( Access = public, Hidden )
        function bytes = hGetRemoteBytes( obj )
            bytes = obj.RemoteBytes;
        end
        function obj = hSendData( obj, region, data )
        % Hidden access to private "transferPortion"
            obj = transferPortion( obj, region, data );
        end
        function data = hRetrieveData( obj, region )
        % Hidden access to private "transferPortion"
            data = transferPortion( obj, region );
        end
    end
    
    methods ( Access = private, Hidden )
        
        function tf = isValid( obj )
        % Defer to AbstractRemote to check whether or not this distributed is still
        % valid. Invalidation could occur either by save/load, or hidden
        % transfer, or by closing the pool.
            tf = obj.isResourceSetOpen();
        end
        
        function errorIfInvalid( obj )
        % Throw an exception as caller if the distributed is not valid.
            if ~obj.isResourceSetOpen()
                throwAsCaller( MException( 'distcomp:distributed:InvalidDistributed', ...
                                           '%s', ... % NB - always use format specifier with MException
                                           ['The distributed array cannot be used. This could be because the ', ...
                                    'MATLABPOOL has been closed, or the distributed array could have ', ...
                                    'been passed into an SPMD block inside some other container such as ', ...
                                    'a cell array or structure'] ) );
            end
        end
    end
    
    methods ( Access = public )
        function obj = distributed( varargin )
        %DISTRIBUTED Create distributed array from local data
        %   D = DISTRIBUTED( X ) creates a distributed array from X. X is an array
        %   stored on the MATLAB client, and D is a distributed array stored on the
        %   workers of the open MATLAB pool.
        %
        %   Constructing a distributed from local data in this way is
        %   appropriate only if the MATLAB client can store the entirety of
        %   X in its memory.  Use one of the static constructor methods such
        %   as DISTRIBUTED.ONES, DISTRIBUTED.ZEROS, etc., to construct large
        %   distributed arrays.
        %
        %   Example:
        %   % directly create a small distributed array
        %   Nsmall = 50;
        %   D1 = distributed( magic( Nsmall ) );
        %   % create a large distributed array using a static build method
        %   Nlarge = 1000;
        %   D2 = distributed.rand( Nlarge );
        %
        %   See also DISTRIBUTED, DISTRIBUTED.ONES, DISTRIBUTED.ZEROS.
            
            if nargin == 0
                % Build empty distributed using the no-args codistributed constructor.
                obj = spmd_feval_fcn( @codistributed );
            elseif nargin == 1
                % Constructor should be idempotent
                if isa( varargin{1}, 'distributed' )
                    obj = varargin{1};
                    return;
                end
                % Cast construction - scatter the input argument
                try
                    obj = distributed.pScatter( varargin{1} );
                catch E
                    throw( E ); % Strip off stack.
                end
            elseif nargin == 5 && ...
                    ischar( varargin{5} ) && ...
                    strcmp( varargin{5}, 'undoc:distributedFromSPMD' )
                % Build as return from SPMD block
                obj.Size            = varargin{1};
                obj.ClassUnderlying = varargin{2};
                obj.SparseFlag      = varargin{3};
                obj.RemoteBytes     = varargin{4};
            else
                error( 'distcomp:distributed:UnexpectedConstructorArgs', ...
                       ['The distributed array constructor should be called with 0 or ', ...
                        '1 arguments.'] );
            end
        end
    end
    
    methods ( Access = private, Static )
        function obj = pScatter( data )
            if distributedutil.Allocator.supportsCreation( data )
                tmpl  = distributedutil.Allocator.extractTemplate( data );
                obj   = spmd_feval_fcn( @distributedutil.Allocator.createCodistributed, ...
                                      { size( data ), tmpl } );
                range = struct( 'start', ones( ndims( obj ), 1 ), ...
                                'end',   size( obj ).' );
                obj   = transferPortion( obj, range, data ); 
            else
                error( 'distcomp:distributed:InvalidTypeForConstruction', ...
                       'A distributed array cannot be created with data of class: %s', ...
                       class( data ) );
            end
        end
        
        function pInvalidPropertyAccess( thing )
            throwAsCaller( MException( 'distcomp:distributed:NotImplemented', ...
                                       ['It is not possible to access the %s directly from a distributed array. ', ...
                                'To access the %s, you must enter an SPMD block and access it from the ', ...
                                'corresponding codistributed array'], thing, thing ) );
        end
        function pInvalidMethodCall( methodName )
            throwAsCaller( MException( 'distcomp:distributed:NotImplemented', ...
                                       ['It is not possible to call "%s" directly on a distributed array. ', ...
                                'To call "%s", you must enter an SPMD block and operate on the ', ...
                                'corresponding codistributed array'], methodName, methodName ) );
        end
    end
    
    methods ( Access = public, Static, Sealed, Hidden )
        function obj = loadobj( obj )
        % Don't warn - the user was already warned at save time.
            spmdlang.AbstractRemote.saveLoadCount( 'increment' );
        end
    end
    
    methods ( Access = public, Hidden )
        
        function obj = saveobj( obj, varargin )
            spmdlang.AbstractRemote.saveLoadCount( 'increment' );
            warning( 'distcomp:spmd:DistributedSave', ...
                     'Saving distributed arrays is not supported' );
        end
        function varargout = getCodistributor( varargin ) %#ok<STOUT>
            distributed.pInvalidPropertyAccess( 'codistributor' );
        end
        function varargout = getLocalPart( varargin ) %#ok<STOUT>
            distributed.pInvalidPropertyAccess( 'local part' );
        end
        function varargout = setLocalPart( varargin ) %#ok<STOUT>
            distributed.pInvalidPropertyAccess( 'local part' );
        end
        function varargout = globalIndices( varargin ) %#ok<STOUT>
            distributed.pInvalidMethodCall( 'globalIndices' )
        end
        function varargout = redistribute( varargin ) %#ok<STOUT>
            distributed.pInvalidMethodCall( 'redistribute' );
        end
    end

    methods (Access = public)
        function [varargout] = abs( varargin )
        %ABS Absolute value of distributed array
        %   Y = ABS(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = complex(3*distributed.ones(N),4*distributed.ones(N))
        %       absD = abs(D)
        %   
        %   compare with
        %   absD2 = sqrt(real(D).^2 + imag(D).^2)
        %   
        %   See also ABS, DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @abs, varargin{:} );
        end

        function [varargout] = acos( varargin )
        %ACOS Inverse cosine of distributed array, result in radians
        %   Y = ACOS(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.zeros(N);
        %       E = acos(D)
        %   
        %   See also ACOS, DISTRIBUTED, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @acos, varargin{:} );
        end

        function [varargout] = acosd( varargin )
        %ACOSD Inverse cosine of distributed array, result in degrees
        %   Y = ACOSD(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.zeros(N);
        %       E = acosd(D)
        %   
        %   See also ACOSD, DISTRIBUTED, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @acosd, varargin{:} );
        end

        function [varargout] = acosh( varargin )
        %ACOSH Inverse hyperbolic cosine of distributed array
        %   Y = ACOSH(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.zeros(N);
        %       E = acosh(D)
        %   
        %   See also ACOSH, DISTRIBUTED, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @acosh, varargin{:} );
        end

        function [varargout] = acot( varargin )
        %ACOT Inverse cotangent of distributed array, result in radians
        %   Y = ACOT(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = acot(D)
        %   
        %   See also ACOT, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @acot, varargin{:} );
        end

        function [varargout] = acotd( varargin )
        %ACOTD Inverse cotangent of distributed array, result in degrees
        %   Y = ACOTD(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = acotd(D)
        %   
        %   See also ACOTD, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @acotd, varargin{:} );
        end

        function [varargout] = acoth( varargin )
        %ACOTH Inverse hyperbolic cotangent of distributed array
        %   Y = ACOTH(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.inf(N);
        %       E = acoth(D)
        %   
        %   See also ACOTH, DISTRIBUTED, DISTRIBUTED/INF.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @acoth, varargin{:} );
        end

        function [varargout] = acsc( varargin )
        %ACSC Inverse cosecant of distributed array, result in radian
        %   Y = ACSC(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = acsc(D)
        %   
        %   See also ACSC, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @acsc, varargin{:} );
        end

        function [varargout] = acscd( varargin )
        %ACSCD Inverse cosecant of distributed array, result in degrees
        %   Y = ACSCD(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = acscd(D)
        %   
        %   See also ACSCD, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @acscd, varargin{:} );
        end

        function [varargout] = acsch( varargin )
        %ACSCH Inverse hyperbolic cosecant of distributed array
        %   Y = ACSCH(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.inf(N);
        %       E = acsch(D)
        %   
        %   See also ACSCH, DISTRIBUTED, DISTRIBUTED/INF.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @acsch, varargin{:} );
        end

        function [varargout] = all( varargin )
        %ALL True if all elements of a distributed vector are nonzero
        %   A = ALL(D)
        %   A = ALL(D,DIM)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.colon(1,N)
        %       t = all(D)
        %   
        %   returns t the distributed logical scalar with value true.
        %   
        %   See also ALL, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @all, varargin{:} );
        end

        function [varargout] = and( varargin )
        %& Logical AND for distributed array
        %   C = A & B
        %   C = AND(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.eye(N);
        %       D2 = distributed.rand(N);
        %       D3 = D1 & D2
        %   
        %   returns D3 a N-by-N distributed logical array with the
        %   diagonal populated with true values.
        %   
        %   See also AND, DISTRIBUTED, DISTRIBUTED/EYE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @and, varargin{:} );
        end

        function [varargout] = angle( varargin )
        %ANGLE Phase angle of distributed array
        %   Y = ANGLE(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = 1i * distributed.ones(N);
        %       E = angle(D)
        %   
        %   See also ANGLE, DISTRIBUTED, DISTRIBUTED/SQRT.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @angle, varargin{:} );
        end

        function [varargout] = any( varargin )
        %ANY True if any element of a distributed vector is nonzero or TRUE
        %   A = ANY(D)
        %   A = ANY(D,DIM)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.eye(N);
        %       t = any(D,1)
        %   
        %   returns t the distributed row vector equal to
        %   distributed.true(1,N).
        %   
        %   See also ANY, DISTRIBUTED, DISTRIBUTED/EYE, DISTRIBUTED/TRUE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @any, varargin{:} );
        end

        function [varargout] = asec( varargin )
        %ASEC Inverse secant of distributed array, result in radians
        %   Y = ASEC(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = asec(D)
        %   
        %   See also ASEC, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @asec, varargin{:} );
        end

        function [varargout] = asecd( varargin )
        %ASECD Inverse secant of distributed array, result in degrees
        %   Y = ASECD(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = asecd(D)
        %   
        %   See also ASECD, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @asecd, varargin{:} );
        end

        function [varargout] = asech( varargin )
        %ASECH Inverse hyperbolic secant of distributed array
        %   Y = ASECH(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.inf(N);
        %       E = asech(D)
        %   
        %   See also ASECH, DISTRIBUTED, DISTRIBUTED/INF.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @asech, varargin{:} );
        end

        function [varargout] = asin( varargin )
        %ASIN Inverse sine of distributed array, result in radians
        %   Y = ASIN(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = asin(D)
        %   
        %   See also ASIN, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @asin, varargin{:} );
        end

        function [varargout] = asind( varargin )
        %ASIND Inverse sine of distributed array, result in degrees
        %   Y = ASIND(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = asind(D)
        %   
        %   See also ASIND, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @asind, varargin{:} );
        end

        function [varargout] = asinh( varargin )
        %ASINH Inverse hyperbolic sine of distributed array
        %   Y = ASINH(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.zeros(N);
        %       E = asinh(D)
        %   
        %   See also ASINH, DISTRIBUTED, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @asinh, varargin{:} );
        end

        function [varargout] = atan( varargin )
        %ATAN Inverse tangent of distributed array, result in radians
        %   Y = ATAN(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = atan(D)
        %   
        %   See also ATAN, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @atan, varargin{:} );
        end

        function [varargout] = atan2( varargin )
        %ATAN2 Four quadrant inverse tangent of distributed array
        %   Z = ATAN2(Y,X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = atan2(D,D)
        %   
        %   See also ATAN2, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @atan2, varargin{:} );
        end

        function [varargout] = atand( varargin )
        %ATAND Inverse tangent of distributed array, result in degrees
        %   Y = ATAND(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = atand(D)
        %   
        %   See also ATAND, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @atand, varargin{:} );
        end

        function [varargout] = atanh( varargin )
        %ATANH Inverse hyperbolic tangent of distributed array
        %   Y = ATANH(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = atanh(D)
        %   
        %   See also ATANH, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @atanh, varargin{:} );
        end

        function [varargout] = bitand( varargin )
        %BITAND Bit-wise AND of distributed array
        %   C = BITAND(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.ones(N,'uint32');
        %       D2 = triu(D1);
        %       D3 = bitand(D1,D2)
        %   
        %   See also BITAND, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @bitand, varargin{:} );
        end

        function [varargout] = bitor( varargin )
        %BITOR Bit-wise OR of distributed array
        %   C = BITOR(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.ones(N,'uint32');
        %       D2 = triu(D1);
        %       D3 = bitor(D1,D2)
        %   
        %   See also BITOR, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @bitor, varargin{:} );
        end

        function [varargout] = bitxor( varargin )
        %BITXOR Bit-wise XOR of distributed array
        %   C = BITXOR(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.ones(N,'uint32');
        %       D2 = triu(D1);
        %       D3 = bitxor(D1,D2)
        %   
        %   See also BITXOR, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @bitxor, varargin{:} );
        end

        function [varargout] = cast( varargin )
        %CAST Cast a distributed array to a different data type or class
        %   B = CAST(A,NEWCLASS)
        %   
        %   Example:
        %       N = 1000;
        %       Du = distributed.ones(N,'uint32');
        %       Ds = cast(Du,'single')
        %       classDu = classUnderlying(Du)
        %       classDs = classUnderlying(Ds)
        %   
        %   casts the distributed uint32 array Du to the distributed single array
        %   Ds. classDu is 'uint32', while classDs is 'single'.
        %   
        %   See also CAST, DISTRIBUTED, DISTRIBUTED/ONES, 
        %   DISTRIBUTED/CLASSUNDERLYING.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @cast, varargin{:} );
        end

        function [varargout] = cat( varargin )
        %CAT Concatenate distributed arrays
        %   C = CAT(DIM,A,B,...) implements CAT(DIM,A,B,...) for distributed arrays.
        %   
        %   Example:
        %       N1 = 500;
        %       N2 = 1000;
        %       D1 = distributed.ones(N1,N2);
        %       D2 = distributed.zeros(N1,N2);
        %       D3 = cat(1,D1,D2) % D3 is 1000-by-1000
        %       D4 = cat(2,D1,D2) % D4 is 500-by-2000
        %   
        %   See also CAT, VERTCAT, HORZCAT, DISTRIBUTED, DISTRIBUTED/ONES, 
        %   DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @cat, varargin{:} );
        end

        function [varargout] = ceil( varargin )
        %CEIL Round distributed array towards plus infinity
        %   Y = CEIL(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.colon(1,N)./2
        %       E = ceil(D)
        %   
        %   See also CEIL, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @ceil, varargin{:} );
        end

        function [varargout] = cell2mat( varargin )
        %CELL2MAT Convert the contents of a distributed cell array into a single matrix
        %   M = CELL2MAT(C)
        %   
        %   Example:
        %       N = 1000;
        %       c = distributed(num2cell(1:N))
        %       m = cell2mat(c)
        %       classc = classUnderlying(c)
        %       classm = classUnderlying(m)
        %   
        %   takes the 1-by-N distributed cell array c and returns the
        %   distributed double row vector m equal to distributed.colon(1, N).
        %   classc is 'cell' while classm is 'double'.
        %   
        %   See also CELL2MAT, DISTRIBUTED, DISTRIBUTED/COLON, 
        %   DISTRIBUTED/CELL, DISTRIBUTED/CLASSUNDERLYING.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @cell2mat, varargin{:} );
        end

        function [varargout] = cell2struct( varargin )
        %CELL2STRUCT Convert distributed cell array to structure array
        %   S = CELL2STRUCT(C,FIELDS,DIM)
        %   
        %   Example:
        %       N = 1000;
        %       C = distributed(repmat({rand(7); char(64+7)}, 1, N))
        %       f = {'matrix','name'}
        %       S = cell2struct(C,f,1)
        %       classC = classUnderlying(C)
        %       classS = classUnderlying(S)
        %   
        %   takes the 2-by-N distributed cell array c and converts it into a
        %   N-by-1 distributed struct array s, with fields named 'matrix' and
        %   'name'.
        %   classC is 'cell' while classS is 'struct'.
        %   
        %   See also CELL2STRUCT, DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @cell2struct, varargin{:} );
        end

        function [varargout] = cellfun( varargin )
        %CELLFUN Apply a function to each cell of a distributed cell array
        %   A = CELLFUN(FUN, C)
        %   A = CELLFUN(FUN, B, C, ...)
        %   [A, B, ...] = CELLFUN(FUN, C,  ..., 'Param1', val1, ...)
        %   
        %   Example:
        %       N = 1000;
        %       C = distributed.cell(N)
        %       T = cellfun(@isempty,C)
        %       classC = classUnderlying(C)
        %       classT = classUnderlying(T)
        %   
        %   returns a N-by-N distributed logical matrix T the same as
        %   distributed.true(N).
        %   classC is 'cell' while classT is 'logical'.
        %   
        %   See also  CELLFUN, DISTRIBUTED, DISTRIBUTED/CELL.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @cellfun, varargin{:} );
        end

        function [varargout] = char( varargin )
        %CHAR Convert a distributed array to a distributed character array (string)
        %   S = CHAR(X)
        %   
        %   The syntax S = CHAR(T1,T2,T3, ...) is not supported.
        %   
        %   Example:
        %       N = 1000;
        %       D = 65*distributed.ones(N,'uint16');
        %       C = char(D)
        %       classD = classUnderlying(D)
        %       classC = classUnderlying(C)
        %   
        %   converts the N-by-N distributed uint16 matrix D into a
        %   distributed char array C.
        %   classD is 'uint16' while classC is 'char'.
        %   
        %   See also CHAR, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @char, varargin{:} );
        end

        function [varargout] = chol( varargin )
        %CHOL Cholesky factorization of distributed matrix
        %   R = CHOL(D)
        %   [R,p] = CHOL(D)
        %   L = CHOL(D, 'lower')
        %   [L,p] = CHOL(D, 'lower')
        %   
        %   D must be a full distributed matrix of floating point numbers (single or double).
        %   
        %   Example:
        %       N = 1000;
        %       D = 1 + distributed.eye(N);
        %       [R,p] = chol(D)
        %   
        %   See also CHOL, DISTRIBUTED, DISTRIBUTED/EYE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @chol, varargin{:} );
        end

        function [varargout] = colonize( varargin )
        %COLONIZE Implement A(:) for distributed A
        %   B = COLONIZE(A) implements B = A(:)
        %   
        %   Example:
        %       N = 1000;
        %       A = distributed.ones(N);
        %       B = colonize(A) % B is now a 1000000-by-1 vector of ones
        %   
        %   See also COLONIZE, DISTRIBUTED, DISTRIBUTED/ONES.
        %   

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @colonize, varargin{:} );
        end

        function [varargout] = complex( varargin )
        %COMPLEX Construct complex distributed array from real and imaginary parts
        %   C = COMPLEX(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = 3*distributed.ones(N);
        %       D2 = 4*distributed.ones(N);
        %       E = complex(D1,D2)
        %   
        %   See also COMPLEX, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @complex, varargin{:} );
        end

        function [varargout] = conj( varargin )
        %CONJ Complex conjugate of distributed array
        %   Y = CONJ(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = complex(3*distributed.ones(N),4*distributed.ones(N))
        %       E = conj(D)
        %   
        %   See also CONJ, DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @conj, varargin{:} );
        end

        function [varargout] = cos( varargin )
        %COS Cosine of distributed array in radians
        %   Y = COS(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.zeros(N);
        %       E = cos(D)
        %   
        %   See also COS, DISTRIBUTED, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @cos, varargin{:} );
        end

        function [varargout] = cosd( varargin )
        %COSD Cosine of distributed array in degrees
        %   Y = COSD(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.zeros(N);
        %       E = cosd(D)
        %   
        %   See also COSD, DISTRIBUTED, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @cosd, varargin{:} );
        end

        function [varargout] = cosh( varargin )
        %COSH Hyperbolic cosine of distributed array
        %   Y = COSH(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.zeros(N);
        %       E = cosh(D)
        %   
        %   See also COSH, DISTRIBUTED, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @cosh, varargin{:} );
        end

        function [varargout] = cot( varargin )
        %COT Cotangent of distributed array in radians
        %   Y = COT(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = cot(D)
        %   
        %   See also COT, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @cot, varargin{:} );
        end

        function [varargout] = cotd( varargin )
        %COTD Cotangent of distributed array in degrees
        %   Y = COTD(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = cotd(D)
        %   
        %   See also COTD, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @cotd, varargin{:} );
        end

        function [varargout] = coth( varargin )
        %COTH Hyperbolic cotangent of distributed array
        %   Y = COTH(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.inf(N);
        %       E = coth(D)
        %   
        %   See also COTH, DISTRIBUTED, DISTRIBUTED/INF.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @coth, varargin{:} );
        end

        function [varargout] = csc( varargin )
        %CSC Cosecant of distributed array in radians
        %   Y = CSC(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = csc(D)
        %   
        %   See also CSC, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @csc, varargin{:} );
        end

        function [varargout] = cscd( varargin )
        %CSCD Cosecant of distributed array in degrees
        %   Y = CSCD(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = cscd(D)
        %   
        %   See also CSCD, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @cscd, varargin{:} );
        end

        function [varargout] = csch( varargin )
        %CSCH Hyperbolic cosecant of distributed array
        %   Y = CSCH(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.inf(N);
        %       E = csch(D)
        %   
        %   See also CSCH, DISTRIBUTED, DISTRIBUTED/INF.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @csch, varargin{:} );
        end

        function [varargout] = ctranspose( varargin )
        %' Complex conjugate transpose of distributed array
        %   E = D'
        %   E = CTRANSPOSE(D)
        %   
        %   Example:
        %       N = 1000;
        %       D = complex(distributed.rand(N),distributed.rand(N))
        %       E = D'
        %   
        %   See also CTRANSPOSE, DISTRIBUTED, DISTRIBUTED/COMPLEX.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @ctranspose, varargin{:} );
        end

        function [varargout] = cumprod( varargin )
        %CUMPROD Cumulative product of elements of distributed array
        %   CUMPROD(X)
        %   CUMPROD(X,DIM)
        %   
        %   Example:
        %       N = 1000;
        %       D = 4 * (distributed.colon(1, N) .^ 2);
        %       D2 = D ./ (D - 1);
        %       c = cumprod(D2)
        %       c1 = cumprod(D2,1)
        %       c2 = cumprod(D2,2)
        %   
        %   returns c1 the same as D2 and c the same as c2. c(end) is
        %   approximately pi/2 (by the Wallis product).
        %   
        %   See also CUMPROD, DISTRIBUTED, DISTRIBUTED/COLON.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @cumprod, varargin{:} );
        end

        function [varargout] = cumsum( varargin )
        %CUMSUM Cumulative sum of elements of distributed array
        %   CUMSUM(X)
        %   CUMSUM(X,DIM)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.colon(1, N);
        %       c = cumsum(D)
        %       c1 = cumsum(D,1)
        %       c2 = cumsum(D,2)
        %   
        %   returns c1 the same as D and c the same as c2.
        %   c(1000) = (1+1000)*1000/2 = 500500.
        %   
        %   See also CUMSUM, DISTRIBUTED, DISTRIBUTED/COLON.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @cumsum, varargin{:} );
        end

        function [varargout] = diag( varargin )
        %DIAG Diagonal matrices and diagonals of a distributed matrix
        %   
        %   A = DIAG(D,K) when D is a distributed vector with N components results 
        %   in a square distributed matrix A of order N+ABS(K) with the elements of 
        %   D along the K-th diagonal of A.  Recall that K = 0 is the main diagonal, 
        %   K > 0 is above the main diagonal, and K < 0 is below the main diagonal.
        %   
        %   A = DIAG(D) is the same as A = DIAG(D,0) and puts D along the main 
        %   diagonal of A.
        %   
        %   D = DIAG(A,K) when A is a distributed matrix results in a distributed 
        %   column vector D formed from the elements of the K-th diagonal of A.  
        %   
        %   D = DIAG(A) is the same as D = DIAG(A,0) and D is the main diagonal 
        %   of A. Note that DIAG(DIAG(A)) results in a distributed diagonal matrix.
        %   
        %   Example:
        %       N = 1000;
        %       d = distributed.colon(N,-1,1)'
        %       d2 = distributed.colon(1,ceil(N/2))'
        %       D = diag(d) + diag(d2,floor(N/2))
        %   
        %   creates two distributed column vectors d and d2 and then populates the
        %   distributed matrix D with them as diagonals.
        %   
        %   See also DIAG, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.
        %   

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @diag, varargin{:} );
        end

        function [varargout] = dot( varargin )
        %DOT Vector dot product of distributed array
        %   C = DOT(A,B)
        %   C = DOT(A,B,DIM)
        %   
        %   Example:
        %       N = 1000;
        %       d1 = distributed.colon(1,N);
        %       d2 = distributed.ones(N,1);
        %       d = dot(d1,d2)
        %   
        %   returns d = N*(N+1)/2.
        %   
        %   See also DOT, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @dot, varargin{:} );
        end

        function [varargout] = double( varargin )
        %DOUBLE Convert distributed array to double precision
        %   Y = DOUBLE(X)
        %   
        %   Example:
        %       N = 1000;
        %       Ds = distributed.ones(N,'single');
        %       Dd = double(Ds)
        %       classDs = classUnderlying(Ds)
        %       classDd = classUnderlying(Dd)
        %   
        %   takes the N-by-N distributed single matrix Ds and converts
        %   it to the distributed double matrix Dd.
        %   classDs is 'single' while classDd is 'double'.
        %   
        %   See also DOUBLE, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @double, varargin{:} );
        end

        function [varargout] = eig( varargin )
        %EIG Eigenvalues and eigenvectors of distributed array
        %   D = EIG(A)
        %   [V,D] = EIG(A)
        %   
        %   A must be real symmetric or complex Hermitian.
        %   
        %   The generalized problem EIG(A,B) is not available.
        %   
        %   Example:
        %       N = 1000;
        %       A = distributed.rand(N);
        %       A = A+A'
        %       [V,D] = eig(A)
        %       normest(A*V-V*D)
        %   
        %   computes a real symmetric A and its eigenvalues D and eigenvectors V
        %   such that A*V is within round-off error of V*D.
        %   
        %   See also EIG, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @eig, varargin{:} );
        end

        function [varargout] = eigs( varargin )
        %EIGS Find a few eigenvalues and eigenvectors of a distributed matrix
        %   
        %   Not yet implemented.
        %   
        %   See also EIGS, DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @eigs, varargin{:} );
        end

        function [varargout] = eps( varargin )
        %EPS Spacing of floating point numbers for distributed array
        %   E = EPS(D)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N,'single');
        %       E = eps(D)
        %   
        %   returns E = eps('single')*distributed.ones(N).
        %   
        %   See also EPS, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @eps, varargin{:} );
        end

        function [varargout] = eq( varargin )
        %== Equal for distributed array
        %   C = A == B
        %   C = EQ(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.rand(N);
        %       T = D == D
        %       F = D == D'
        %   
        %   returns T = distributed.true(N) and F is probably the same as
        %   logical(distributed.eye(N)).
        %   
        %   See also EQ, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @eq, varargin{:} );
        end

        function [varargout] = exp( varargin )
        %EXP Exponential of distributed array
        %   Y = EXP(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = exp(D)
        %   
        %   See also EXP, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @exp, varargin{:} );
        end

        function [varargout] = expm1( varargin )
        %EXPM1 Compute exp(z)-1 accurately for distributed array
        %   Y = EXPM1(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = eps(1) .* distributed.ones(N);
        %       E = expm1(D)
        %   
        %   See also EXPM1, DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @expm1, varargin{:} );
        end

        function [varargout] = fft( varargin )
        %FFT Discrete Fourier transform of distributed array
        %   Y = FFT(X) is the discrete Fourier transform (DFT) of vector X.  For 
        %   matrices, the FFT operation is applied to each column.  For N-D arrays,
        %   the FFT operation operates on the first non-singleton dimension.
        %   
        %   Y = FFT(X,M) is the M-point FFT, padded with zeros if X has less than
        %   M points and truncated if it has more.
        %   
        %   Y = FFT(X,[],DIM) or Y = FFT(X,M,DIM) applies the FFT operation across 
        %   the dimension DIM.
        %   
        %   Example:
        %       Nrow = 2^16;
        %       Ncol = 100;
        %       D = distributed.rand(Nrow, Ncol);
        %       F = fft(D)
        %   
        %   returns the FFT F of the distributed matrix by applying the FFT to 
        %   each column.
        %   
        %   The current implementation gathers vectors on a single lab to perform
        %   the computations rather than using a parallel FFT algorithm. It may
        %   result in out-of-memory errors for long vectors.
        %   
        %   See also FFT, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @fft, varargin{:} );
        end

        function [varargout] = fieldnames( varargin )
        %FIELDNAMES Get structure field names of distributed array
        %   NAMES = FIELDNAMES(S)
        %   
        %   Example:
        %       matrices = { 1,  2,  3,  4,  5,  6,  7,  8,  9,  10};
        %       names    = {'a','b','c','d','e','f','g','h','i','j'};
        %       s = struct('matrix', matrices, 'name', names);
        %       S = distributed(s)
        %       f = fieldnames(S)
        %   
        %   returns the field names f = {'matrix','name'} of the 1-by-10
        %   distributed array of structs S.
        %   
        %   See also FIELDNAMES, DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @fieldnames, varargin{:} );
        end

        function [varargout] = find( varargin )
        %FIND Find indices of nonzero elements of distributed array
        %   If X is an m-by-n distributed with m ~= 1, then FIND(X) returns a p-by-1
        %   distributed column vector containing the p indices of the nonzero or true
        %   elements in X(:).
        %   
        %   If X is an 1-by-n distributed row vector, then FIND(X) returns a 1-by-p
        %   distributed row vector containing the p indices of the nonzero or true
        %   elements in X.
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.rand(N) > 0.5 % build random array of ones and zeros
        %       q = find(D) % find the indices where elements of D are non-zero
        %   
        %   See also FIND, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @find, varargin{:} );
        end

        function [varargout] = fix( varargin )
        %FIX Round distributed array towards zero
        %   Y = FIX(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.colon(1,N)./2
        %       E = fix(D)
        %   
        %   See also FIX, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @fix, varargin{:} );
        end

        function [varargout] = floor( varargin )
        %FLOOR Round distributed array towards minus infinity
        %   Y = FLOOR(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.colon(1,N)./2
        %       E = floor(D)
        %   
        %   See also FLOOR, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @floor, varargin{:} );
        end

        function [varargout] = full( varargin )
        %FULL Convert sparse distributed matrix to full distributed matrix
        %   F = FULL(D)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.speye(N);
        %       F = full(D)
        %   
        %   returns F = distributed.eye(N).
        %   
        %   t = issparse(D)
        %   f = issparse(F)
        %   
        %   returns t = true and f = false.
        %   
        %   See also FULL, DISTRIBUTED, DISTRIBUTED/SPEYE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @full, varargin{:} );
        end

        function [varargout] = ge( varargin )
        %>= Greater than or equal for distributed array
        %   C = A >= B
        %   C = GE(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.rand(N);
        %       T = D >= D
        %       F = D >= D+0.5
        %   
        %   returns T = distributed.true(N)
        %   and F = distributed.false(N).
        %   
        %   See also GE, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @ge, varargin{:} );
        end

        function [varargout] = gt( varargin )
        %> Greater than for distributed array
        %   C = A > B
        %   C = GT(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.rand(N);
        %       T = D > D-0.5
        %       F = D > D
        %   
        %   returns T = distributed.true(N) 
        %   and F = distributed.false(N).
        %   
        %   See also GT, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @gt, varargin{:} );
        end

        function [varargout] = horzcat( varargin )
        %HORZCAT Horizontal concatenation of distributed arrays
        %   C = HORZCAT(A,B,...) implements [A B ...] for distributed arrays.
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.eye(N);
        %       D2 = [D D] % a 1000-by-2000 distributed matrix
        %   
        %   See also HORZCAT, DISTRIBUTED, DISTRIBUTED/CAT.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @horzcat, varargin{:} );
        end

        function [varargout] = hypot( varargin )
        %HYPOT Robust computation of square root of sum of squares for distributed array
        %   C = HYPOT(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = 3e300*distributed.ones(N);
        %       D2 = 4e300*distributed.ones(N);
        %       E = hypot(D1,D2)
        %   
        %   See also HYPOT, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @hypot, varargin{:} );
        end

        function [varargout] = imag( varargin )
        %IMAG Complex imaginary part of distributed array
        %   Y = IMAG(X)
        %   
        %   Example:
        %       N = 1000;
        %       rp = 3 * distributed.ones(N);
        %       ip = 4 * distributed.ones(N);
        %       D = complex(rp, ip);
        %       E = imag(D)
        %   
        %   See also IMAG, DISTRIBUTED, DISTRIBUTED/COMPLEX, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @imag, varargin{:} );
        end

        function [varargout] = int16( varargin )
        %INT16 Convert distributed array to signed 16-bit integer
        %   I = INT16(X)
        %   
        %   Example:
        %       N = 1000;
        %       Du = distributed.ones(N,'uint16');
        %       Di = int16(Du)
        %       classDu = classUnderlying(Du)
        %       classDi = classUnderlying(Di)
        %   
        %   converts the N-by-N uint16 distributed array Du to the
        %   int16 distributed array Di.
        %   classDu is 'uint16' while classDi is 'int16'.
        %   
        %   See also INT16, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @int16, varargin{:} );
        end

        function [varargout] = int32( varargin )
        %INT32 Convert distributed array to signed 32-bit integer
        %   I = INT32(X)
        %   
        %   Example:
        %       N = 1000;
        %       Du = distributed.ones(N,'uint32');
        %       Di = int32(Du)
        %       classDu = classUnderlying(Du)
        %       classDi = classUnderlying(Di)
        %   
        %   converts the N-by-N uint32 distributed array Du to the
        %   int32 distributed array Di.
        %   classDu is 'uint32' while classDi is 'int32'.
        %   
        %   See also INT32, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @int32, varargin{:} );
        end

        function [varargout] = int64( varargin )
        %INT64 Convert distributed array to signed 64-bit integer
        %   I = INT64(X)
        %   
        %   Example:
        %       N = 1000;
        %       Du = distributed.ones(N,'uint64');
        %       Di = int64(Du)
        %       classDu = classUnderlying(Du)
        %       classDi = classUnderlying(Di)
        %   
        %   converts the N-by-N uint64 distributed array Du to the
        %   int64 distributed array Di.
        %   classDu is 'uint64' while classDi is 'int64'.
        %   
        %   See also INT64, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @int64, varargin{:} );
        end

        function [varargout] = int8( varargin )
        %INT8 Convert distributed array to signed 8-bit integer
        %   I = INT8(X)
        %   
        %   Example:
        %       N = 1000;
        %       Du = distributed.ones(N,'uint8');
        %       Di = int8(Du)
        %       classDu = classUnderlying(Du)
        %       classDi = classUnderlying(Di)
        %   
        %   converts the N-by-N uint8 distributed array Du to the
        %   int8 distributed array Di.
        %   classDu is 'uint8' while classDi is 'int8'.
        %   
        %   See also INT8, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @int8, varargin{:} );
        end

        function [varargout] = isaUnderlying( varargin )
        %isaUnderlying    True if the DISTRIBUTED array's underlying elements are a given class
        %   TF = isaUnderlying(D, 'classname') returns true if the elements of D are 
        %   either an instance of 'classname' or an instance of a class derived from 
        %   'classname'.  isaUnderlying and ISA support the same values for 'classname'. 
        %   
        %   Example:   
        %       N = 1000;
        %       D_uint8  = distributed.ones(1, N, 'uint8');
        %       D_cell   = distributed.cell(1, N);
        %       isUint8  = isaUnderlying(D_uint8, 'uint8') % returns true
        %       isDouble = isaUnderlying(D_cell, 'double')  % returns false
        %   
        %   See also ISA, DISTRIBUTED, DISTRIBUTED/classUnderlying, DISTRIBUTED/CELL, DISTRIBUTED/ONES.
        %    

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @isaUnderlying, varargin{:} );
        end

        function [varargout] = isempty( varargin )
        %ISEMPTY True for empty distributed array
        %   TF = ISEMPTY(D)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.zeros(N,0,N);
        %       t = isempty(D)
        %   
        %   returns t = true.
        %   
        %   See also ISEMPTY, DISTRIBUTED, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @isempty, varargin{:} );
        end

        function [varargout] = isequal( varargin )
        %ISEQUAL True if distributed arrays are numerically equal
        %   TF = ISEQUAL(A,B)
        %   TF = ISEQUAL(A,B,C,...)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.nan(N);
        %       f = isequal(D,D)
        %       t = isequalwithequalnans(D,D)
        %   
        %   returns f = false and t = true.
        %   
        %   See also ISEQUAL, DISTRIBUTED, DISTRIBUTED/NAN.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @isequal, varargin{:} );
        end

        function [varargout] = isequalwithequalnans( varargin )
        %ISEQUALWITHEQUALNANS True if distributed arrays are numerically equal
        %   TF = ISEQUALWITHEQUALNANS(A,B)
        %   TF = ISEQUALWITHEQUALNANS(A,B,C,...)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.nan(N);
        %       f = isequal(D,D)
        %       t = isequalwithequalnans(D,D)
        %   
        %   returns f = false and t = true.
        %   
        %   See also ISEQUALWITHEQUALNANS, DISTRIBUTED, DISTRIBUTED/NAN.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @isequalwithequalnans, varargin{:} );
        end

        function [varargout] = isfinite( varargin )
        %ISFINITE True for finite elements of distributed array
        %   TF = ISFINITE(D)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       T = isfinite(D)
        %   
        %   returns T = distributed.true(size(D)).
        %   
        %   See also ISFINITE, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @isfinite, varargin{:} );
        end

        function [varargout] = isinf( varargin )
        %ISINF True for infinite elements of distributed array
        %   TF = ISINF(D)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.inf(N);
        %       T = isinf(D)
        %   
        %   returns T = distributed.true(size(D)).
        %   
        %   See also ISINF, DISTRIBUTED, DISTRIBUTED/INF.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @isinf, varargin{:} );
        end

        function [varargout] = isnan( varargin )
        %ISNAN True for Not-a-Number elements of distributed array
        %   TF = ISNAN(D)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.nan(N);
        %       T = isnan(D)
        %   
        %   returns T = distributed.true(size(D)).
        %   
        %   See also ISNAN, DISTRIBUTED, DISTRIBUTED/NAN.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @isnan, varargin{:} );
        end

        function [varargout] = isreal( varargin )
        %ISREAL True for real distributed array
        %   TF = ISREAL(X)
        %   
        %   Example:
        %       N = 1000;
        %       rp = 3 * distributed.ones(N);
        %       ip = 4 * distributed.ones(N);
        %       D = complex(rp, ip);
        %       f = isreal(D)
        %   
        %   returns f = false.
        %   
        %   See also ISREAL, DISTRIBUTED, DISTRIBUTED/COMPLEX, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @isreal, varargin{:} );
        end

        function [varargout] = ldivide( varargin )
        %.\ Left array divide for distributed array matrix
        %   C = A .\ B
        %   C = LDIVIDE(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.colon(1, N)'
        %       D2 = D1 .\ 1 
        %   
        %   See also LDIVIDE, DISTRIBUTED, DISTRIBUTED/COLON.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @ldivide, varargin{:} );
        end

        function [varargout] = le( varargin )
        %<= Less than or equal for distributed array
        %   C = A <= B
        %   C = LE(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.rand(N);
        %       T = D <= D
        %       F = D <= D-0.5
        %   
        %   returns T = distributed.true(N)
        %   and F = distributed.false(N).
        %   
        %   See also LE, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @le, varargin{:} );
        end

        function [varargout] = log( varargin )
        %LOG Natural logarithm of distributed array
        %   Y = LOG(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N);
        %       E = log(D)
        %   
        %   See also LOG, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @log, varargin{:} );
        end

        function [varargout] = log10( varargin )
        %LOG10 Common (base 10) logarithm of distributed array
        %   Y = LOG10(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = 10.^distributed.colon(1,N);
        %       E = log10(D)
        %   
        %   See also LOG10, DISTRIBUTED, DISTRIBUTED/COLON.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @log10, varargin{:} );
        end

        function [varargout] = log1p( varargin )
        %LOG1P Compute log(1+z) accurately of distributed array
        %   Y = LOG1P(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = eps(1) .* distributed.ones(N);
        %       E = log1p(D)
        %   
        %   See also LOG1P, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @log1p, varargin{:} );
        end

        function [varargout] = log2( varargin )
        %LOG2 Base 2 logarithm and dissect floating point number of distributed array
        %   Y = LOG2(X)
        %   [F,E] = LOG2(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = 2.^distributed.colon(1, N);
        %       E = log2(D)
        %   
        %   See also LOG2, DISTRIBUTED, DISTRIBUTED/COLON.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @log2, varargin{:} );
        end

        function [varargout] = logical( varargin )
        %LOGICAL Convert numeric values of distributed array to logical
        %   L = LOGICAL(X)
        %   
        %   Example:
        %       N = 1000;
        %       Du = distributed.ones(N,'uint8');
        %       Dl = logical(Du)
        %       classDu = classUnderlying(Du)
        %       classDl = classUnderlying(Dl)
        %   
        %   converts the N-by-N uint8 distributed array Du to the
        %   logical distributed array Dl.
        %   classDu is 'uint8' while classDl is 'logical'.
        %   
        %   See also LOGICAL, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @logical, varargin{:} );
        end

        function [varargout] = lt( varargin )
        %< Less than for distributed array
        %   C = A < B
        %   C = LT(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.rand(N);
        %       T = D < D+0.5
        %       F = D < D
        %   
        %   returns T = distributed.true(N)
        %   and F = distributed.false(N).
        %   
        %   See also LT, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @lt, varargin{:} );
        end

        function [varargout] = lu( varargin )
        %LU LU factorization for distributed array
        %   [L,U,P] = LU(D, 'vector')
        %   
        %   D must be a full distributed matrix of floating point numbers (single or double).
        %   
        %   The following syntaxes are not supported for full distributed D:
        %   [...] = LU(D)
        %   [...] = LU(D,'matrix')
        %   X = LU(D,'vector')
        %   [L,U] = LU(D,'vector')
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.rand(N);
        %       [L,U,piv] = lu(D,'vector');
        %       norm(L*U-D(piv,:), 1)
        %   
        %   See also LU, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @lu, varargin{:} );
        end

        function [varargout] = mat2cell( varargin )
        %MAT2CELL Break distributed matrix up into a distributed cell array of underlying data.
        %   Not yet implemented.
        %   

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @mat2cell, varargin{:} );
        end

        function [varargout] = max( varargin )
        %MAX Largest component of distributed array
        %   Y = MAX(X)
        %   [Y,I] = MAX(X)
        %   [Y,I] = MAX(X,[],DIM)
        %   Z = MAX(X,Y)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed(magic(N))
        %       m = max(D)
        %       m1 = max(D,[],1)
        %       m2 = max(D,[],2)
        %   
        %   m and m1 are both distributed row vectors, m2 is a distributed column 
        %   vector.
        %   
        %   See also MAX, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @max, varargin{:} );
        end

        function [varargout] = min( varargin )
        %MIN Smallest component of distributed array
        %   Y = MIN(X)
        %   [Y,I] = MIN(X)
        %   [Y,I] = MIN(X,[],DIM)
        %   Z = MIN(X,Y)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed(magic(N))
        %       m = min(D)
        %       m1 = min(D,[],1)
        %       m2 = min(D,[],2)
        %   
        %   m and m1 are both distributed row vectors, m2 is a distributed column 
        %   vector.
        %   
        %   See also MIN, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.
        %   

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @min, varargin{:} );
        end

        function [varargout] = minus( varargin )
        %- Minus for distributed array
        %   C = A - B
        %   C = MINUS(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.ones(N);
        %       D2 = 2*D1
        %       D3 = D1 - D2
        %   
        %   See also MINUS, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @minus, varargin{:} );
        end

        function [varargout] = mldivide( varargin )
        %\ Backslash or left matrix divide for distributed arrays
        %   X = A \ B is the matrix division of A into B, where either A or B or both are
        %   distributed.  This is roughly the same as INV(A)*B, except it is computed in a 
        %   different way.  If A is an N-by-N matrix and B is a column vector with N
        %   components, or a matrix with several such columns, then X = A\B is the 
        %   solution to the equation A*X = B.  A\EYE(SIZE(A)) produces the inverse of A.
        %   
        %   If A is an M-by-N matrix with M < or > N and B is a column vector with M
        %   components, or a matrix with several such columns, then X=A\B is the solution
        %   in the least squares sense to the under- or over-determined system of 
        %   equations A*X = B.  A\EYE(SIZE(A)) produces a generalized inverse of A.
        %   
        %   X = MLDIVIDE(A,B) is called for the syntax A\B when A or B is an object.
        %   
        %   Example:
        %       N = 1000;
        %       A = distributed.rand(N);
        %       B = distributed.rand(N,1);
        %       X = A \ B
        %       norm(B-A*X, 1)
        %   
        %   See also MLDIVIDE, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @mldivide, varargin{:} );
        end

        function [varargout] = mod( varargin )
        %MOD Modulus after division of distributed array
        %   C = MOD(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D = mod(distributed.colon(1,N),2)
        %   
        %   See also MOD, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @mod, varargin{:} );
        end

        function [varargout] = mrdivide( varargin )
        %/ Slash or right matrix divide for distributed array
        %   C = A / B
        %   C = MRDIVIDE(A,B)
        %   
        %   B must be scalar.
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.colon(1, N)'
        %       D2 = D1 / 2
        %   
        %   See also MRDIVIDE, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @mrdivide, varargin{:} );
        end

        function [varargout] = mtimes( varargin )
        %* Matrix multiply for distributed array
        %   C = A * B
        %   C = MTIMES(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       A = distributed.rand(N)
        %       B = distributed.rand(N)
        %       C = A * B
        %   
        %   See also MTIMES, DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @mtimes, varargin{:} );
        end

        function [varargout] = ne( varargin )
        %~= Not equal for distributed array
        %   C = A ~= B
        %   C = NE(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.rand(N);
        %       F = D ~= D
        %       T = D ~= D'
        %   
        %   returns F = distributed.false(N) and T is probably the same as
        %   distributed.true(N), but with the main diagonal all false
        %   values.
        %   
        %   See also NE, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @ne, varargin{:} );
        end

        function [varargout] = nextpow2( varargin )
        %NEXTPOW2 Next higher power of 2 for distributed arrays
        %   
        %   Y = NEXTPOW2(X)
        %   
        %   Examples:
        %       D = distributed(pi)
        %       E = nextpow2(D)
        %   
        %       X = distributed.colon(1, 5)
        %       Y = nextpow2(X)
        %   
        %   See also NEXTPOW2, DISTRIBUTED, DISTRIBUTED/COLON.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @nextpow2, varargin{:} );
        end

        function [varargout] = nnz( varargin )
        %NNZ Number of nonzero distributed matrix elements
        %   N = NNZ(D)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.speye(N);
        %       n = nnz(D)
        %   
        %   returns n = N.
        %   
        %   t = issparse(D)
        %   
        %   returns t = true.
        %   
        %   See also NNZ, DISTRIBUTED, DISTRIBUTED/SPEYE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @nnz, varargin{:} );
        end

        function [varargout] = nonzeros( varargin )
        %NONZEROS Nonzero distributed matrix elements
        %   NZ = NONZEROS(D)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.speye(N);
        %       nz = nonzeros(D)
        %   
        %   returns nz = distributed.ones(N,1).
        %   
        %   t = issparse(D)
        %   
        %   returns t = true.
        %   
        %   See also NONZEROS, DISTRIBUTED, DISTRIBUTED/SPEYE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @nonzeros, varargin{:} );
        end

        function [varargout] = norm( varargin )
        %NORM Matrix or vector norm for distributed array
        %   All norms supported by the built-in function have been overloaded for distributed arrays.
        %   
        %   For matrices...
        %         N = NORM(D) is the 2-norm of D.
        %         N = NORM(D, 2) is the same as NORM(D).
        %         N = NORM(D, 1) is the 1-norm of D.
        %         N = NORM(D, inf) is the infinity norm of D.
        %         N = NORM(D, 'fro') is the Frobenius norm of D.
        %         N = NORM(D, P) is available for matrix D only if P is 1, 2, inf or 'fro'.
        %    
        %   For vectors...
        %         N = NORM(D, P) = sum(abs(D).^P)^(1/P).
        %         N = NORM(D) = norm(D, 2).
        %         N = NORM(D, inf) = max(abs(D)).
        %         N = NORM(D, -inf) = min(abs(D)).
        %   
        %   Example:
        %       N = 1000;
        %       D = diag(distributed.colon(1,N))
        %       n = norm(D,1)
        %   
        %   returns n = 1000.
        %   
        %   See also NORM, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @norm, varargin{:} );
        end

        function [varargout] = normest( varargin )
        %NORMEST Estimate the distributed matrix 2-norm
        %   N = NORMEST(D)
        %   
        %   Limitations: Matrix NORMEST will return slightly different results for the
        %   same matrix distributed over a different number of labs, or distributed in
        %   a different manner.
        %   
        %   Example:
        %       N = 1000;
        %       D = diag(distributed.colon(1,N))
        %       n = normest(D)
        %   
        %   returns n = 1000.
        %   
        %   See also NORMEST, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @normest, varargin{:} );
        end

        function [varargout] = not( varargin )
        %~ Logical NOT for distributed array
        %   B = ~A
        %   B = NOT(A)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.eye(N);
        %       E = ~D
        %   
        %   See also NOT, DISTRIBUTED, DISTRIBUTED/EYE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @not, varargin{:} );
        end

        function [varargout] = nthroot( varargin )
        %NTHROOT Real n-th root of real numbers
        %   Y = NTHROOT(X,N)
        %   
        %   Example:
        %       N = 1000;
        %       D = -2*distributed.ones(N);
        %       E = D.^(1/3)
        %       F = nthroot(D,3)
        %   
        %   See also NTHROOT, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @nthroot, varargin{:} );
        end

        function [varargout] = num2cell( varargin )
        %NUM2CELL Convert numeric distributed array into cell array
        %   C = NUM2CELL(A)
        %   C = NUM2CELL(A,DIMS)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.colon(1,N)
        %       C = num2cell(D)
        %       classD = classUnderlying(D)
        %       classC = classUnderlying(C)
        %   
        %   converts the distributed double row vector D to the distributed cell 
        %   array C. classD is 'double' while classC is 'cell'.
        %   
        %   See also NUM2CELL, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/CELL.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @num2cell, varargin{:} );
        end

        function [varargout] = nzmax( varargin )
        %NZMAX Amount of storage allocated for nonzero distributed matrix elements
        %   N = NZMAX(D)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.speye(N);
        %       n = nzmax(D)
        %   
        %   returns n = N.
        %   
        %   t = issparse(D)
        %   
        %   returns t = true.
        %   
        %   See also NZMAX, DISTRIBUTED, DISTRIBUTED/SPEYE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @nzmax, varargin{:} );
        end

        function [varargout] = or( varargin )
        %| Logical OR for distributed array
        %   C = A | B
        %   C = OR(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.eye(N);
        %       D2 = distributed.rand(N);
        %       D3 = D1 | D2
        %   
        %   returns D3 = distributed.true(N).
        %   
        %   See also OR, DISTRIBUTED, DISTRIBUTED/EYE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @or, varargin{:} );
        end

        function [varargout] = permute( varargin )
        %PERMUTE Permute distributed array dimensions
        %   Not yet implemented.
        %   

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @permute, varargin{:} );
        end

        function [varargout] = plus( varargin )
        %+ Plus for distributed array
        %   C = A + B
        %   C = PLUS(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.ones(N);
        %       D2 = 2*D1
        %       D3 = D1 + D2
        %   
        %   See also PLUS, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @plus, varargin{:} );
        end

        function [varargout] = pow2( varargin )
        %POW2 Base 2 power and scale floating point number for distributed array
        %   X = POW2(Y)
        %   X = POW2(F,E)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.colon(1, N)
        %       E = pow2(D)
        %   
        %   See also POW2, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @pow2, varargin{:} );
        end

        function [varargout] = power( varargin )
        %.^ Array power for distributed array
        %   C = A .^ B
        %   C = POWER(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = 2*distributed.eye(N);
        %       D2 = D1 .^ 2
        %   
        %   See also POWER, DISTRIBUTED, DISTRIBUTED/EYE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @power, varargin{:} );
        end

        function [varargout] = prod( varargin )
        %PROD Product of elements of distributed array
        %   PROD(X)
        %   PROD(X,DIM)
        %   
        %   Example:
        %       N = 1000;
        %       D = 4 * (distributed.colon(1, N) .^ 2);
        %       D2 = D ./ (D - 1);
        %       p = prod(D2)
        %   
        %   returns p as approximately pi/2 (by the Wallis product).
        %   
        %   See also PROD, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @prod, varargin{:} );
        end

        function [varargout] = qr( varargin )
        %QR Orthogonal-triangular decomposition for distributed matrix
        %   [Q,R] = QR(D)
        %   [Q,R] = QR(D,0)
        %   
        %   D must be a full distributed matrix of floating point numbers (single or double).
        %   
        %   The following syntaxes are not supported for full distributed D:
        %   [Q,R,E] = QR(D)
        %   [Q,R,E] = QR(D,0)
        %   X = QR(D)
        %   X = QR(D,0)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.rand(N);
        %       [Q,R] = qr(D)
        %       norm(Q*R-D)
        %   
        %   See also QR, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @qr, varargin{:} );
        end

        function [varargout] = rdivide( varargin )
        %./ Right array divide for distributed matrix
        %   C = A ./ B
        %   C = RDIVIDE(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.colon(1, N)'
        %       D2 = 1 ./ D1
        %   
        %   See also RDIVIDE, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @rdivide, varargin{:} );
        end

        function [varargout] = real( varargin )
        %REAL Complex real part of distributed array
        %   Y = REAL(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = complex(3*distributed.ones(N),4*distributed.ones(N))
        %       E = real(D)
        %   
        %   See also REAL, DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @real, varargin{:} );
        end

        function [varargout] = reallog( varargin )
        %REALLOG Real logarithm of distributed array
        %   Y = REALLOG(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = -exp(1)*distributed.ones(N)
        %       try reallog(D), catch, disp('negative input!'), end
        %       E = reallog(-D)
        %   
        %   See also REALLOG, DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @reallog, varargin{:} );
        end

        function [varargout] = realpow( varargin )
        %REALPOW Real power of distributed array
        %   Z = REALPOW(X,Y)
        %   
        %   Example:
        %       N = 1000;
        %       D = -8*distributed.ones(N)
        %       try realpow(D,1/3), catch, disp('complex output!'), end
        %       E = realpow(-D,1/3)
        %   
        %   See also REALPOW, DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @realpow, varargin{:} );
        end

        function [varargout] = realsqrt( varargin )
        %REALSQRT Real square root of distributed array
        %   Y = REALSQRT(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = -4*distributed.ones(N)
        %       try realsqrt(D), catch, disp('negative input!'), end
        %       E = realsqrt(-D)
        %   
        %   See also REALSQRT, DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @realsqrt, varargin{:} );
        end

        function [varargout] = rem( varargin )
        %REM Remainder after division for distributed array
        %   C = REM(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D = rem(distributed.colon(1, N),2)
        %   
        %   See also REM, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @rem, varargin{:} );
        end

        function [varargout] = reshape( varargin )
        %RESHAPE Change size of distributed array
        %   Not yet implemented.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @reshape, varargin{:} );
        end

        function [varargout] = rmfield( varargin )
        %RMFIELD Remove fields from a structure distributed array
        %   S = RMFIELD(S,'field')
        %   S = RMFIELD(S,FIELDS)
        %   
        %   Example:
        %       matrices = { 1,  2,  3,  4,  5,  6,  7,  8,  9,  10};
        %       names    = {'a','b','c','d','e','f','g','h','i','j'};
        %       s = struct('matrix', matrices, 'name', names);
        %       S = distributed(s)
        %       S = rmfield(S,'name')
        %       classS = classUnderlying(S)
        %   
        %   removes the field named 'name' from the distributed array of structs S.
        %   classS is 'struct'.
        %   
        %   See also RMFIELD, DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @rmfield, varargin{:} );
        end

        function [varargout] = round( varargin )
        %ROUND Round towards nearest integer for distributed array
        %   Y = ROUND(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.colon(1, N)./2
        %       E = round(D)
        %   
        %   See also ROUND, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @round, varargin{:} );
        end

        function [varargout] = sec( varargin )
        %SEC Secant of distributed array in radians
        %   Y = SEC(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.zeros(N);
        %       E = sec(D)
        %   
        %   See also SEC, DISTRIBUTED, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @sec, varargin{:} );
        end

        function [varargout] = secd( varargin )
        %SECD Secant of distributed array in degrees
        %   Y = SECD(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.zeros(N);
        %       E = secd(D)
        %   
        %   See also SECD, DISTRIBUTED, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @secd, varargin{:} );
        end

        function [varargout] = sech( varargin )
        %SECH Hyperbolic secant of distributed array
        %   Y = SECH(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.zeros(N);
        %       E = sech(D)
        %   
        %   See also SECH, DISTRIBUTED, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @sech, varargin{:} );
        end

        function [varargout] = sign( varargin )
        %SIGN Signum function for distributed array
        %   Y = SIGN(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.colon(1, N) - ceil(N/2)
        %       E = sign(D)
        %   
        %   See also SIGN, DISTRIBUTED, DISTRIBUTED/COLON, DISTRIBUTED/ZEROS.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @sign, varargin{:} );
        end

        function [varargout] = sin( varargin )
        %SIN Sine of distributed array in radians
        %   Y = SIN(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = pi/2*distributed.ones(N);
        %       E = sin(D)
        %   
        %   See also SIN, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @sin, varargin{:} );
        end

        function [varargout] = sind( varargin )
        %SIND Sine of distributed array in degrees
        %   Y = SIND(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = pi/2*distributed.ones(N);
        %       E = sind(D)
        %   
        %   See also SIND, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @sind, varargin{:} );
        end

        function [varargout] = single( varargin )
        %SINGLE Convert distributed array to single precision
        %   S = SINGLE(X)
        %   
        %   Example:
        %       N = 1000;
        %       Du = distributed.ones(N,'uint32');
        %       Ds = single(Du)
        %       classDu = classUnderlying(Du)
        %       classDs = classUnderlying(Ds)
        %   
        %   converts the N-by-N uint32 distributed array Du to the
        %   single distributed array Ds.
        %   classDu is 'uint32' while classDs is 'single'.
        %   
        %   See also SINGLE, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @single, varargin{:} );
        end

        function [varargout] = sinh( varargin )
        %SINH Hyperbolic sine of distributed array
        %   Y = SINH(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.inf(N);
        %       E = sinh(D)
        %   
        %   See also SINH, DISTRIBUTED, DISTRIBUTED/INF.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @sinh, varargin{:} );
        end

        function [varargout] = sparse( varargin )
        %SPARSE Create sparse distributed matrix
        %   SD = SPARSE(FD) converts a full distributed array FD to a sparse
        %   distributed array SD.
        %   
        %   The following syntaxes are not supported for distributed arrays:
        %   S = SPARSE(ROWS,COLS,VALS,M,N,NZMAX)
        %   S = SPARSE(ROWS,COLS,VALS,M,N)
        %   S = SPARSE(ROWS,COLS,VALS)
        %   
        %   Conversion Example:
        %   N = 1000;
        %   D = distributed.eye(N);
        %   S = sparse(D)
        %   
        %   returns S = distributed.speye(N).
        %   
        %   f = issparse(D)
        %   t = issparse(S)
        %   
        %   returns f = false and t = true.
        %   
        %   See also SPARSE, DISTRIBUTED, DISTRIBUTED/EYE, DISTRIBUTED/SPEYE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @sparse, varargin{:} );
        end

        function [varargout] = spfun( varargin )
        %SPFUN Apply function to nonzero distributed matrix elements
        %   D2 = SPFUN(FUN,D)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.sprand(N, N, 0.2)
        %       F = spfun(@exp, D)
        %   
        %   F has the same sparsity pattern as D (except for underflow), whereas 
        %   EXP(D) has 1's where D has 0's.
        %   
        %   See also SPFUN, DISTRIBUTED, DISTRIBUTED/SPRAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @spfun, varargin{:} );
        end

        function [varargout] = spones( varargin )
        %SPONES Replace nonzero sparse distributed matrix elements with ones
        %   D2 = SPONES(D)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.sprand(N,N,1/N);
        %       D2 = spones(D1)
        %   
        %   returns D2 with the same sparsity structure as D1, but 1's in the nonzero
        %   positions.
        %   
        %   t1 = issparse(D1)
        %   t2 = issparse(D2)
        %   
        %   returns t1 and t2 both equal to true.
        %   
        %   See also SPONES, DISTRIBUTED, DISTRIBUTED/SPRAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @spones, varargin{:} );
        end

        function [varargout] = sqrt( varargin )
        %SQRT Square root of distributed array
        %   Y = SQRT(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = -distributed.ones(N)
        %       E = sqrt(D)
        %   
        %   See also SQRT, DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @sqrt, varargin{:} );
        end

        function [varargout] = struct2cell( varargin )
        %STRUCT2CELL Convert structure distributed array to cell distributed array
        %   C = STRUCT2CELL(S)
        %   
        %   If the original struct array is distributed along dimension DIM, the
        %   resulting cell array will be distributed along dimension DIM+1.
        %   
        %   Example:
        %       matrices = { 1,  2,  3,  4,  5,  6,  7,  8,  9,  10};
        %       names    = {'a','b','c','d','e','f','g','h','i','j'};
        %       s = struct('matrix', matrices, 'name', names);
        %       S = distributed(s)
        %       C = struct2cell(S)
        %       classS = classUnderlying(S)
        %       classC = classUnderlying(C)
        %   
        %   converts the 1-by-10 distributed array of structs S to the
        %   2-by-1-by-10 distributed cell array C.
        %   classS is 'struct' while classC is 'cell'.
        %   
        %   See also STRUCT2CELL, DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @struct2cell, varargin{:} );
        end

        function [varargout] = subsindex( varargin )
        %SUBSINDEX Subscript index for distributed array
        %   
        %   OUTIDX = SUBSINDEX(INIDX) accepts a distributed input INIDX, and returns the 
        %   index OUTIDX of zero-based integer values for use in indexing.  The 
        %   class of OUTIDX is the same as the underlying class of INIDX.  
        %   
        %   See also DISTRIBUTED.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @subsindex, varargin{:} );
        end

        function [varargout] = sum( varargin )
        %SUM Sum of elements of distributed array
        %   SUM(X)
        %   SUM(X,'double')
        %   SUM(X,'native')
        %   SUM(X,DIM)
        %   SUM(X,DIM,'double')
        %   SUM(X,DIM,'native')
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.colon(1,N)
        %       s = sum(D)
        %   
        %   returns s = (1+1000)*1000/2 = 500500.
        %   
        %   The order of the additions within the SUM operation is not defined, so
        %   the SUM operation on distributed array might not return exactly the same 
        %   answer as the SUM operation on the corresponding MATLAB numeric array.
        %   In particular, the differences might be significant when X is a signed
        %   integer type and its sum is accumulated natively.
        %   
        %   See also SUM, DISTRIBUTED, DISTRIBUTED/ZEROS.
        %   
        %   

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @sum, varargin{:} );
        end

        function [varargout] = svd( varargin )
        %SVD Singular value decomposition of distributed matrix
        %   If A is square, S = SVD(A) returns the singular values of A, and 
        %   [U,S,V] = SVD(A) returns the singular value decomposition of A.
        %   
        %   If A is rectangular, you must specify "economy size" decomposition.
        %   [U,S,V] = SVD(A,'econ')
        %   
        %   [U,S,V] = SVD(A, 0) is not supported.
        %       
        %   Example:
        %   % Compute a real square matrix A, its singular values S, and singular
        %   % vectors U and V such that A*V is within round-off error of U*S.
        %       N = 1000;
        %       A = distributed.rand(N);
        %       [U,S,V] = svd(A)
        %       norm(A*V-U*S)
        %   
        %   
        %   See also SVD, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @svd, varargin{:} );
        end

        function [varargout] = swapbytes( varargin )
        %SWAPBYTES Swap byte ordering, changing endianness of distributed array
        %   Y = SWAPBYTES(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.ones(N,'uint16');
        %       E = swapbytes(D)
        %       classD = classUnderlying(D)
        %       classE = classUnderlying(E)
        %   
        %   swaps the bytes of the uint16(1) values of D into uint16(256).
        %   classD and classE are both uint16.
        %   
        %   See also SWAPBYTES, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @swapbytes, varargin{:} );
        end

        function [varargout] = tan( varargin )
        %TAN Tangent of distributed array in radians
        %   Y = TAN(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = pi/4*distributed.ones(N);
        %       E = tan(D)
        %   
        %   See also TAN, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @tan, varargin{:} );
        end

        function [varargout] = tand( varargin )
        %TAND Tangent of distributed array in degrees
        %   Y = TAND(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = 45*distributed.ones(N);
        %       E = tand(D)
        %   
        %   See also TAND, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @tand, varargin{:} );
        end

        function [varargout] = tanh( varargin )
        %TANH Hyperbolic tangent of distributed array
        %   Y = TANH(X)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.inf(N);
        %       E = tanh(D)
        %   
        %   See also TANH, DISTRIBUTED, DISTRIBUTED/INF.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @tanh, varargin{:} );
        end

        function [varargout] = times( varargin )
        %.* distributed array multiply
        %   C = A .* B
        %   C = TIMES(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.eye(N);
        %       D2 = distributed.rand(N);
        %       D3 = D1 .* D2
        %   
        %   See also TIMES, DISTRIBUTED, DISTRIBUTED/EYE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @times, varargin{:} );
        end

        function [varargout] = transpose( varargin )
        %.' Transpose of distributed array
        %   E = D.'
        %   E = TRANSPOSE(D)
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.rand(N);
        %       E = D.'
        %   
        %   See also TRANSPOSE, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @transpose, varargin{:} );
        end

        function [varargout] = tril( varargin )
        %TRIL Extract lower triangular part of distributed array
        %   T = TRIL(A,K) yields the elements on and below the K-th diagonal of A. 
        %   K = 0 is the main diagonal, K > 0 is above the main diagonal and K < 0
        %   is below the main diagonal.
        %   T = TRIL(A) is the same as T = TRIL(A,0) where T is the lower triangular 
        %   part of A.
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.rand(N);
        %       T1 = tril(D,1)
        %       Tm1 = tril(D,-1)
        %   
        %   See also TRIL, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @tril, varargin{:} );
        end

        function [varargout] = triu( varargin )
        %TRIU Extract upper triangular part of distributed array
        %   T = TRIU(A,K) yields the elements on and above the K-th diagonal of A. 
        %   K = 0 is the main diagonal, K > 0 is above the main diagonal and K < 0
        %   is below the main diagonal.
        %   T = TRIU(A) is the same as T = TRIU(A,0) where T is the upper triangular 
        %   part of A.
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.rand(N);
        %       T1 = triu(D,1)
        %       Tm1 = triu(D,-1)
        %   
        %   See also TRIU, DISTRIBUTED, DISTRIBUTED/RAND.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @triu, varargin{:} );
        end

        function [varargout] = typecast( varargin )
        %TYPECAST Convert datatypes of distributed array without changing underlying data
        %   Y = TYPECAST(X, DATATYPE)
        %   
        %   Example:
        %       N = 1000;
        %       Di = -1*distributed.ones(1,N,'int8');
        %       Du = typecast(Di,'uint8')
        %       classDi = classUnderlying(Di)
        %       classDu = classUnderlying(Du)
        %   
        %   type casts the 1-by-N distributed uint8 row vector Du to the
        %   distributed int8 array Di.
        %   Di has all values -1 while Du has all values 255.
        %   classDi is 'int8' while classDu is 'uint8'.
        %   
        %   See also TYPECAST, DISTRIBUTED, DISTRIBUTED/ONES, 
        %   DISTRIBUTED/CLASSUNDERLYING.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @typecast, varargin{:} );
        end

        function [varargout] = uint16( varargin )
        %UINT16 Convert distributed array to unsigned 16-bit integer
        %   I = UINT16(X)
        %   
        %   Example:
        %       N = 1000;
        %       Di = distributed.ones(N,'int16');
        %       Du = uint16(Di)
        %       classDi = classUnderlying(Di)
        %       classDu = classUnderlying(Du)
        %   
        %   converts the N-by-N int16 distributed array Di to the
        %   uint16 distributed array Du.
        %   classDi is 'int16' while classDu is 'uint16'.
        %   
        %   See also UINT16, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @uint16, varargin{:} );
        end

        function [varargout] = uint32( varargin )
        %UINT32 Convert distributed array to unsigned 32-bit integer
        %   I = UINT32(X)
        %   
        %   Example:
        %       N = 1000;
        %       Di = distributed.ones(N,'int32');
        %       Du = uint32(Di)
        %       classDi = classUnderlying(Di)
        %       classDu = classUnderlying(Du)
        %   
        %   converts the N-by-N int32 distributed array Di to the
        %   uint32 distributed array Du.
        %   classDi is 'int32' while classDu is 'uint32'.
        %   
        %   See also UINT32, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @uint32, varargin{:} );
        end

        function [varargout] = uint64( varargin )
        %UINT64 Convert distributed array to unsigned 64-bit integer
        %   I = UINT64(X)
        %   
        %   Example:
        %       N = 1000;
        %       Di = distributed.ones(N,'int64');
        %       Du = uint64(Di)
        %       classDi = classUnderlying(Di)
        %       classDu = classUnderlying(Du)
        %   
        %   converts the N-by-N int64 distributed array Di to the
        %   uint64 distributed array Du.
        %   classDi is 'int64' while classDu is 'uint64'.
        %   
        %   See also UINT64, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @uint64, varargin{:} );
        end

        function [varargout] = uint8( varargin )
        %UINT8 Convert distributed array to unsigned 8-bit integer
        %   I = UINT8(X)
        %   
        %   Example:
        %       N = 1000;
        %       Di = distributed.ones(N,'int8');
        %       Du = uint8(Di)
        %       classDi = classUnderlying(Di)
        %       classDu = classUnderlying(Du)
        %   
        %   converts the N-by-N int8 distributed array Di to the
        %   uint8 distributed array Du.
        %   classDi is 'int8' while classDu is 'uint8'.
        %   
        %   See also UINT8, DISTRIBUTED, DISTRIBUTED/ONES.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @uint8, varargin{:} );
        end

        function [varargout] = uminus( varargin )
        %- Unary minus for distributed arrays
        %   B = -A
        %   B = UMINUS(A)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.eye(N);
        %       D2 = -D1
        %   
        %   See also UMINUS, DISTRIBUTED, DISTRIBUTED/EYE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @uminus, varargin{:} );
        end

        function [varargout] = uplus( varargin )
        %+ Unary plus for distributed array
        %   B = +A
        %   B = UPLUS(A)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.eye(N);
        %       D2 = +D1
        %   
        %   See also UPLUS, DISTRIBUTED, DISTRIBUTED/EYE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @uplus, varargin{:} );
        end

        function [varargout] = vertcat( varargin )
        %VERTCAT Vertical concatenation for distributed array
        %   C = VERTCAT(A,B,...) implements [A; B; ...] for distributed arrays.
        %   
        %   Example:
        %       N = 1000;
        %       D = distributed.eye(N);
        %       D2 = [D; D] % a 2000-by-1000 distributed matrix
        %   
        %   See also VERTCAT, DISTRIBUTED, DISTRIBUTED/CAT.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @vertcat, varargin{:} );
        end

        function [varargout] = xor( varargin )
        %XOR Logical EXCLUSIVE OR for distributed array
        %   C = XOR(A,B)
        %   
        %   Example:
        %       N = 1000;
        %       D1 = distributed.eye(N);
        %       D2 = distributed.rand(N);
        %       D3 = xor(D1,D2)
        %   
        %   See also XOR, DISTRIBUTED, DISTRIBUTED/EYE.

            varargout = cell( 1, max( nargout, 1 ) );
            [varargout{:}] = wrapRemoteCall( @xor, varargin{:} );
        end

        function [varargout] = plot( varargin )
        %PLOT   Overloaded for distributed arrays
        %   See documentation for PLOT for details
        %
        % See also PLOT.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = plot( args{:} );
        end

        function [varargout] = loglog( varargin )
        %LOGLOG   Overloaded for distributed arrays
        %   See documentation for LOGLOG for details
        %
        % See also LOGLOG.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = loglog( args{:} );
        end

        function [varargout] = semilogy( varargin )
        %SEMILOGY   Overloaded for distributed arrays
        %   See documentation for SEMILOGY for details
        %
        % See also SEMILOGY.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = semilogy( args{:} );
        end

        function [varargout] = semilogx( varargin )
        %SEMILOGX   Overloaded for distributed arrays
        %   See documentation for SEMILOGX for details
        %
        % See also SEMILOGX.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = semilogx( args{:} );
        end

        function [varargout] = polar( varargin )
        %POLAR   Overloaded for distributed arrays
        %   See documentation for POLAR for details
        %
        % See also POLAR.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = polar( args{:} );
        end

        function [varargout] = plotyy( varargin )
        %PLOTYY   Overloaded for distributed arrays
        %   See documentation for PLOTYY for details
        %
        % See also PLOTYY.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = plotyy( args{:} );
        end

        function [varargout] = plot3( varargin )
        %PLOT3   Overloaded for distributed arrays
        %   See documentation for PLOT3 for details
        %
        % See also PLOT3.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = plot3( args{:} );
        end

        function [varargout] = mesh( varargin )
        %MESH   Overloaded for distributed arrays
        %   See documentation for MESH for details
        %
        % See also MESH.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = mesh( args{:} );
        end

        function [varargout] = surf( varargin )
        %SURF   Overloaded for distributed arrays
        %   See documentation for SURF for details
        %
        % See also SURF.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = surf( args{:} );
        end

        function [varargout] = fill3( varargin )
        %FILL3   Overloaded for distributed arrays
        %   See documentation for FILL3 for details
        %
        % See also FILL3.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = fill3( args{:} );
        end

        function [varargout] = surfl( varargin )
        %SURFL   Overloaded for distributed arrays
        %   See documentation for SURFL for details
        %
        % See also SURFL.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = surfl( args{:} );
        end

        function [varargout] = area( varargin )
        %AREA   Overloaded for distributed arrays
        %   See documentation for AREA for details
        %
        % See also AREA.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = area( args{:} );
        end

        function [varargout] = bar( varargin )
        %BAR   Overloaded for distributed arrays
        %   See documentation for BAR for details
        %
        % See also BAR.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = bar( args{:} );
        end

        function [varargout] = barh( varargin )
        %BARH   Overloaded for distributed arrays
        %   See documentation for BARH for details
        %
        % See also BARH.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = barh( args{:} );
        end

        function [varargout] = comet( varargin )
        %COMET   Overloaded for distributed arrays
        %   See documentation for COMET for details
        %
        % See also COMET.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = comet( args{:} );
        end

        function [varargout] = compass( varargin )
        %COMPASS   Overloaded for distributed arrays
        %   See documentation for COMPASS for details
        %
        % See also COMPASS.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = compass( args{:} );
        end

        function [varargout] = errorbar( varargin )
        %ERRORBAR   Overloaded for distributed arrays
        %   See documentation for ERRORBAR for details
        %
        % See also ERRORBAR.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = errorbar( args{:} );
        end

        function [varargout] = ezplot( varargin )
        %EZPLOT   Overloaded for distributed arrays
        %   See documentation for EZPLOT for details
        %
        % See also EZPLOT.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = ezplot( args{:} );
        end

        function [varargout] = ezpolar( varargin )
        %EZPOLAR   Overloaded for distributed arrays
        %   See documentation for EZPOLAR for details
        %
        % See also EZPOLAR.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = ezpolar( args{:} );
        end

        function [varargout] = feather( varargin )
        %FEATHER   Overloaded for distributed arrays
        %   See documentation for FEATHER for details
        %
        % See also FEATHER.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = feather( args{:} );
        end

        function [varargout] = fill( varargin )
        %FILL   Overloaded for distributed arrays
        %   See documentation for FILL for details
        %
        % See also FILL.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = fill( args{:} );
        end

        function [varargout] = fplot( varargin )
        %FPLOT   Overloaded for distributed arrays
        %   See documentation for FPLOT for details
        %
        % See also FPLOT.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = fplot( args{:} );
        end

        function [varargout] = hist( varargin )
        %HIST   Overloaded for distributed arrays
        %   See documentation for HIST for details
        %
        % See also HIST.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = hist( args{:} );
        end

        function [varargout] = pareto( varargin )
        %PARETO   Overloaded for distributed arrays
        %   See documentation for PARETO for details
        %
        % See also PARETO.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = pareto( args{:} );
        end

        function [varargout] = pie( varargin )
        %PIE   Overloaded for distributed arrays
        %   See documentation for PIE for details
        %
        % See also PIE.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = pie( args{:} );
        end

        function [varargout] = plotmatrix( varargin )
        %PLOTMATRIX   Overloaded for distributed arrays
        %   See documentation for PLOTMATRIX for details
        %
        % See also PLOTMATRIX.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = plotmatrix( args{:} );
        end

        function [varargout] = rose( varargin )
        %ROSE   Overloaded for distributed arrays
        %   See documentation for ROSE for details
        %
        % See also ROSE.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = rose( args{:} );
        end

        function [varargout] = stem( varargin )
        %STEM   Overloaded for distributed arrays
        %   See documentation for STEM for details
        %
        % See also STEM.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = stem( args{:} );
        end

        function [varargout] = stairs( varargin )
        %STAIRS   Overloaded for distributed arrays
        %   See documentation for STAIRS for details
        %
        % See also STAIRS.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = stairs( args{:} );
        end

        function [varargout] = contour( varargin )
        %CONTOUR   Overloaded for distributed arrays
        %   See documentation for CONTOUR for details
        %
        % See also CONTOUR.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = contour( args{:} );
        end

        function [varargout] = contourc( varargin )
        %CONTOURC   Overloaded for distributed arrays
        %   See documentation for CONTOURC for details
        %
        % See also CONTOURC.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = contourc( args{:} );
        end

        function [varargout] = contourf( varargin )
        %CONTOURF   Overloaded for distributed arrays
        %   See documentation for CONTOURF for details
        %
        % See also CONTOURF.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = contourf( args{:} );
        end

        function [varargout] = contour3( varargin )
        %CONTOUR3   Overloaded for distributed arrays
        %   See documentation for CONTOUR3 for details
        %
        % See also CONTOUR3.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = contour3( args{:} );
        end

        function [varargout] = clabel( varargin )
        %CLABEL   Overloaded for distributed arrays
        %   See documentation for CLABEL for details
        %
        % See also CLABEL.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = clabel( args{:} );
        end

        function [varargout] = ezcontour( varargin )
        %EZCONTOUR   Overloaded for distributed arrays
        %   See documentation for EZCONTOUR for details
        %
        % See also EZCONTOUR.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = ezcontour( args{:} );
        end

        function [varargout] = ezcontourf( varargin )
        %EZCONTOURF   Overloaded for distributed arrays
        %   See documentation for EZCONTOURF for details
        %
        % See also EZCONTOURF.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = ezcontourf( args{:} );
        end

        function [varargout] = pcolor( varargin )
        %PCOLOR   Overloaded for distributed arrays
        %   See documentation for PCOLOR for details
        %
        % See also PCOLOR.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = pcolor( args{:} );
        end

        function [varargout] = voronoi( varargin )
        %VORONOI   Overloaded for distributed arrays
        %   See documentation for VORONOI for details
        %
        % See also VORONOI.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = voronoi( args{:} );
        end

        function [varargout] = bar3( varargin )
        %BAR3   Overloaded for distributed arrays
        %   See documentation for BAR3 for details
        %
        % See also BAR3.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = bar3( args{:} );
        end

        function [varargout] = bar3h( varargin )
        %BAR3H   Overloaded for distributed arrays
        %   See documentation for BAR3H for details
        %
        % See also BAR3H.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = bar3h( args{:} );
        end

        function [varargout] = comet3( varargin )
        %COMET3   Overloaded for distributed arrays
        %   See documentation for COMET3 for details
        %
        % See also COMET3.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = comet3( args{:} );
        end

        function [varargout] = ezgraph3( varargin )
        %EZGRAPH3   Overloaded for distributed arrays
        %   See documentation for EZGRAPH3 for details
        %
        % See also EZGRAPH3.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = ezgraph3( args{:} );
        end

        function [varargout] = ezmesh( varargin )
        %EZMESH   Overloaded for distributed arrays
        %   See documentation for EZMESH for details
        %
        % See also EZMESH.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = ezmesh( args{:} );
        end

        function [varargout] = ezmeshc( varargin )
        %EZMESHC   Overloaded for distributed arrays
        %   See documentation for EZMESHC for details
        %
        % See also EZMESHC.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = ezmeshc( args{:} );
        end

        function [varargout] = ezplot3( varargin )
        %EZPLOT3   Overloaded for distributed arrays
        %   See documentation for EZPLOT3 for details
        %
        % See also EZPLOT3.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = ezplot3( args{:} );
        end

        function [varargout] = ezsurf( varargin )
        %EZSURF   Overloaded for distributed arrays
        %   See documentation for EZSURF for details
        %
        % See also EZSURF.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = ezsurf( args{:} );
        end

        function [varargout] = ezsurfc( varargin )
        %EZSURFC   Overloaded for distributed arrays
        %   See documentation for EZSURFC for details
        %
        % See also EZSURFC.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = ezsurfc( args{:} );
        end

        function [varargout] = meshc( varargin )
        %MESHC   Overloaded for distributed arrays
        %   See documentation for MESHC for details
        %
        % See also MESHC.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = meshc( args{:} );
        end

        function [varargout] = meshz( varargin )
        %MESHZ   Overloaded for distributed arrays
        %   See documentation for MESHZ for details
        %
        % See also MESHZ.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = meshz( args{:} );
        end

        function [varargout] = pie3( varargin )
        %PIE3   Overloaded for distributed arrays
        %   See documentation for PIE3 for details
        %
        % See also PIE3.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = pie3( args{:} );
        end

        function [varargout] = ribbon( varargin )
        %RIBBON   Overloaded for distributed arrays
        %   See documentation for RIBBON for details
        %
        % See also RIBBON.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = ribbon( args{:} );
        end

        function [varargout] = scatter3( varargin )
        %SCATTER3   Overloaded for distributed arrays
        %   See documentation for SCATTER3 for details
        %
        % See also SCATTER3.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = scatter3( args{:} );
        end

        function [varargout] = stem3( varargin )
        %STEM3   Overloaded for distributed arrays
        %   See documentation for STEM3 for details
        %
        % See also STEM3.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = stem3( args{:} );
        end

        function [varargout] = surfc( varargin )
        %SURFC   Overloaded for distributed arrays
        %   See documentation for SURFC for details
        %
        % See also SURFC.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = surfc( args{:} );
        end

        function [varargout] = trisurf( varargin )
        %TRISURF   Overloaded for distributed arrays
        %   See documentation for TRISURF for details
        %
        % See also TRISURF.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = trisurf( args{:} );
        end

        function [varargout] = trimesh( varargin )
        %TRIMESH   Overloaded for distributed arrays
        %   See documentation for TRIMESH for details
        %
        % See also TRIMESH.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = trimesh( args{:} );
        end

        function [varargout] = waterfall( varargin )
        %WATERFALL   Overloaded for distributed arrays
        %   See documentation for WATERFALL for details
        %
        % See also WATERFALL.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = waterfall( args{:} );
        end

        function [varargout] = vissuite( varargin )
        %VISSUITE   Overloaded for distributed arrays
        %   See documentation for VISSUITE for details
        %
        % See also VISSUITE.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = vissuite( args{:} );
        end

        function [varargout] = isosurface( varargin )
        %ISOSURFACE   Overloaded for distributed arrays
        %   See documentation for ISOSURFACE for details
        %
        % See also ISOSURFACE.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = isosurface( args{:} );
        end

        function [varargout] = isonormals( varargin )
        %ISONORMALS   Overloaded for distributed arrays
        %   See documentation for ISONORMALS for details
        %
        % See also ISONORMALS.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = isonormals( args{:} );
        end

        function [varargout] = isocaps( varargin )
        %ISOCAPS   Overloaded for distributed arrays
        %   See documentation for ISOCAPS for details
        %
        % See also ISOCAPS.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = isocaps( args{:} );
        end

        function [varargout] = isocolors( varargin )
        %ISOCOLORS   Overloaded for distributed arrays
        %   See documentation for ISOCOLORS for details
        %
        % See also ISOCOLORS.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = isocolors( args{:} );
        end

        function [varargout] = contourslice( varargin )
        %CONTOURSLICE   Overloaded for distributed arrays
        %   See documentation for CONTOURSLICE for details
        %
        % See also CONTOURSLICE.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = contourslice( args{:} );
        end

        function [varargout] = slice( varargin )
        %SLICE   Overloaded for distributed arrays
        %   See documentation for SLICE for details
        %
        % See also SLICE.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = slice( args{:} );
        end

        function [varargout] = streamline( varargin )
        %STREAMLINE   Overloaded for distributed arrays
        %   See documentation for STREAMLINE for details
        %
        % See also STREAMLINE.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = streamline( args{:} );
        end

        function [varargout] = stream3( varargin )
        %STREAM3   Overloaded for distributed arrays
        %   See documentation for STREAM3 for details
        %
        % See also STREAM3.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = stream3( args{:} );
        end

        function [varargout] = stream2( varargin )
        %STREAM2   Overloaded for distributed arrays
        %   See documentation for STREAM2 for details
        %
        % See also STREAM2.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = stream2( args{:} );
        end

        function [varargout] = quiver3( varargin )
        %QUIVER3   Overloaded for distributed arrays
        %   See documentation for QUIVER3 for details
        %
        % See also QUIVER3.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = quiver3( args{:} );
        end

        function [varargout] = quiver( varargin )
        %QUIVER   Overloaded for distributed arrays
        %   See documentation for QUIVER for details
        %
        % See also QUIVER.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = quiver( args{:} );
        end

        function [varargout] = divergence( varargin )
        %DIVERGENCE   Overloaded for distributed arrays
        %   See documentation for DIVERGENCE for details
        %
        % See also DIVERGENCE.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = divergence( args{:} );
        end

        function [varargout] = curl( varargin )
        %CURL   Overloaded for distributed arrays
        %   See documentation for CURL for details
        %
        % See also CURL.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = curl( args{:} );
        end

        function [varargout] = coneplot( varargin )
        %CONEPLOT   Overloaded for distributed arrays
        %   See documentation for CONEPLOT for details
        %
        % See also CONEPLOT.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = coneplot( args{:} );
        end

        function [varargout] = streamtube( varargin )
        %STREAMTUBE   Overloaded for distributed arrays
        %   See documentation for STREAMTUBE for details
        %
        % See also STREAMTUBE.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = streamtube( args{:} );
        end

        function [varargout] = streamribbon( varargin )
        %STREAMRIBBON   Overloaded for distributed arrays
        %   See documentation for STREAMRIBBON for details
        %
        % See also STREAMRIBBON.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = streamribbon( args{:} );
        end

        function [varargout] = streamslice( varargin )
        %STREAMSLICE   Overloaded for distributed arrays
        %   See documentation for STREAMSLICE for details
        %
        % See also STREAMSLICE.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = streamslice( args{:} );
        end

        function [varargout] = streamparticles( varargin )
        %STREAMPARTICLES   Overloaded for distributed arrays
        %   See documentation for STREAMPARTICLES for details
        %
        % See also STREAMPARTICLES.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = streamparticles( args{:} );
        end

        function [varargout] = interpstreamspeed( varargin )
        %INTERPSTREAMSPEED   Overloaded for distributed arrays
        %   See documentation for INTERPSTREAMSPEED for details
        %
        % See also INTERPSTREAMSPEED.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = interpstreamspeed( args{:} );
        end

        function [varargout] = subvolume( varargin )
        %SUBVOLUME   Overloaded for distributed arrays
        %   See documentation for SUBVOLUME for details
        %
        % See also SUBVOLUME.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = subvolume( args{:} );
        end

        function [varargout] = reducevolume( varargin )
        %REDUCEVOLUME   Overloaded for distributed arrays
        %   See documentation for REDUCEVOLUME for details
        %
        % See also REDUCEVOLUME.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = reducevolume( args{:} );
        end

        function [varargout] = volumebounds( varargin )
        %VOLUMEBOUNDS   Overloaded for distributed arrays
        %   See documentation for VOLUMEBOUNDS for details
        %
        % See also VOLUMEBOUNDS.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = volumebounds( args{:} );
        end

        function [varargout] = smooth3( varargin )
        %SMOOTH3   Overloaded for distributed arrays
        %   See documentation for SMOOTH3 for details
        %
        % See also SMOOTH3.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = smooth3( args{:} );
        end

        function [varargout] = reducepatch( varargin )
        %REDUCEPATCH   Overloaded for distributed arrays
        %   See documentation for REDUCEPATCH for details
        %
        % See also REDUCEPATCH.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = reducepatch( args{:} );
        end

        function [varargout] = shrinkfaces( varargin )
        %SHRINKFACES   Overloaded for distributed arrays
        %   See documentation for SHRINKFACES for details
        %
        % See also SHRINKFACES.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = shrinkfaces( args{:} );
        end

        function [varargout] = image( varargin )
        %IMAGE   Overloaded for distributed arrays
        %   See documentation for IMAGE for details
        %
        % See also IMAGE.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = image( args{:} );
        end

        function [varargout] = imagesc( varargin )
        %IMAGESC   Overloaded for distributed arrays
        %   See documentation for IMAGESC for details
        %
        % See also IMAGESC.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = imagesc( args{:} );
        end

        function [varargout] = spy( varargin )
        %SPY   Overloaded for distributed arrays
        %   See documentation for SPY for details
        %
        % See also SPY.

            args = gatherIfNecessary( varargin{:} );
            varargout = cell( 1, nargout );
            [varargout{:}] = spy( args{:} );
        end

    end % generated public methods

    methods (Access = private)
        varargout = dispInternal( varargin );
        varargout = gatherIfNecessary( varargin );
        varargout = transferPortion( varargin );
        varargout = wrapRemoteCall( varargin );
    end % private methods

    methods (Access = private, Static)
        varargout = sBuild( varargin );
        varargout = sBuildArgChk( varargin );
    end % static private methods

    % Static method declarations
    methods (Access = public, Static)
        % Methods taking only size-type arguments:
        D = true( varargin );
        D = false( varargin );
        
        % Cell
        D = cell( varargin );
        
        % Methods taking size and optional class
        D = ones( varargin );
        D = zeros( varargin );
        D = eye( varargin );
        D = inf( varargin );
        function D = Inf(varargin)
            D = distributed.sBuild( @codistributed.Inf, 'Inf', varargin{:} );
        end
        D = nan( varargin );
        function D = NaN(varargin)
            D = distributed.sBuild( @codistributed.NaN, 'NaN', varargin{:} );
        end
        D = rand( varargin );
        D = randn( varargin );

        % Unique prototype methods       
        D = colon( varargin );
        
        % Sparse-related methods
        D = speye( varargin );
        D = sprand( varargin );
        D = sprandn( varargin );
        D = spalloc( varargin );
    end
end
