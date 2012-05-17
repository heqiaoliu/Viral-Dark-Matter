%--------------------------------------------------------
% File PCG_Eval_Base_Data_Stage_2 Automatically generated 13-Dec-2006
%--------------------------------------------------------
%  Base Signals definitions 

%   Copyright 2007 The MathWorks, Inc.

%  Parameters definitions 


%----------------------
% Next Entry: I_Gain
%----------------------
I_Gain = Simulink.Parameter;
I_Gain.RTWInfo.StorageClass =  'Custom';
I_Gain.RTWInfo.Alias = char([]);
I_Gain.RTWInfo.CustomStorageClass =  'Const';
I_Gain.Description = char([]);
I_Gain.DataType =  'auto';
I_Gain.Min = double(-Inf);
I_Gain.Max = double(Inf);
I_Gain.DocUnits = char([]);
I_Gain.Value = double(-0.03);
%----------------------
% Next Entry: I_InErrMap
%----------------------
I_InErrMap = Simulink.Parameter;
I_InErrMap.RTWInfo.StorageClass =  'Custom';
I_InErrMap.RTWInfo.Alias = char([]);
I_InErrMap.RTWInfo.CustomStorageClass =  'Const';
I_InErrMap.Description = char([]);
I_InErrMap.DataType =  'auto';
I_InErrMap.Min = double(-Inf);
I_InErrMap.Max = double(Inf);
I_InErrMap.DocUnits = char([]);
I_InErrMap.Value = double(reshape([-1,-0.5,-0.25,-0.05,0,0.05,0.25,0.5,1],[1  9]));
%----------------------
% Next Entry: I_OutMap
%----------------------
I_OutMap = Simulink.Parameter;
I_OutMap.RTWInfo.StorageClass =  'Custom';
I_OutMap.RTWInfo.Alias = char([]);
I_OutMap.RTWInfo.CustomStorageClass =  'Const';
I_OutMap.Description = char([]);
I_OutMap.DataType =  'auto';
I_OutMap.Min = double(-Inf);
I_OutMap.Max = double(Inf);
I_OutMap.DocUnits = char([]);
I_OutMap.Value = double(reshape([1,0.75,0.6,0,0,0,0.6,0.75,1],[1  9]));
%----------------------
% Next Entry: P_Gain
%----------------------
P_Gain = Simulink.Parameter;
P_Gain.RTWInfo.StorageClass =  'Custom';
P_Gain.RTWInfo.Alias = char([]);
P_Gain.RTWInfo.CustomStorageClass =  'Const';
P_Gain.Description = char([]);
P_Gain.DataType =  'auto';
P_Gain.Min = double(-Inf);
P_Gain.Max = double(Inf);
P_Gain.DocUnits = char([]);
P_Gain.Value = double(0.74);
%----------------------
% Next Entry: P_InErrMap
%----------------------
P_InErrMap = Simulink.Parameter;
P_InErrMap.RTWInfo.StorageClass =  'Custom';
P_InErrMap.RTWInfo.Alias = char([]);
P_InErrMap.RTWInfo.CustomStorageClass =  'Const';
P_InErrMap.Description = char([]);
P_InErrMap.DataType =  'auto';
P_InErrMap.Min = double(-Inf);
P_InErrMap.Max = double(Inf);
P_InErrMap.DocUnits = char([]);
P_InErrMap.Value = double(reshape([-1,-0.25,-0.01,0,0.01,0.25,1],[1  7]));
%----------------------
% Next Entry: P_OutMap
%----------------------
P_OutMap = Simulink.Parameter;
P_OutMap.RTWInfo.StorageClass =  'Custom';
P_OutMap.RTWInfo.Alias = char([]);
P_OutMap.RTWInfo.CustomStorageClass =  'Const';
P_OutMap.Description = char([]);
P_OutMap.DataType =  'auto';
P_OutMap.Min = double(-Inf);
P_OutMap.Max = double(Inf);
P_OutMap.DocUnits = char([]);
P_OutMap.Value = double(reshape([1,0.25,0,0,0,0.25,1],[1  7]));
%  Signals definitions 


