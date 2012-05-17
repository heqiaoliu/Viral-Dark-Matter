function hpccRandomAccess( m )
%HPCCRANDOMACCESS An implementation of the HPCC Global RandomAccess benchmark
%
%  hpccRandomAccess(m) creates a real vector of length m, partitoned across
%    the labs, then updates the elements of this vector based on the output
%    of a pseudo-random number generator (PRNG).  The vector update occurs
%    in a parallel way using the currently available resources (MATLAB
%    pool).
%
%    The number of labs involved with the computation must be a power of 2.
%
%    Initially, the vector contains the values 1:m, and on each lab the
%    PRNG is initialized to compute a discrete part of the whole stream.
%    The timed portion of the computation is 4*m updates to the vector in
%    parallel. A hypercube algorithm is used to alleviate latency issues:
%       http://www.sandia.gov/~sjplimp/algorithms.html#gups
%       http://www.sandia.gov/~sjplimp/docs/cluster06.pdf
%    This timed region produces the performance benchmark in GUPS
%    (Giga-updates per second). Finally, the same random stream is applied
%    once more to the vector to ensure that the final state of the vector
%    is the values 1:m. This confirms that no errors were introduced during
%    the transformation.
%
%    If you do not specify the variable m, the default is the value 
%    returned from hpccGetProblemSize('ra'), which assumes that each
%    process in the pool has 256 MB of memory available. This is expected
%    to be smaller than the actual memory available. 
%
%    Details of the HPC Challenge benchmarks can be found at
%    www.hpcchallenge.org and the specific Class 2 specs are linked off
%    that page. (At the time of writing, the specs are linked at
%    www.hpcchallenge.org/class2specs.pdf.)
%
%    Examples:
%
%      % Without a matlabpool open
%      tic; hpccRandomAccess; toc
%      Data size: 0.062500 GB
%      Performance: 0.002555 GUPS
%      Err: 0.000000
%      Elapsed time is 7.280912 seconds.
%
%      % With a local matlabpool of size 4
%      tic; hpccRandomAccess; toc
%      Data size: 0.250000 GB
%      Performance: 0.001724 GUPS
%      Err: 0.000000
%      Elapsed time is 41.254388 seconds.
%
%    See also: hpccGetProblemSize, matlabpool

%   Copyright 2008-2009 The MathWorks, Inc.

% If no size provided then get a default size
if nargin < 1
    m = hpccGetProblemSize( 'ra' );
end
% Random number block size we can compute in one go
b = 1024;
% Run algorithm for nu steps
nu = 4*m;
spmd
    assert(numlabs == 2^floor(log2(numlabs)), 'hpccRandomAccess requires a power of 2 number of labs');
    % Call the algorithm. Return the time it takes and the output table
    [t, T] = iDoIt( m, b, nu );
end
perf = m / t{1} / 1e9;

% Verification. Run the algorithm again. Should get original data
spmd
    [~, T] = iDoIt( m, b, nu, T );
    err = gplus( norm( double(T) - double( iGenerateTable(m) ), Inf ) );
end

if err{1} ~= 0
    error( 'Failed the HPC RandomAccess Benchmark' );
end

fprintf( 'Data size: %f GB\nPerformance: %f GUPS\nErr: %f\n', ...
         8*m/(1024^3), perf, err{1});

end

% -------------------------------------------------------------------
% Function to generate table of size m
% -------------------------------------------------------------------
function T = iGenerateTable(m)
n = m/numlabs;
T = uint64((1:n)+(labindex-1)*n);
end

% -------------------------------------------------------------------
%
% -------------------------------------------------------------------
function [t, T] = iDoIt( m, b, nu, T )

localTableSize = m / numlabs;
logLocalSize   = log2( localTableSize );
nloops         = nu / numlabs / b;
logNumlabs     = log2( numlabs );
localMask      = uint64( localTableSize - 1 );

if nargin < 4
    T = iGenerateTable( m );
end
% Initialiase random number generator
try
    randRA( (labindex-1) * m * 4 / numlabs, 'StreamOffset' );
catch err
    if strcmp( err.identifier, 'MATLAB:UndefinedFunction' )
        newErr = MException( 'MATLAB:UndefinedFunction', ...
            ['Unable to find the mex function randRA. This is probably because this function ' ...
             'has not been compiled for the cluster. See the randRA.cpp file for instructions on ' ...
             'how to compile the code for your cluster']);
        newErr.addCause(err);
        throw( newErr );
    else
        rethrow( err );
    end
end

t1 = clock;
for k = 1:nloops
    % Make the local chunk of random data
    list = randRA( b );
    % Loop over the hyper-cube dimensions
    for d = 0 : logNumlabs-1
        % Choose my partner for this dimension of the hypercube
        partner       = 1 + bitxor( (labindex-1), 2.^d );

        % Choose my mask for this dimension of the hypercube
        dim_mask      = uint64( 2.^( d + logLocalSize ) );
        
        % Choose which data to send and receive for this dimension
        dataToSend = logical( bitand( list, dim_mask ) );
        if partner <= labindex
            dataToSend = ~dataToSend;
        end
        % Setup a list of data that will be sent, and list I will keep
        send_list = list( dataToSend );
        keep_list = list( ~dataToSend );

        % Use send/receive to get some data that we should use next round
        recv_list = labSendReceive( partner, partner, send_list );
        
        % Our new list is the old list and what we've received
        list      = [keep_list, recv_list];
    end
    
    % Finally, after all rounds of communication, perform the table updates.
    idx = 1 + double( bitand( localMask, list ) );
    T(idx) = bitxor( T(idx), list );
end
% Calculate max time
t = gop( @max, etime( clock, t1 ) );
end
