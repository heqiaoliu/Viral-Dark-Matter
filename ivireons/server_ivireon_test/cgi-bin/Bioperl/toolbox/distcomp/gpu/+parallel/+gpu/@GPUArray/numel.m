%NUMEL Number of elements in GPUArray or subscripted array expression
%   N = NUMEL(D) returns the number of underlying elements in the GPUArray 
%   array D.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(3,4,N);
%       ne = numel(D)
%   
%   returns ne = 12000.
%   
%   See also NUMEL, PARALLEL.GPU.GPUARRAY.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:18 $
