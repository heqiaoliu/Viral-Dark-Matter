function dev = gpuDevice( optIdx )
%GPUDEVICE Query or select a GPU device
%   D = GPUDEVICE returns the currently selected GPU device
%
%   D = GPUDEVICE(IDX) selects the GPU device by index IDX. IDX must be between
%   1 and GPUDEVICECOUNT. An error may occur if the GPU device is not supported
%   for use.
%
%   See also gpuDeviceCount, gpuArray, parallel.gpu.GPUDevice,
%   parallel.gpu.CUDADevice.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:24:37 $

if nargin == 1
    dev = parallel.gpu.GPUDevice.select( optIdx );
else
    dev = parallel.gpu.GPUDevice.current();
end
end
