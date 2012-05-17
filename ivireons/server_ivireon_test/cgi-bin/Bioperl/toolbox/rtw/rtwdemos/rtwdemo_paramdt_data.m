% RTWDEMO_PARAMDT_DATA  Create workspace variables for rtwdemo_paramdt.

% $Revision: 1.1.8.2 $
% $Date: 2007/04/20 20:15:22 $
%
% Copyright 1994-2006 The MathWorks, Inc.

% Clear the base workspace
clear;

%================================================================
% The following parameter does not have its storage class set,
% so it will be inlined into the generated code.
%================================================================

% Create a numeric variable (data type is irrelevant).
Kinline = 2;

%================================================================
% The following parameters have their storage class set to
% 'ExportedGlobal' in the model's "tunable parameters table".
%================================================================

% Create a context-sensitive (double-precision) variable
Kcs = 3;

% Create numeric variables with specific data types
Ksingle = single(4);
Kint8 = int8(5);

%================================================================
% The following parameters are defined using Simulink.Parameter
% objects.  Their storage class is set to 'ExportedGlobal'.
%================================================================

% Create a parameter object with a fixed-point data type
%
% NOTE: You can also create fixed-point parameters using fi objects
%   Kfixpt = fi(6, true, 16, 2^-5, 0);
%
Kfixpt                      = Simulink.Parameter;
Kfixpt.Value                = 6;
Kfixpt.DataType             = 'fixdt(true, 16, 2^-5, 0)';
Kfixpt.RTWInfo.StorageClass = 'ExportedGlobal';

% Create a parameter object that uses an alias data type
aliasType = Simulink.AliasType('single');

Kalias = Simulink.Parameter;
Kalias.Value                = 7;
Kalias.DataType             = 'aliasType';
Kalias.RTWInfo.StorageClass = 'ExportedGlobal';

% Create a parameter object that uses a user-defined data type
userType              = Simulink.NumericType;
userType.DataTypeMode = 'Fixed-point: slope and bias scaling';
userType.Slope        = 2^-3;
userType.isAlias      = true;

Kuser                      = Simulink.Parameter;
Kuser.Value                = 8;
Kuser.DataType             = 'userType';
Kuser.RTWInfo.StorageClass = 'ExportedGlobal';
