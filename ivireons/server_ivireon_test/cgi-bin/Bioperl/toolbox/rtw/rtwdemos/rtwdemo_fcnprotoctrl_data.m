% $Revision: 1.1.6.1 $
% $Date: 2006/12/20 07:25:08 $
%
% Copyright 1994-2004 The MathWorks, Inc.
%
% Abstract:
%   Data for rtwdemo_slbus.mdl

clear;

BusObject = Simulink.Bus;
BusObject.Description = 'This bus contains sensor measurements';

e1 = Simulink.BusElement;
e1.DataType = 'double';
e1.Name = 'temperature';

e2 = Simulink.BusElement;
e2.DataType = 'double';
e2.Name = 'heat';

e3 = Simulink.BusElement;
e3.DataType = 'double';
e3.Name = 'pressure';
e3.Dimensions = 20;

BusObject.Elements = [e1 e2 e3];

clear e1 e2 e3







