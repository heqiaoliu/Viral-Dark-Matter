function n = gpuDeviceCount
%GPUDEVICECOUNT - return how many GPU devices are present
%   N = GPUDEVICECOUNT returns how many GPU devices are present in your system.
%
%   See also gpuDevice, parallel.gpu.GPUDevice, parallel.gpu.CUDADevice.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:24:38 $

n = parallel.gpu.GPUDevice.count;
end
