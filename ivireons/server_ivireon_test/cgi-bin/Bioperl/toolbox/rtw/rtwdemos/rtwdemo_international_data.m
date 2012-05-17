% $Revision: 1.1.6.2 $
% $Date: 2004/10/06 14:01:00 $
%
% Copyright 1994-2004 The MathWorks, Inc.
%
% Abstract:
%   Data for rtwdemo_international.mdl

clear LIMIT;
clear mpts1;

LIMIT = Simulink.Parameter;
LIMIT.value = 16;
LIMIT.RTWInfo.StorageClass = 'Custom';
LIMIT.RTWInfo.CustomStorageClass = 'Const';
LIMIT.Description = ['Japanese characters in Simulink Parameter description ',...
    sprintf('\n'), 'Simulinkパラメータの説明にある日本語の文字'];

mpts1 = mpt.Signal;
mpts1.DataType = 'auto';
mpts1.Dimensions = -1;
mpts1.RTWInfo.StorageClass = 'Custom';
mpts1.Description = ['Japanese characters in MPT Signal description ', ...
    sprintf('\n'), 'MPT信号の説明にある日本語の文字'];
mpts1.DocUnits = '[]';

