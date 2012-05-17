function out = bitcmp( in )
%BITCMP Complement bits of GPUArray
%   C = BITCMP(G) returns the bitwise complement of G, where G is an unsigned
%   GPUArray containing integers or unsigned integers.
%   
%   Example:
%   import parallel.gpu.GPUArray
%      a = GPUArray.ones(10, 'uint32') .* uint32(intmax('uint8'));
%      bitcmp(a)
%   
%   See also BITCMP, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.
%   


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:57 $

out = pElementwiseUnaryOp( 'bitcmp', in );
