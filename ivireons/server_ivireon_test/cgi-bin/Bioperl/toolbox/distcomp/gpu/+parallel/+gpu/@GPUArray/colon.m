function obj = colon( varargin )
%PARALLEL.GPU.GPUARRAY.COLON Build GPUArrays of the form A:D:B
%   PARALLEL.GPU.GPUARRAY.COLON returns a GPUArray vector equivalent to the return 
%   vector of the COLON function or the colon notation. 
%   
%   D = PARALLEL.GPU.GPUARRAY.COLON(A,B) is the same as PARALLEL.GPU.GPUARRAY.COLON(A,1,B).
%   
%   D = PARALLEL.GPU.GPUARRAY.COLON(A,D,B) is a GPUArray vector storing the values
%   A:D:B.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       d = GPUArray.colon(1,N)
%   
%   creates the vector 1:N on the GPU
%   
%   See also COLON, PARALLEL.GPU.GPUARRAY.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:37 $

[szVec, ~, E] = parallel.internal.buildFcnArgCheck( 'colon', ...
                                                  'parallel:gpu:colon', ...
                                                  varargin{:} );
if ~isempty( E )
    throw( E );
end

% Insert "D" if required
if length( szVec ) == 2
    szVec = [szVec(1), 1, szVec(2)];
end

if szVec(2) == round( szVec(2) )
    try
        % Can do efficiently on the GPU
        obj = parallel.gpu.GPUArray.hIntColon( szVec(1), szVec(2), szVec(3) );
    catch E
        throw(E);
    end
else
    % Must create the array on the CPU and transmit
    obj = parallel.gpu.GPUArray( szVec(1):szVec(2):szVec(3) );
end

end

