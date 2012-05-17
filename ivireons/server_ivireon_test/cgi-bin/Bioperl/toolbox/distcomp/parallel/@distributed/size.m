function varargout = size( obj, opt_dim )
%SIZE Size of distributed array
%   S = SIZE(D), for the M-by-N distributed array D, returns the two-element
%   row vector D = [M,N] containing the number of rows and columns in the
%   matrix. For N-D distributed arrays, SIZE(D) returns a 1-by-N vector of
%   dimension lengths. Trailing singleton dimensions are ignored.
%   
%   [M,N] = SIZE(D) for distributed array D, returns the number of rows and
%   columns in D as separate output variables.
%   
%   [M1,M2,M3,...,MN] = SIZE(D) for N>1 returns the sizes of the first N 
%   dimensions of the distributed array D.  If the number of output arguments N does
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
%       N = 1000;
%       D = distributed.ones(N, N*2);
%       n = size(D, 2)
%   
%   returns n = 2000.
%   
%   See also SIZE, DISTRIBUTED, DISTRIBUTED/RAND.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/03/25 22:01:58 $

if nargin == 1
    if nargout > 1
        % Must only give as many output arguments as requested, by multiplying
        % together the trailing arguments, or appending trailing ones.
        objSz = obj.Size;
        if nargout >= length( objSz )
            % append ones
            szForOut = [ objSz, ones( 1, nargout - length( objSz ) ) ];
        else
            % multiply remaining values
            szForOut  = obj.Size( 1:nargout );
            szForOut( nargout ) = prod( obj.Size( nargout:end ) );
        end
        varargout = num2cell( szForOut );
    else
        varargout = {obj.Size};
    end
else
    % Error check nargout
    error( nargoutchk( 0, 1, nargout, 'struct' ) );
    
    % Defend against the case where the dim is the distributed thing
    if isa( opt_dim, 'distributed' )
        dim = gather( opt_dim );
    else
        dim = opt_dim;
    end
    
    % Check the value of dim
    if ~isPositiveIntegerValuedNumeric( dim ) || ~isscalar( dim )
        error( 'distcomp:distributed:BadDimension', ...
               'Dimension argument must be a positive integer scalar within indexing range.' );
    end

    % Defend against dim being higher dimensionality than obj
    if dim > ndims( obj )
        varargout{1} = 1;
    else
        if isa( obj, 'distributed' )
            varargout{1} = obj.Size( dim );
        else
            % Use default size - neither obj nor dim are distributed by the time we get
            % here.
            varargout{1} = size( obj, dim );
        end
    end
end
end