%----------------------
% Next Entry: ThrotComm
%----------------------
ThrotComm = Simulink.Signal;
ThrotComm.RTWInfo.StorageClass =  'ExportedGlobal';
ThrotComm.RTWInfo.Alias = char([]);
ThrotComm.RTWInfo.CustomStorageClass =  'Default';
ThrotComm.Description = char([]);
ThrotComm.DataType =  'auto';
ThrotComm.Min = double(-Inf);
ThrotComm.Max = double(Inf);
ThrotComm.DocUnits = char([]);
ThrotComm.Dimensions = double(-1);
ThrotComm.Complexity =  'auto';
ThrotComm.SampleTime = double(-1);
ThrotComm.SamplingMode =  'auto';
ThrotComm.InitialValue = char([]);
%----------------------
% Next Entry: Throt_Param
%----------------------
Throt_Param = Simulink.Signal;
Throt_Param.RTWInfo.StorageClass =  'ExportedGlobal';
Throt_Param.RTWInfo.Alias = char([]);
Throt_Param.RTWInfo.CustomStorageClass =  'Default';
Throt_Param.Description = char([]);
Throt_Param.DataType =  'auto';
Throt_Param.Min = double(-Inf);
Throt_Param.Max = double(Inf);
Throt_Param.DocUnits = char([]);
Throt_Param.Dimensions = double(-1);
Throt_Param.Complexity =  'auto';
Throt_Param.SampleTime = double(-1);
Throt_Param.SamplingMode =  'auto';
Throt_Param.InitialValue = char([]);
%----------------------
% Next Entry: error_reset
%----------------------
error_reset = Simulink.Signal;
error_reset.RTWInfo.StorageClass =  'Auto';
error_reset.RTWInfo.Alias = char([]);
error_reset.RTWInfo.CustomStorageClass =  'Default';
error_reset.Description = char([]);
error_reset.DataType =  'auto';
error_reset.Min = double(-Inf);
error_reset.Max = double(Inf);
error_reset.DocUnits = char([]);
error_reset.Dimensions = double(-1);
error_reset.Complexity =  'auto';
error_reset.SampleTime = double(-1);
error_reset.SamplingMode =  'auto';
error_reset.InitialValue = char([]);
%----------------------
% Next Entry: fail_safe_pos
%----------------------
fail_safe_pos = Simulink.Signal;
fail_safe_pos.RTWInfo.StorageClass =  'Auto';
fail_safe_pos.RTWInfo.Alias = char([]);
fail_safe_pos.RTWInfo.CustomStorageClass =  'Default';
fail_safe_pos.Description = char([]);
fail_safe_pos.DataType =  'auto';
fail_safe_pos.Min = double(-Inf);
fail_safe_pos.Max = double(Inf);
fail_safe_pos.DocUnits = char([]);
fail_safe_pos.Dimensions = double(-1);
fail_safe_pos.Complexity =  'auto';
fail_safe_pos.SampleTime = double(-1);
fail_safe_pos.SamplingMode =  'auto';
fail_safe_pos.InitialValue = char([]);
%----------------------
% Next Entry: fbk_2
%----------------------
fbk_2 = Simulink.Signal;
fbk_2.RTWInfo.StorageClass =  'ImportedExtern';
fbk_2.RTWInfo.Alias = char([]);
fbk_2.RTWInfo.CustomStorageClass =  'Default';
fbk_2.Description = char([]);
fbk_2.DataType =  'double';
fbk_2.Min = double(-Inf);
fbk_2.Max = double(Inf);
fbk_2.DocUnits = char([]);
fbk_2.Dimensions = double(-1);
fbk_2.Complexity =  'auto';
fbk_2.SampleTime = double(-1);
fbk_2.SamplingMode =  'auto';
fbk_2.InitialValue = char([]);
%----------------------
% Next Entry: max_diff
%----------------------
max_diff = Simulink.Signal;
max_diff.RTWInfo.StorageClass =  'Auto';
max_diff.RTWInfo.Alias = char([]);
max_diff.RTWInfo.CustomStorageClass =  'Default';
max_diff.Description = char([]);
max_diff.DataType =  'auto';
max_diff.Min = double(-Inf);
max_diff.Max = double(Inf);
max_diff.DocUnits = char([]);
max_diff.Dimensions = double(-1);
max_diff.Complexity =  'auto';
max_diff.SampleTime = double(-1);
max_diff.SamplingMode =  'auto';
max_diff.InitialValue = char([]);
%----------------------
% Next Entry: pos_cmd_one
%----------------------
pos_cmd_one = Simulink.Signal;
pos_cmd_one.RTWInfo.StorageClass =  'ExportedGlobal';
pos_cmd_one.RTWInfo.Alias = char([]);
pos_cmd_one.RTWInfo.CustomStorageClass =  'Default';
pos_cmd_one.Description =  'Throttle position command from the first PI controller';
pos_cmd_one.DataType =  'double';
pos_cmd_one.Min = double(-1);
pos_cmd_one.Max = double(1);
pos_cmd_one.DocUnits =  'Norm';
pos_cmd_one.Dimensions = double(-1);
pos_cmd_one.Complexity =  'auto';
pos_cmd_one.SampleTime = double(-1);
pos_cmd_one.SamplingMode =  'auto';
pos_cmd_one.InitialValue =  '0';
%----------------------
% Next Entry: pos_rqst
%----------------------
pos_rqst = Simulink.Signal;
pos_rqst.RTWInfo.StorageClass =  'ImportedExternPointer';
pos_rqst.RTWInfo.Alias = char([]);
pos_rqst.RTWInfo.CustomStorageClass =  'Default';
pos_rqst.Description = char([]);
pos_rqst.DataType =  'double';
pos_rqst.Min = double(-Inf);
pos_rqst.Max = double(Inf);
pos_rqst.DocUnits = char([]);
pos_rqst.Dimensions = double(-1);
pos_rqst.Complexity =  'auto';
pos_rqst.SampleTime = double(-1);
pos_rqst.SamplingMode =  'auto';
pos_rqst.InitialValue = char([]);
%  Buses definitions 


