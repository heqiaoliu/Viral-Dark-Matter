function Y = fft(X, n, dim)
%FFT Discrete Fourier transform of codistributed array
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
%   spmd
%       Nrow = 2^16;
%       Ncol = 100;
%       D = codistributed.rand(Nrow, Ncol);
%       F = fft(D)
%   end
%   
%   returns the FFT F of the codistributed matrix by applying the FFT to 
%   each column.
%   
%   The current implementation gathers vectors on a single lab to perform
%   the computations rather than using a parallel FFT algorithm. It may
%   result in out-of-memory errors for long vectors.
%   
%   See also FFT, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/14 16:51:06 $

if nargin < 3
    dim = distributedutil.Sizes.firstNonSingletonDimension(size(X));
else
    dim = distributedutil.CodistParser.gatherIfCodistributed(dim);
end

if nargin < 2 || (nargin > 1 && isempty(n))
    n = size(X,dim);
else
    n = distributedutil.CodistParser.gatherIfCodistributed(n);
end

if ~isa(X, 'codistributed')
    Y = fft(X, n, dim);
    return;
end
    
% This implementation only supports codistributor1d.
codistributed.pVerifyUsing1d('fft', X); %#ok<DCUNK> private static

xDist = getCodistributor(X);
if xDist.Dimension ~= dim  %localX contains all the data.
    localY = fft(getLocalPart(X),n,dim);
    % Since we are not doing the fft along the distribution dimension, we can reuse
    % the distribution dimension and the partition.  The global size only
    % changes in the dimension along which we do the fft.
    sz = xDist.Cached.GlobalSize;
    sz(dim) = n;
    codistr = codistributor1d(xDist.Dimension, xDist.Partition, sz);
    Y = codistributed.pDoBuildFromLocalPart(localY, codistr); %#ok<DCUNK> private static
else
    Y = dist_fft(X,n,dim); %fft on codistributed data
end


function Y = dist_fft(X,n,dim)
%DIST_FFT fft on codistributed data
%   This is the only difficult part and
%   is where all the limitation comes from.
%   This implementation is general, but not efficient.
if dim == 1
    Y = redistribute(X,codistributor('1d', 2));
else
    Y = redistribute(X,codistributor('1d', dim-1));
end
Y = fft(Y,n,dim);
if size(X,dim) == n
   Y = redistribute(Y, getCodistributor(X));
else
   Y = redistribute(Y,codistributor('1d',dim));
end
