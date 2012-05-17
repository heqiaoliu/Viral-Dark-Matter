function hpccFft( m )
%HPCCFFT An implementation of the HPCC Global FFT benchmark
%
% hpccFft(m) creates a random complex codistributed array of length m and 
%  computes the discrete fourier transform on that vector in a parallel
%  way, using the currently available resources (MATLAB pool). This
%  computation is timed to produce the benchmark result. It then computes 
%  the inverse discrete fourier transform on the result (in parallel) to 
%  ensure that the error on the computation is within acceptable bounds.
%
%  The number of labs in the pool must be a power of 2; and m must be a 
%  power of 2 equal to or greater than 2^numlabs.
%
%  If you do not provide a value for m, the default value is that returned
%  from hpccGetProblemSize('fft'), which assumes that each process in the
%  pool has 256 MB of memory available. This is expected to be smaller than
%  the actual memory available.
%
%  Details of the HPC Challenge benchmarks can be found at
%  www.hpcchallenge.org and the specific Class 2 specs are linked off that
%  page. (At the time of writing, the specs are linked at
%  www.hpcchallenge.org/class2specs.pdf.)
%
%    Examples:
%
%      % Without a matlabpool open
%      tic; hpccFft; toc
%      Data size: 0.062500 GB
%      Performance: 0.211762 GFlops
%      Err: 0.016637
%      Elapsed time is 2.354904 seconds.
%
%      % With a local matlabpool of size 4
%      tic; hpccFft; toc
%      Data size: 0.250000 GB
%      Performance: 0.316420 GFlops
%      Err: 0.021332
%      Elapsed time is 7.170477 seconds.
%
%  See also: hpccGetProblemSize, matlabpool


%   Copyright 2008-2009 The MathWorks, Inc.

% If no size provided then get a default size
if nargin < 1
    m = hpccGetProblemSize( 'fft' );
end
% Input vector MUST be a power of 2 in size
assert(m == 2^floor(log2(m)), 'hpccFft requires an exact power of 2 size for its input vector size');
spmd
    % Input vector MUST be larger than 2^numlabs and numlabs MUST be a power of 2
    assert(log2(m) >= numlabs, 'hpccFft requires an input vector size >= 2^numlabs');
    assert(numlabs == 2^floor(log2(numlabs)), 'hpccFft requires an exact power of 2 number of labs');
    
    % Create complex 1xm random vector
    x = codistributed.rand(1, m) + codistributed.rand(1, m)*1i;
     
    % Time the forward FFT
    tic
    y = iDistributedFft(x);
    t = toc;
        
    % Performance in gigaflops
    perf = 5*m*log2(m)/t/1.e9;
    
    % Compute error from the inverse FFT    
    z = iDistributedIfft(y);
    err = norm(x-z,inf)/(16*log2(m)*eps);
end

perf = min([perf{:}]);
err = err{1};

if err > 1
    error('Failed the HPC FFT Benchmark');
end

fprintf('Data size: %f GB\nPerformance: %f GFlops\nErr: %f\n', 32*m/(1024^3), perf, err);

% -------------------------------------------------------------------------
% Trivial implementation of the inverse distributed FFT based 
% -------------------------------------------------------------------------
function z = iDistributedIfft(y)
% IFFT  Inverse FFT for distribued arrays
z = (1/length(y))*conj(iDistributedFft(conj(y)));

% -------------------------------------------------------------------------
% An implementation of a distributed FFT based on the Cooley-Tukey FFT
% algorithm (http://en.wikipedia.org/wiki/Cooley-Tukey_FFT_algorithm)
% -------------------------------------------------------------------------
function x = iDistributedFft(x)
% Remember row or column size
s = size(x);
assert(s(1) == 1 || s(2) == 1, 'Must have a vector input');

% Reshape to matrix with numlabs columns
n = prod(s);
M = numlabs;
N = n/M;
x = iReshape(x, N, M);

% Redistribute to do small FFT's on each lab
x = redistribute(x, codistributor1d(1));

% Local 1-D FFT
xloc = fft(getLocalPart(x), [], 2);

% Compute local twiddle factors
omega = exp(-2*pi*1i* (getLocalPart(codistributed.colon(0,N-1))')/n);
t = repmat(omega, 1, M);
t(:, 1) = 1;
t = cumprod(t, 2);

% Multiply by the local twiddle factors
x = codistributed.build(xloc .* t, getCodistributor(x));

% Redistribute to do second set of small FFT's on each lab
x = redistribute(x, codistributor1d(2));

% Local 1-D FFTs
xloc = fft(getLocalPart(x), [], 1);
% Recreate distributed array 
x = codistributed.build(xloc,  getCodistributor(x));

% Return distributed array row or column vector
x = redistribute(x.', codistributor1d(2));
x = iReshape(x, s(1), s(2));

% -------------------------------------------------------------------------
% A function that reshapes codistributed arrays without any communication.
% This can ONLY be done because we know that the partitions involved fit
% exactly onto the same machine. This fit is a consequence of the specific
% restrictions on the size of the input vector and the number of labs 
% involved in the computation.
% -------------------------------------------------------------------------
function B = iReshape(A, r, c)
% Check the inputs are correct
assert(prod(size(A)) == r*c, 'Cannot reshape'); %#ok<PSIZE>
assert(rem(c, numlabs) == 0, 'Cannot reshape');
% Reshape the local part correctly
L = reshape(getLocalPart(A), r, c/numlabs);
% Create the correct codistributor for the output
cdist = codistributor1d(2, zeros(1, numlabs) + c/numlabs, [r, c]);
% Make the output distributed array without communication
B = codistributed.build(L, cdist, 'noCommunication');