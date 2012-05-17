function obj = reshape( obj, varargin )
%RESHAPE Change size of GPUArray
%   RESHAPE(G,M,N) returns the M-by-N GPUArray whose elements are 
%   taken columnwise from G. An error results if G does not 
%   have M*N elements.
%   
%   RESHAPE(G,M,N,P,...) returns an N-D array with the same
%   elements as G but reshaped to have the size M-by-N-by-P-by-...
%   M*N*P*... must be the same as PROD(SIZE(G)).
%   
%   RESHAPE(G,[M N P ...]) is the same thing.
%   
%   RESHAPE(G,...,[],...) calculates the length of the dimension
%   represented by [], such that the product of the dimensions 
%   equals PROD(SIZE(G)). PROD(SIZE(G)) must be evenly divisible 
%   by the product of the known dimensions. You can use only one 
%   occurrence of [].
%   
%   In general, RESHAPE(G,SIZ) returns an N-D array with the same
%   elements as G but reshaped to the size SIZ.  PROD(SIZ) must be
%   the same as PROD(SIZE(G)). 
%   
%   
%   Example:
%   import parallel.gpu.GPUArray
%       x = GPUArray.colon(1,1000);
%       y = reshape(x,10,10,10)
%   
%   See also RESHAPE, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COLON.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $   $Date: 2010/06/10 14:28:22 $

% Handle non-data arg being GPUArray
[objIsGpu, args{1:nargin-1}] = gatherIfNecessary( obj, varargin{:} );
if ~objIsGpu
    obj = reshape( obj, args{:} );
    return
end

% Two cases: either a vector, or a series of arguments.
numelCheck = numel( obj );
if nargin == 2
    desSz = double( varargin{1} );
    if isreal( desSz ) && all( desSz == round( desSz ) ) && all( isfinite( desSz ) )
        % ok
    else
        error( 'parallel:gpu:reshape', ...
               'Size arguments must be real integers.' );
    end
else
    desSz = cellfun( @iConvToDim, varargin );
    if any( isnan( desSz ) )
        error( 'parallel:gpu:reshape', ...
               'Size arguments must be real integers.' );
    end
    unspecIdx = find( desSz == -1 );

    if length( unspecIdx ) > 1
        error( 'parallel:gpu:reshape', ...
               'Size can have at most one unknown dimension.' );
    elseif length( unspecIdx ) == 1
        knownProduct = -prod( desSz );
        unspecValue = numelCheck / knownProduct;
        if unspecValue ~= round( unspecValue )
            % This is the error given by builtin/reshape. 
            error( 'parallel:gpu:reshape', ...
                   ['Total number of elements(%d) is not divisible by ' ...
                    'product of known dimensions(%d).'], numelCheck, knownProduct);
        end
        desSz( unspecIdx ) = unspecValue;
    end
end

% Final pre-flight checks
if length( desSz ) < 2 
    error( 'parallel:gpu:reshape', ...
           'Size vector must have at least two elements.' );
elseif prod( desSz ) ~= numelCheck
    error( 'parallel:gpu:reshape', ...
           'To RESHAPE the number of elements must not change.' );
else
    % Go ahead and call the builtin method
    try
        obj = hReshape( obj, desSz );
    catch E
        throw(E);
    end
end

end

% convert a single input argument to a dimension
function x = iConvToDim( v )
if isempty( v )
    x = -1;
elseif isscalar( v ) && isnumeric( v ) && isfinite( v ) && isequal( v, round( v ) )
    x = double( v );
else
    % Error checking above will catch this
    x = NaN;
end    
end
