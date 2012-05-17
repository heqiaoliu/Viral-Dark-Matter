function varargout = size(D,d)
%SIZE Size of codistributed array
%   S = SIZE(D), for the M-by-N codistributed array D, returns the two-element
%   row vector D = [M,N] containing the number of rows and columns in the
%   matrix. For N-D codistributed arrays, SIZE(D) returns a 1-by-N vector of
%   dimension lengths. Trailing singleton dimensions are ignored.
%   
%   [M,N] = SIZE(D) for codistributed array D, returns the number of rows and
%   columns in D as separate output variables.
%   
%   [M1,M2,M3,...,MN] = SIZE(D) for N>1 returns the sizes of the first N 
%   dimensions of the codistributed array D.  If the number of output arguments N does
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
%   spmd
%       N = 1000;
%       D = codistributed.ones(N, N*2);
%       n = size(D, 2)
%   end
%   
%   returns n = 2000.
%   
%   See also SIZE, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/15 23:01:18 $

if nargin==2 
    if isa(d, 'codistributed')
        error('distcomp:codistributed:size:InvalidCodistributed', ...
              'Dimension must not be a codistributed array.');
    end
        
    if ~isscalar(d) || ~isPositiveIntegerValuedNumeric(d,false)
        error('distcomp:codistributed:size:dimInput', ...
            'Second input must be a numeric scalar dimension.');
    end
    if nargout > 1
        error('distcomp:codistributed:size:numOutputs', ...
            ['SIZE accepts only one output argument ' ...
            'when DIM argument is provided.']);
    end
end

% Get size from codistributor.
dist = getCodistributor(D);
s = dist.Cached.GlobalSize;
g = nargout;
if nargin > 1
    if d <= length(s)
        varargout{1} = s(d);
    else
        varargout{1} = 1;
    end
elseif g <= 1
    varargout{1} = s;
else
    e = length(s);
    for d = 1:min(e,g)
        varargout{d} = s(d);
    end
    if e > g
        varargout{g} = prod(s(g:e));
    end
    for d = e+1:g
        varargout{d} = 1;
    end
end
