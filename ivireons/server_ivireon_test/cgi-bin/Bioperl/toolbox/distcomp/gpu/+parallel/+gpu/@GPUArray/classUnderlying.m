%classUnderlying Class of elements contained within a GPUArray
%   C = classUnderlying(D) returns the name of the class of the elements
%   contained within the GPUArray D.
%   
%   Examples:
%   import parallel.gpu.GPUArray
%       N        = 1000;
%       D_uint8  = GPUArray.ones(1, N, 'uint8');
%       D_single = GPUArray.nan(1, N, 'single');
%       c_uint8  = classUnderlying(D_uint8) % returns 'uint8'
%       c_single = classUnderlying(D_single)  % returns 'single'
%   
%   See also CLASS, PARALLEL.GPU.GPUARRAY.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:36 $
