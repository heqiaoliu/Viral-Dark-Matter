% $Revision: 1.1.6.2 $
% $Date: 2009/05/14 17:30:49 $
%
% Copyright 1994-2009 The MathWorks, Inc.
%
% Abstract:
%   Data for rtwdemo_namerules

clear;

% Signals
A     = Simulink.Signal;
B     = Simulink.Signal;
C     = Simulink.Signal;
L     = Simulink.Signal;
Final = Simulink.Signal;

A.RTWInfo.StorageClass = 'ExportedGlobal';
B.RTWInfo.StorageClass = 'ExportedGlobal';
C.RTWInfo.StorageClass = 'ExportedGlobal';
L.RTWInfo.StorageClass = 'ExportedGlobal';
Final.RTWInfo.StorageClass = 'ExportedGlobal';

% Parameters
F1 = Simulink.Parameter;
G1 = Simulink.Parameter;
G2 = Simulink.Parameter;
G3 = Simulink.Parameter;
K1 = Simulink.Parameter;

F1.RTWInfo.StorageClass = 'ExportedGlobal';
G1.RTWInfo.StorageClass = 'ExportedGlobal';
G2.RTWInfo.StorageClass = 'ExportedGlobal';
G3.RTWInfo.StorageClass = 'ExportedGlobal';
K1.RTWInfo.StorageClass = 'Custom';
K1.RTWInfo.CustomStorageClass = 'Define';

F1.Value = 2;
G1.Value = 3;
G2.Value = 4;
G3.Value = 5;
K1.Value = 6;

% Data Store Memory
DS = Simulink.Signal;
DS.RTWInfo.StorageClass = 'ExportedGlobal';
