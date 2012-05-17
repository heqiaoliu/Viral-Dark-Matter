% Next Entry: I_Gain
%----------------------

%   Copyright 2007 The MathWorks, Inc.

I_Gain = double(-0.03);
%----------------------
% Next Entry: I_InAdjMap
%----------------------
I_InAdjMap = double(reshape([0,0.5,1,1.5,2],[1  5]));
%----------------------
% Next Entry: I_InErrMap
%----------------------
I_InErrMap = double(reshape([-1,-0.5,-0.25,-0.05,0,0.05,0.25,0.5,1],[1  9]));
%----------------------
% Next Entry: I_OutMap
%----------------------
I_OutMap = double(reshape([1,0.75,0.6,0,0,0,0.6,0.75,1],[1  9]));
%----------------------
% Next Entry: P_Gain
%----------------------
P_Gain = double(0.74);
%----------------------
% Next Entry: P_InAdjMap
%----------------------
P_InAdjMap = double(reshape([0,0.5,1,1.5,2],[1  5]));
%----------------------
% Next Entry: P_InErrMap
%----------------------
P_InErrMap = double(reshape([-1,-0.25,-0.01,0,0.01,0.25,1],[1  7]));
%----------------------
% Next Entry: P_OutMap
%----------------------
P_OutMap = double(reshape([1,0.25,0,0,0,0.25,1],[1  7]));
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
