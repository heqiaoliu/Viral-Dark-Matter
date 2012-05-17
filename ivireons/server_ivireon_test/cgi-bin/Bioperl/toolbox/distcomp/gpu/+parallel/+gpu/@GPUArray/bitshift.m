function out = bitshift( in1, in2 )
%BITSHIFT Bit-wise shift of GPUArray
%   
%   C = BITSHIFT(A,K) returns the value of A shifted by K bits. At least one
%   of A or K must be a GPUArray of unsigned integers. Shifting by K 
%   is the same as multiplication by 2^K. Negative values of K are allowed 
%   and this corresponds to shifting to the right, or dividing by 2^ABS(K) 
%   and truncating to an integer. If the shift causes C to overflow 
%   the number of bits in the unsigned integer class of A, then the 
%   overflowing bits are dropped.
%   
%   Example:
%   % Repeatedly shift the bits of an unsigned 32 bit value to the left
%   % until all the nonzero bits overflow. Track the progress in binary.
%   import parallel.gpu.GPUArray
%       a = GPUArray(intmax('uint32'));
%       disp(sprintf('Initial uint32 value %5d is %32s in binary', ...
%          gather(a),dec2bin(gather(a))))
%       for i = 1:32
%          a = bitshift(a,1);
%          disp(sprintf('Shifted uint32 value %5d is %32s in binary',...
%             gather(a),dec2bin(gather(a))))
%       end
%    
%   See also BITSHIFT, PARALLEL.GPU.GPUARRAY.
%   


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:59 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'bitshift', in1, in2 );
