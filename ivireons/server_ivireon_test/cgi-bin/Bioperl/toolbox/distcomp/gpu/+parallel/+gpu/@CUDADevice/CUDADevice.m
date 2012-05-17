%CUDADevice CUDA GPU device object
%   DEV = parallel.gpu.GPUDevice.getDevice(IDX) returns a CUDADevice
%   representing the device with index IDX. 
%
%   DEV = parallel.gpu.GPUDevice.current() returns the currently selected
%   CUDADevice.
%
%   The CUDADevice has various properties describing the capabilities of the
%   underlying device.
%
%   See also parallel.gpu.GPUDevice, gpuDevice, gpuDeviceCount.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:24:42 $
classdef CUDADevice < parallel.gpu.GPUDevice
    properties ( SetAccess = private )
        % Name - Name of the CUDA Device
        Name;

        % Index - Index of the CUDA Device
        %   This is the index by which the device can be selected
        Index;
        
        % ComputeCapability - CUDA Compute Capability
        %   This indicates the computational capability of the device
        ComputeCapability;
        
        % SupportsDouble - Does the device support double precision data
        %   True for devices which can support double precision operations
        SupportsDouble;
        
        % DriverVersion - the CUDA driver version
        %   The CUDA device driver version currently in use
        DriverVersion;
        
        % MaxThreadsPerBlock - maximum supported thread block size
        %   This is the maximum number of threads per block during
        %   CUDAKernel execution
        MaxThreadsPerBlock;
        
        % MaxShmemPerBlock - maximum amount of shared memory per block
        %   The maximum amount of shared memory that can be used by
        %   a thread block during CUDAKernel execution
        MaxShmemPerBlock;

        % MaxThreadBlockSize - maximum size in each dimension for thread block
        %   Each dimension of a thread block must not exceed these
        %   dimensions. Additionally, the product of the thread block size must
        %   not exceed MaxThreadsPerBlock.
        MaxThreadBlockSize;

        % MaxGridSize - maximum size of grid of thread blocks
        MaxGridSize;
        
        % SIMDWidth - number of simultaneously executing threads
        SIMDWidth;
        
        % TotalMemory - total available memory in bytes on the device
        TotalMemory;
    end
    properties ( Dependent = true, SetAccess = private )
        % FreeMemory - free memory in bytes on the device
        %   This property is only available for the currently selected
        %   device, and will have the value NaN for unselected devices
        FreeMemory;
    end
    properties ( SetAccess = private )
        % MultiprocessorCount - the number of vector processors present
        %   The total core count of the device is 8 times this property
        MultiprocessorCount;
        
        % GPUOverlapsTransfers - whether the device supports overlapped transfers
        GPUOverlapsTransfers;
        
        % KernelExecutionTimeout - if true, the device may abort long-running kernels
        KernelExecutionTimeout;
        
        % DeviceSupported - can this device be used
        %   Not all devices are supported, for example if their ComputeCapability
        %   is insufficient. 
        DeviceSupported;
    end
    properties ( Dependent = true, SetAccess = private )
        % DeviceSelected - is this the currently selected device
        DeviceSelected;
    end


    methods
        function fm = get.FreeMemory( obj )
            if obj.isCurrent() && obj.DeviceSupported
                fm = parallel.internal.gpu.currentDeviceFreeMem();
            else
                fm = NaN;
            end
        end
        function tf = get.DeviceSelected( obj )
            tf = obj.isCurrent();
        end
    end

    % Deny access to static methods through CUDADevice
    methods ( Static, Hidden )
        function count()
            iError();
        end
        function current()
            iError();
        end
        function select( ~ )
            iError();
        end
        function getDevice( ~ )
            iError();
        end
    end

    methods ( Access = private )
        function obj = CUDADevice( propStruc )
            if nargin == 0
                error( 'parallel:gpu:CUDADevice', ...
                       'Please use parallel.gpu.GPUDevice methods to access an object of class CUDADevice' );
            end
            obj.Name                   = propStruc.DeviceName;
            obj.Index                  = propStruc.DeviceIndex;
            obj.ComputeCapability      = propStruc.ComputeCapability;
            obj.SupportsDouble         = propStruc.DeviceSupportsDouble;
            obj.DeviceSupported        = propStruc.DeviceSupported;
            obj.DriverVersion          = propStruc.DriverVersion;
            obj.MaxThreadsPerBlock     = propStruc.MaxThreadsPerBlock;
            obj.MaxShmemPerBlock       = propStruc.MaxShmemPerBlock;
            obj.MaxGridSize            = propStruc.MaxGridSize;
            obj.MaxThreadBlockSize     = propStruc.MaxThreadBlockSize;
            obj.SIMDWidth              = propStruc.SIMDWidth;
            obj.TotalMemory            = propStruc.TotalMemory;
            obj.MultiprocessorCount    = propStruc.MultiprocessorCount;
            obj.GPUOverlapsTransfers   = propStruc.GPUOverlapsTransfers;
            obj.KernelExecutionTimeout = propStruc.KernelExecutionTimeout;
        end
        
        function tf = isCurrent( obj )
            tf = ( obj.Index == parallel.internal.gpu.currentDeviceIndex() );
        end
        
    end

    methods ( Static, Hidden )
        function obj = hBuild( propStruct )
            obj = parallel.gpu.CUDADevice( propStruct );
        end
    end

    methods
        function reset( obj )
        %RESET Reset GPU device
        %   RESET resets the GPU device and invalidates any GPUArrays and
        %   CUDAKernels residing on that device.
        %
        %   See also gpuDevice, parallel.gpu.CUDADevice.
            if ~obj.isCurrent()
                error( 'parallel:gpu:CUDADevice:resetCurrent', ...
                       'Only the current CUDADevice can be reset' );
            end
            parallel.internal.gpu.selectDevice( obj.Index );
        end
    end
end

function iError()
    E = MException( 'parallel:gpu:CUDADevice', ...
                    'Please use static methods on parallel.gpu.GPUDevice' );
    throwAsCaller( E );
end
