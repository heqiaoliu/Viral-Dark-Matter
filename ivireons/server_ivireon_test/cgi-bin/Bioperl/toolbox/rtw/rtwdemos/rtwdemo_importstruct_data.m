% RTWDEMO_IMPORTSTRUCT_DATA  Create data objects for rtwdemo_importstruct.mdl

%   $Revision: 1.1.6.1 $   $Date: 2006/06/20 20:22:46 $
%   Copyright 1994-2006 The MathWorks, Inc.

% Clear the base workspace
clear

% Create signal objects
Sensor_In = ECoderDemos.Signal;
Sensor_In.DataType = 'int16';
Sensor_In.Dimensions = [1,1];
Sensor_In.Complexity = 'real';
Sensor_In.InitialValue = '0';

Sensor_Out = ECoderDemos.Signal;
Sensor_Out.DataType = 'int16';
Sensor_Out.Dimensions = [1,1];
Sensor_Out.Complexity = 'real';
Sensor_Out.InitialValue = '0';

% Create parameter objects
OFFSET = ECoderDemos.Parameter;
OFFSET.RTWInfo.StorageClass = 'Custom';
OFFSET.RTWInfo.CustomStorageClass = 'StructPointer';
OFFSET.DataType = 'int16';
OFFSET.Value = 12;

GAIN = ECoderDemos.Parameter;
GAIN.RTWInfo.StorageClass = 'Custom';
GAIN.RTWInfo.CustomStorageClass = 'StructPointer';
GAIN.DataType = 'int16';
GAIN.Value = 2;

