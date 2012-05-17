%% GPU Devices
% This demo shows how to find out the number of  CUDA devices in your
% machine, how to choose which device MATLAB(R) uses, and how to query the
% properties of the currently selected device.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1.4.2 $   $Date: 2010/06/21 17:56:08 $

%% Number of Devices
% The function |gpuDeviceCount| returns the number of CUDA
% devices in your machine:
numDevices = gpuDeviceCount
origDevice = gpuDevice

%% Selecting and Querying Devices
% Use the |gpuDevice| function with no inputs to return an object that
% represent the current device. Use the |gpuDevice| function with a single
% integer input to select a device with that device index. Note that device
% indices are one-based, which is different from the CUDA API. |gpuDevice|
% always returns an object representing the selected device. Not all
% devices are supported, in which case the DeviceSupported property is
% |false|, and the memory properties are not available.

% Ignore warnings about unsupported devices
warnState = warning( 'off', 'parallel:gpu:DeviceCapability' );

for idx = 1:numDevices
    device = gpuDevice( idx )
end

%% Reset to the Original Device
% We use the original properties to revert to the original device.
gpuDevice( origDevice.Index );

% revert warning state
warning( warnState );
displayEndOfDemoMessage(mfilename)
