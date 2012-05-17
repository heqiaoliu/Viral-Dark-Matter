function obj = complex( A, B )
%COMPLEX Construct complex GPUArray from real and imaginary parts
%   C = COMPLEX(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D1 = 3*GPUArray.ones(N);
%       D2 = 4*GPUArray.ones(N);
%       E = complex(D1,D2)
%   
%   See also COMPLEX, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $   $Date: 2010/06/10 14:27:38 $

[aIsNum, aIsFlt, aClzz, aSz, aSparse, aReal] = iInfo( A );
if nargin > 1
    [bIsNum, bIsFlt, bClzz, bSz, bSparse, bReal] = iInfo( B );
end

% real, numeric, full
if ~isValidInputForComplex( aReal, aSparse, aIsNum ) || ...
        ( nargin > 1 && ~isValidInputForComplex( bReal, bSparse, bIsNum ) )
    error('parallel:gpu:complex:Input', ...
          'Inputs must be numeric, real, and full.');
end

if nargin == 1
    % 1-arg, just send the real part to have a complex part added to it. No need to
    % check whether it's already GPU - method dispatch has already taken care of
    % that.
    try
        obj = hComplex( A );
    catch E
        throw(E);
    end
else
    clsMatch = isequal( aClzz, bClzz );
    szMatch  = isequal( aSz,   bSz  );

    if szMatch
        % All the size match cases
        if clsMatch
            try
                % Good to go
                obj = hComplex( pGPU( A ), pGPU( B ) );
            catch E
                throw(E);
            end
        elseif aIsFlt && bIsFlt
            % Classes don't match, but both are floating point. Must therefore result in
            % 'single'. Trade-off here on relative ordering of pGPU and single
            % calls - casting is quicker on the device, but transferring doubles
            % is slower. Choose to transfer singles.
            try
                obj = hComplex( pGPU( single( A ) ), pGPU( single( B ) ) );
            catch E
                throw(E);
            end
        else
            % error
            error( 'parallel:gpu:complex:Input', ...
                   ['Mixed inputs must be single and double. ', ...
                    'All other combinations are not allowed.'] );
        end
    else
        % Can we do scalar expansion? First, need to know if A or B is double-scalar
        aDoubleScalar = isequal( aClzz, 'double' ) && isscalar( A );
        bDoubleScalar = isequal( bClzz, 'double' ) && isscalar( B );
        
        canDoScalarExpansion = aDoubleScalar || ...  % Ok, scalar-double-expansion
            bDoubleScalar || ...                     % Ok, scalar-double-expansion
            ( clsMatch && ( isscalar( A ) || isscalar( B ) ) ); % Ok - class match scalar expansion
        if ~canDoScalarExpansion
            error( 'parallel:gpu:complex:Input', ...
                   ['Mixed inputs must be either single and double, or integer and scalar ', ...
                    'double. All other combinations are not allowed.'] );
        end

        % Only need to cast scalar doubles
        if aDoubleScalar
            A = cast( A, bClzz );
        end
        if bDoubleScalar
            B = cast( B, aClzz );
        end
        
        % Finally, call hComplex which actually expands the scalars
        try
            obj = hComplex( pGPU( A ), pGPU( B ) );
        catch E
            throw(E);
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get all metadata about an array
function [aIsNum, aIsFlt, aClzz, aSz, aSparse, aReal] = iInfo( A )
[~, aIsNum, aIsFlt, aClzz] = pObjProps( A );
aSz     = size( A );
aSparse = issparse( A );
aReal   = isreal( A );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Check if A is a valid input for COMPLEX
function flag = isValidInputForComplex( isrl, issp, isnum )
flag = isrl && ~issp && isnum;
end
