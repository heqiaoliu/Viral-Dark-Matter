function b = repmat(a,varargin)
%REPMAT Replicate and tile a categorical array.
%   B = REPMAT(A,M,N) creates a large array B consisting of an M-by-N tiling
%   of copies of the categorical array A.  The size of B is [size(A,1)*M,
%   size(A,2)*N, size(A,3), ...].  REPMAT(A,N) creates an N-by-N tiling.
%
%   B = REPMAT(A,[M N P ...]) tiles the categorical array A to produce a 
%   multidimensional array B composed of copies of A.  The size of B is 
%   [size(A,1)*M, size(A,2)*N, size(A,3)*P, ...].
%
%   See also CATEGORICAL/SIZE, CATEGORICAL/NDIMS.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:15 $

b = a;
b.codes = repmat(a.codes,varargin{:});
