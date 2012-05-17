
%   Copyright 2009 The MathWorks, Inc.

Seed = round(cputime*1000);
K1 = 3;
K2 = 4;
K3 = 2.7;

% Bus object definitions
BottomBus = Simulink.Bus;
el1 = Simulink.BusElement;
el1.Name = 'lo0';
el1.Dimensions = [2 2];
el1.DataType = 'fixdt(0,16,2^-8,0)';
el2 = Simulink.BusElement;
el2.Name = 'lo1';
el2.Dimensions = 1;
el2.DataType = 'double';
el3 = Simulink.BusElement;
el3.Name = 'lo2';
el3.Dimensions = 1;
el3.DataType = 'double';
BottomBus.Elements = [el1 el2 el3];

MidBus = Simulink.Bus;
el1 = Simulink.BusElement;
el1.Name = 'mid0';
el1.Dimensions = 1;
el1.DataType = 'BottomBus';
el2 = Simulink.BusElement;
el2.Name = 'mid1';
el2.Dimensions = 2;
el2.DataType = 'int16';
MidBus.Elements = [el1 el2];

TopBus = Simulink.Bus;
el1 = Simulink.BusElement;
el1.Name = 'hi0';
el1.DataType  ='int8';
el1.Dimensions = 2;
el2 = Simulink.BusElement;
el2.Name = 'hi1';
el2.Dimensions = 1;
el2.DataType = 'MidBus';
TopBus.Elements = [el1 el2];
