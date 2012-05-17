function hpccLinpack( m )
%HPCCLINPACK An implementation of the HPCC Global HPL benchmark
%
%  hpccLinpack(m) creates a random codistributed real matrix A of size 
%    m-by-m and a real random codistributed vector B of length m. It then
%    measures the time to perform the matrix division of A into B (X = A\B,
%    which is the solution to the equation A*X = B) in a parallel way using
%    the currently available resources (MATLAB pool). This time indicates
%    the performance metric. Finally the function computes the scaled
%    residuals to ensure that the error on the computation is within
%    acceptable bounds.
%
%    If you do not specify m, the default value is that returned from
%    hpccGetProblemSize('hpl'), which assumes that each process in the pool
%    has 256 MB of memory available. This is expected to be smaller than
%    the actual memory available. 
%
%    Details of the HPC Challenge benchmarks can be found at
%    www.hpcchallenge.org and the specific Class 2 specs are linked off
%    that page. (At the time of writing, the specs are linked at
%    www.hpcchallenge.org/class2specs.pdf.)
%
%    Examples:
%
%      % Without a matlabpool open
%      tic; hpccLinpack; toc
%      Data size: 0.108665 GB
%      Performance: 16.351622 GFlops
%      Elapsed time is 2.791896 seconds.
%
%      % With a local matlabpool of size 4
%      tic; hpccLinpack; toc
%      Data size: 0.434774 GB
%      Performance: 18.650758 GFlops
%      Elapsed time is 21.647003 seconds.
%
%    See also: hpccGetProblemSize, matlabpool

%   Copyright 2008-2009 The MathWorks, Inc.

% If no size provided then get a default size
if nargin < 1
    m = hpccGetProblemSize( 'hpl' );
end

spmd
    % Create a distributed matrix in the 2d block cyclic distribution and a
    % distributed column vector in 1d
    A = codistributed.randn(m, m, codistributor2dbc);
    b = codistributed.rand(m, 1);
    
    % Time the solution of the linear system   
    tic
    x = A\b;
    t = toc;    

    % Need to convert to a 1d distribution for the checking code below
    A = redistribute(A, codistributor1d);
    % Compute scaled residuals
    r1 = norm(A*x-b,inf)/(eps*norm(A,1)*m);
    r2 = norm(A*x-b,inf)/(eps*norm(A,1)*norm(x,1));
    r3 = norm(A*x-b,inf)/(eps*norm(A,inf)*norm(x,inf)*m);
    % This test is specified in the benchmark definition
    if max([r1 r2 r3]) > 16
        error('Failed the HPC HPL Benchmark');
    end
end
% Performance in gigaflops
perf = (2/3*m^3 + 3/2*m^2)/max([t{:}])/1.e9;

fprintf('Data size: %f GB\nPerformance: %f GFlops\n', 8*m^2/(1024^3), perf);

