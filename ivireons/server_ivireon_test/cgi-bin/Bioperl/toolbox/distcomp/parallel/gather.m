function x = gather( x )
%GATHER collect values into current workspace
%    X = GATHER(A) when A is a codistributed array, X is a replicated array with
%    all the data of the array on every lab.  This would typically be executed
%    inside SPMD statements, or in parallel jobs.
%
%    X = GATHER(A) when A is a distributed array, X is an array in the local
%    workspace with the data transferred from the multiple labs.  This would
%    typically be executed outside SPMD statements.
%
%    X = GATHER(X) when A is a GPUArray, X is an array in the local workspace
%    with the data transferred from the GPU device.
%
%    If A is not one of the types mentioned above, then no operation is
%    performed and X is the same as A.
%
%    Example:
%    % create a distributed array
%    d = distributed(magic(5));
%    % gather values back to the client
%    x = gather(d);
%    % a second gather is a no-op
%    isequal(x, gather(x)) % returns true
% 
%    See also DISTRIBUTED, CODISTRIBUTED, PARALLEL.GPU.GPUARRAY

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $   $Date: 2010/05/10 17:07:01 $
error( nargchk( 1, 1, nargin, 'struct') );
