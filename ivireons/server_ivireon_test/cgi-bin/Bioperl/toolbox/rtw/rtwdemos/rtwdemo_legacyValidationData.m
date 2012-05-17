%--------------------------------------------------------
% File legacyValidationData Automatically generated 13-Nov-2006
%--------------------------------------------------------
%  Parameters definitions 

%   Copyright 2007 The MathWorks, Inc.


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
