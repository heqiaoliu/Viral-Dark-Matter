function tf = isequal( varargin )
%ISEQUAL True if GPUArrays are numerically equal
%   TF = ISEQUAL(A,B)
%   TF = ISEQUAL(A,B,C,...)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.nan(N);
%       f = isequal(D,D)
%       t = isequalwithequalnans(D,D)
%   
%   returns f = false and t = true.
%   
%   See also ISEQUAL, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/NAN.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:03 $

try
    areNansEqual = false;
    tf = isequaltemplate( areNansEqual, varargin{:} );
catch E
    % strip stack
    throw(E);
end
end
