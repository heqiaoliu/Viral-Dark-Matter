%GPUDevice - select and query properties of GPU hardware
%   parallel.gpu.GPUDevice has a number of static methods to select and query
%   GPU devices:
%
%   c = parallel.gpu.GPUDevice.count() returns the number of GPU devices
%   present.
%
%   d = parallel.gpu.GPUDevice.current() returns the currently selected GPU
%   device.
%
%   d = parallel.gpu.GPUDevice.select(idx) selects a different GPU device.
%
%   d = parallel.gpu.GPUDevice.getDevice(idx) returns a GPU device object
%   without selecting it.
%
%   See also parallel.gpu.CUDADevice, gpuDevice, gpuDeviceCount.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:24:44 $
classdef GPUDevice < handle
    methods ( Access = public, Static )
        
        function c = count()
        %COUNT Number of GPU Devices
        %   N = PARALLEL.GPU.GPUDEVICE.COUNT returns the number of available GPU
        %   devices.
            c = parallel.internal.gpu.deviceCount;
        end
        
        function d = current()
        %CURRENT Return currently selected GPUDevice
        %   D = PARALLEL.GPU.GPUDEVICE.CURRENT returns the currently selected GPUDevice
        %   object.
            [props, E] = parallel.internal.gpu.deviceProperties();
            if ~isempty( E ), throw( E ); end
            d = parallel.gpu.CUDADevice.hBuild( props );
        end
        
        function d = select( idx )
        %SELECT Change the currently selected GPUDevice
        %   D = PARALLEL.GPU.GPUDEVICE.SELECT(IDX) selects a GPUDevice with index
        %   IDX. IDX must be in the range 1..PARALLEL.GPU.GPUDEVICE.COUNT.

            E = parallel.internal.gpu.selectDevice( idx );
            if ~isempty( E )
                throw( E );
            end
            if nargout == 1
                d = parallel.gpu.GPUDevice.current();
            end
        end
        
        function d = getDevice( idx )
        %GETDEVICE Return a GPUDevice object without selecting it
        %   D = PARALLEL.GPU.GPUDEVICE.GETDEVICE(IDX) returns a GPUDevice object for
        %   index IDX without making it the currently selected GPU device.
            [props, E] = parallel.internal.gpu.deviceProperties( idx );
            if ~isempty( E ), throw( E ); end
            d = parallel.gpu.CUDADevice.hBuild( props );
        end
    end
    methods ( Abstract = true )
        reset( obj )
    end
end
