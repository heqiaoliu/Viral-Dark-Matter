function hpccStream( m )
%HPCCSTREAM An implementation of the HPCC EP STREAM (Triad) benchmark
%
%  hpccStream(m) computes a = b + c*k for random vectors b & c of length m
%  and a 
%    random constant k. The minimum of 10 timed runs is used to deduce the
%    overall memory access bandwidth of the system in GB/s.
%
%    If you do not specify the variable m, the default is the value 
%    returned from hpccGetProblemSize('stream'), which assumes that each
%    process in the pool has 256 MB of memory available. This is expected
%    to be smaller than the actual memory available. 
%
%    Details of the HPC Challenge benchmarks can be found at
%    www.hpcchallenge.org and the specific Class 2 specs are linked off
%    that page. (At the time of writing the specs are linked at
%    www.hpcchallenge.org/class2specs.pdf.)

%    Examples:
%
%      % Without a matlabpool open
%      tic; hpccStream; toc
%      Data size: 0.062500 GB
%      Performance: 2.778029 GB/s
%      Elapsed time is 0.059182 seconds.
%
%      % With a local matlabpool of size 4
%      tic; hpccStream; toc
%      Data size: 0.250000 GB
%      Performance: 5.069985 GB/s
%      Elapsed time is 1.064580 seconds.
%
%    See also: hpccGetProblemSize, matlabpool

%   Copyright 2008-2009 The MathWorks, Inc.

% If no size provided then get a default size
if nargin < 1
    m = hpccGetProblemSize( 'stream' );
end
% Repeat the test n times
n = 10;
spmd
    % How big should we make the individual vectors 
    N = fix(m/numlabs);
    % Create vectors b and c of normally distributed random numbers
    b = randn(N, 1);
    c = randn(N, 1);
    alpha = randn;
    t = inf;
    
    for k = 1:n
        tic
        a = b + alpha*c; 
        % Performance on one process uses the best time achieved out of 10
        t = min(t, toc);
    end
    
    if a(1) ~= b(1) + alpha*c(1)
        error('Failed the HPC Stream Benchmark');
    end
end
% Performance across all the processes uses the mean time.
% 24 bytes the data transfer for each element in the vector, made from
% the reading of b and c and assignment to a, alpha is assumed to already
% be in some cache.
perf = 24*m/mean([t{:}])/1.e9;

fprintf('Data size: %f GB\nPerformance: %f GB/s\n', 24*m/(1024^3), perf);

