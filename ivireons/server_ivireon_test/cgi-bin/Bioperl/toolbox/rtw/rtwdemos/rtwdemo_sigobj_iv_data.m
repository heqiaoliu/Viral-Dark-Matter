% RTWDEMO_SIGOBJ_IV_DATA  Create data objects for rtwdemo_sigobj_iv.mdl

% $Revision: 1.1.8.1 $
% $Date: 2006/03/10 01:56:13 $
%
% Copyright 1994-2006 The MathWorks, Inc.

% Clear the base workspace
clear

% Create signal objects to specify initial value of signals.
S1 = Simulink.Signal;
S1.RTWInfo.StorageClass = 'ExportedGlobal';
S1.InitialValue = '-4.5';

S2 = Simulink.Signal;
S2.RTWInfo.StorageClass = 'ExportedGlobal';
S2.InitialValue = 'aa2';

S3 = Simulink.Signal;
S3.RTWInfo.StorageClass = 'ExportedGlobal';
S3.InitialValue = '-3.0';

% Create signal objects to specify initial value of states.
X1 = Simulink.Signal;
X1.RTWInfo.StorageClass = 'ExportedGlobal';
X1.InitialValue = 'aa1';

X2 = Simulink.Signal;
X2.RTWInfo.StorageClass = 'ExportedGlobal';
X2.InitialValue = '-3.5';

% Create parameters used by these signal objects.
aa1 = Simulink.Parameter;
aa1.RTWInfo.StorageClass = 'ExportedGlobal';
aa1.Value = -2.5;

aa2 = -2.0;  % Storage class set in model's tunable parameters table.

