function obj = pGPU( obj )
% pGPU - ensure data is on the GPU

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:37 $

gpuclzz = 'parallel.gpu.GPUArray';

if ~isequal( gpuclzz, class( obj ) )
    obj = parallel.gpu.GPUArray( obj );
end
end
