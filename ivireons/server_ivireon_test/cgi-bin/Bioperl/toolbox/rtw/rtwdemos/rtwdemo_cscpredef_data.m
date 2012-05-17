% $Revision: 1.1.6.3 $
% $Date: 2008/12/01 07:30:45 $
%
% Copyright 1994-2008 The MathWorks, Inc.
%
% Abstract:
%   Data for rtwdemo_cscpredef.mdl

clear;

templimit=Simulink.Parameter;
templimit.RTWInfo.StorageClass= 'Custom';
templimit.RTWInfo.CustomStorageClass= 'ConstVolatile';
templimit.Value = 202.0;

pressurelimit=Simulink.Parameter;
pressurelimit.RTWInfo.StorageClass= 'Custom';
pressurelimit.RTWInfo.CustomStorageClass= 'ConstVolatile';
pressurelimit.Value = 45.2;

O2limit=Simulink.Parameter;
O2limit.RTWInfo.StorageClass= 'Custom';
O2limit.RTWInfo.CustomStorageClass= 'ConstVolatile';
O2limit.Value = 0.96;

rpmlimit=Simulink.Parameter;
rpmlimit.RTWInfo.StorageClass= 'Custom';
rpmlimit.RTWInfo.CustomStorageClass= 'ConstVolatile';
rpmlimit.Value = 7400.0;