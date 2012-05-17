%RTWDEMO_SIL_MODELBLOCK_DATA Initializes parameters for rtwdemo_sil_modelblock

% $Revision: 1.1.6.1 $
% $Date: 2009/11/13 04:56:19 $
%
% Copyright 2009 The MathWorks, Inc.


% Global parameter that will be initialized when the referenced model is loade
Increment = Simulink.Parameter;
Increment.DataType = 'uint8';
Increment.RTWInfo.StorageClass = 'SimulinkGlobal';
Increment.Value = 1;

SilCounterBus = Simulink.Bus;
SilCounterBus.Description = 'This bus contains counter inputs';

e1 = Simulink.BusElement;
e1.DataType = 'boolean';
e1.Name = 'ticks_to_count';

e2 = Simulink.BusElement;
e2.DataType = 'boolean';
e2.Name = 'reset';

SilCounterBus.Elements = [e1 e2];
clear e1 e2

% Step size
T=0.1;

% Input values
ticks_to_count.time = (0:100)'*T;
ticks_to_count.signals.values = boolean((floor( (0:100)/2)==(0:100)/2)');
ticks_to_count.signals.dimensions = 1;

reset.time = (0:100)'*T;
reset_values = boolean(zeros(101,1)); reset_values(20)=true;
reset.signals.values = reset_values;
clear reset_values
reset.signals.dimensions = 1;
