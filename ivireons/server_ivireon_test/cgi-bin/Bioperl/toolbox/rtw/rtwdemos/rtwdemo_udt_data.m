% $Revision: 1.1.4.4 $
% $Date: 2005/12/19 07:38:26 $
%
% Copyright 1994-2005 The MathWorks, Inc.
%
% Abstract:
%   Data for rtwdemo_udt.mdl

clear;

% Define replacement types
FLOAT64 = Simulink.AliasType('double');
FLOAT32 = Simulink.AliasType('single');
S32 = Simulink.AliasType('int32');
S16 = Simulink.AliasType('int16');
S8  = Simulink.AliasType('int8');
U32 = Simulink.AliasType('uint32');
U16 = Simulink.AliasType('uint16');
U8  = Simulink.AliasType('uint8');
CHAR  = Simulink.AliasType('int8');

ENG_SPEED = Simulink.NumericType;
ENG_SPEED.Description = 'Engine speed type';
ENG_SPEED.DataTypeMode = 'Single';
ENG_SPEED.IsAlias = true; % Alias to single

ENG_SPEED_OFFSET = Simulink.AliasType('ENG_SPEED');
ENG_SPEED_OFFSET.Description = 'Alias to ENG_SPEED';
