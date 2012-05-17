function varargout = size( obj, dim )
%SIZE Size of GPUArray
%   S = SIZE(D), for the M-by-N GPUArray D, returns the two-element
%   row vector D = [M,N] containing the number of rows and columns in the
%   matrix. For N-D GPUArrays, SIZE(D) returns a 1-by-N vector of
%   dimension lengths. Trailing singleton dimensions are ignored.
%   
%   [M,N] = SIZE(D) for GPUArray D, returns the number of rows and
%   columns in D as separate output variables.
%   
%   [M1,M2,M3,...,MN] = SIZE(D) for N>1 returns the sizes of the first N 
%   dimensions of the GPUArray D.  If the number of output arguments N does
%   not equal NDIMS(D), then for:
%   
%   N > NDIMS(D), SIZE returns ones in the "extra" variables, i.e., outputs
%                 NDIMS(D)+1 through N.
%   N < NDIMS(D), MN contains the product of the sizes of dimensions N
%                 through NDIMS(D).
%   
%   M = SIZE(D,DIM) returns the length of the dimension specified
%   by the scalar DIM.  For example, SIZE(D,1) returns the number
%   of rows. If DIM > NDIMS(D), M will be 1.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N, N*2);
%       n = size(D, 2)
%   
%   returns n = 2000.
%   
%   See also SIZE, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:54 $

if nargin == 1
    objSz = hSize( obj );
    if nargout > 1
        % Must only give as many output arguments as requested, by multiplying
        % together the trailing arguments, or appending trailing ones.
        if nargout >= length( objSz )
            % append ones
            szForOut = [ objSz, ones( 1, nargout - length( objSz ) ) ];
        else
            % multiply remaining values
            szForOut  = objSz( 1:nargout );
            szForOut( nargout ) = prod( objSz( nargout:end ) );
        end
        varargout = num2cell( szForOut );
    else
        varargout = {objSz};
    end
else
    % Deal with GPUArray dim
    [objIsGpu, dim] = gatherIfNecessary( obj, dim );
    if ~objIsGpu
        [varargout{1:nargout}] = size( obj, dim );
        return
    end
    
    objSz = hSize( obj );

    % Error check nargout
    error( nargoutchk( 0, 1, nargout, 'struct' ) );
    
    % Check the value of dim
    if ~isPositiveIntegerValuedNumeric( dim ) || ~isscalar( dim )
        error( 'parallel:gpu:size:BadDimension', ...
               'Dimension argument must be a positive integer scalar within indexing range.' );
    end

    % Defend against dim being higher dimensionality than obj
    if dim > ndims( obj )
        varargout{1} = 1;
    else
        varargout{1} = objSz( dim );
    end
end
end