%----------------------
% Next Entry: ThrottleCommands
%----------------------
ThrottleCommands = Simulink.Bus;
ThrottleCommands.Description = char([]);
ThrottleCommands.HeaderFile =  'ThrottleBus.h';
eleTmp(1) = Simulink.BusElement;
eleTmp(1).Name =  'pos_cmd_raw';
eleTmp(1).DataType =  'double';
eleTmp(1).Complexity =  'real';
eleTmp(1).Dimensions = double(2);
eleTmp(1).SamplingMode =  'Sample based';
eleTmp(1).SampleTime = double(-1);
eleTmp(2) = Simulink.BusElement;
eleTmp(2).Name =  'pos_cmd_act';
eleTmp(2).DataType =  'double';
eleTmp(2).Complexity =  'real';
eleTmp(2).Dimensions = double(1);
eleTmp(2).SamplingMode =  'Sample based';
eleTmp(2).SampleTime = double(-1);
eleTmp(3) = Simulink.BusElement;
eleTmp(3).Name =  'pos_failure_mode';
eleTmp(3).DataType =  'double';
eleTmp(3).Complexity =  'real';
eleTmp(3).Dimensions = double(1);
eleTmp(3).SamplingMode =  'Sample based';
eleTmp(3).SampleTime = double(-1);
eleTmp(4) = Simulink.BusElement;
eleTmp(4).Name =  'err_cnt';
eleTmp(4).DataType =  'double';
eleTmp(4).Complexity =  'real';
eleTmp(4).Dimensions = double(1);
eleTmp(4).SamplingMode =  'Sample based';
eleTmp(4).SampleTime = double(-1);
ThrottleCommands.Elements = eleTmp;
clear eleTmp;
%----------------------
% Next Entry: ThrottleParams
%----------------------
ThrottleParams = Simulink.Bus;
ThrottleParams.Description = char([]);
ThrottleParams.HeaderFile =  'ThrottleBus.h';
eleTmp(1) = Simulink.BusElement;
eleTmp(1).Name =  'fail_safe_pos';
eleTmp(1).DataType =  'double';
eleTmp(1).Complexity =  'real';
eleTmp(1).Dimensions = double(1);
eleTmp(1).SamplingMode =  'Sample based';
eleTmp(1).SampleTime = double(-1);
eleTmp(2) = Simulink.BusElement;
eleTmp(2).Name =  'max_diff';
eleTmp(2).DataType =  'double';
eleTmp(2).Complexity =  'real';
eleTmp(2).Dimensions = double(1);
eleTmp(2).SamplingMode =  'Sample based';
eleTmp(2).SampleTime = double(-1);
eleTmp(3) = Simulink.BusElement;
eleTmp(3).Name =  'error_reset';
eleTmp(3).DataType =  'double';
eleTmp(3).Complexity =  'real';
eleTmp(3).Dimensions = double(1);
eleTmp(3).SamplingMode =  'Sample based';
eleTmp(3).SampleTime = double(-1);
ThrottleParams.Elements = eleTmp;
clear eleTmp;
