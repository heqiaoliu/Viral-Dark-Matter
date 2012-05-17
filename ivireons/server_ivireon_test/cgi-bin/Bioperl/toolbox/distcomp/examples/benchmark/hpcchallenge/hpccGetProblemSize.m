function N = hpccGetProblemSize(benchmark, nLabs, GBperLab)
%HPCCGETPROBLEMSIZE return suitable problem size for HPCC benchmarks
%
% N = HPCCGETPROBLEMSIZE(PROBLEM, NLABS, GBperLAB)
%
%    This function provides a suitable problem size for each 
%    of the implemented HPCC benchmarks. PROBLEM must be one of 
%        'hpl'      Linpack benchmark
%        'ra'       Random Access benchmark 
%        'fft'      FFT benchmark 
%        'stream'   Stream benchmark
%
%    For a particular problem, number of communicating processes involved
%    with the solution, and amount of memory available to each of those
%    processes, this function computes the size input to that problem to
%    fulfil the requirements of the HPCC benchmark. 
%   
%    In general, this computed size input is large (between 1/4 and 1/2 of
%    total system memory). When trying out these benchmarks, it is
%    worthwhile lowering the memory available to each process first, to
%    ensure that they run.
%
%    If you do not specify NLABS, the default is the size of the currently
%    running MATLAB pool. If you do not specify GBperLAB, the default
%    is 0.25.
%
%  See also:  hpccFft, hpccLinpack, hpccRandomAccess, hpccStream

%   Copyright 2008-2009 The MathWorks, Inc.

if nargin < 2
    % If no pool open then nLabs = 1 and we run locally
    nLabs = max(matlabpool('size'), 1);
end
if nargin < 3
    % Assume 0.25 GB per lab if not supplied
    GBperLab = 0.25;
end

totalMem = nLabs*(1024^3)*GBperLab;

switch lower(benchmark)
    case 'hpl'
        % Use a little less than half the system memory (should be half but
        % we need to keep a copy of the array in MATLAB as well as the
        % ScaLAPACK data
        %
        % Matrix size (8*N^2) > 1/2 system memory
        N = fix(sqrt(totalMem / 2.3 / 8));
    case 'ra'
        % Table size (8*M bytes) > 1/4 of system memory
        N = fix(totalMem / 4 / 8);
    case 'fft'
        % Vector in + vector out (32*M bytes) > 1/4 of system memory
        N = fix(totalMem / 4 / 32);
        % Vector length must be a power of 2
        N = 2^(floor(log2(N)));
    case 'stream'
        % two vectors in + vector out (24*M bytes) > 1/4 of system memory
        N = fix(totalMem / 4 / 24);
    otherwise
        error('Unknown benchmark');
end