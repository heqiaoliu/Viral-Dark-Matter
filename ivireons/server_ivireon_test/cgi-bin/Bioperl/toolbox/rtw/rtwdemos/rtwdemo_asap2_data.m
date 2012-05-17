% Abstract:
%   Data for rtwdemo_asap2.mdl
%
%   Copyright 1994-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/04/21 21:37:50 $

% Define parameter objects
k1 = Simulink.Parameter; 
k1.RTWInfo.StorageClass = 'ExportedGlobal'; 
k1.Value       =  2;
k1.Description = 'k1 gain';
k1.Min         = -2;
k1.Max         =  2;
k1.DocUnits    = 'm/(s^2)';
            
k2 = Simulink.Parameter; 
k2.RTWInfo.StorageClass = 'ExportedGlobal'; 
k2.Value       =  3;
k2.Description = 'k2 gain';
k2.Min         = -3;
k2.Max         =  3;
k2.DocUnits    = 'rpm';
            
xbreak1 = Simulink.Parameter; 
xbreak1.RTWInfo.StorageClass = 'ExportedGlobal'; 
xbreak1.Value       = (-1:0.1:1);
xbreak1.Description = 'X1 break data';
xbreak1.Min         = -1;
xbreak1.Max         =  1;
xbreak1.DocUnits    = 'rpm';


xbreak2 = Simulink.Parameter; 
xbreak2.RTWInfo.StorageClass = 'ExportedGlobal'; 
xbreak2.Value       = (-1:0.1:1);
xbreak2.Description = 'X2 break data';
xbreak2.Min         = -1;
xbreak2.Max         =  1;
xbreak2.DocUnits    = 'rpm';


ybreak = Simulink.Parameter; 
ybreak.RTWInfo.StorageClass = 'ExportedGlobal'; 
ybreak.Value       = (-5:5);
ybreak.Description = 'Y break data';
ybreak.Min         = -5;
ybreak.Max         =  5;
ybreak.DocUnits    = 'rpm';

ydata1 = Simulink.Parameter; 
ydata1.RTWInfo.StorageClass = 'ExportedGlobal'; 
ydata1.Value       = (-1:0.1:1)*2;
ydata1.Description = 'Y data';
ydata1.Min         = -2;
ydata1.Max         =  2;
ydata1.DocUnits    = 'm/(s^2)';

ydata2 = Simulink.Parameter; 
ydata2.RTWInfo.StorageClass = 'ExportedGlobal';
ydata2.Value       = (-10:1:10)*2;
ydata2.Description = 'Y data';
ydata2.Min         = -20;
ydata2.Max         =  20;
ydata2.DocUnits    = 'm/(s^2)';
            
zdata = Simulink.Parameter; 
zdata.RTWInfo.StorageClass = 'ExportedGlobal'; 
zdata.Value       = meshgrid((-5:5), (-1:0.1:1))*2;
zdata.Description = 'Z data';
zdata.Min         = -10;
zdata.Max         =  10;
zdata.DocUnits    = 'm/(s^2)';
            
% Define signal objects

input1 = Simulink.Signal; 
input1.RTWInfo.StorageClass = 'ExportedGlobal'; 
input1.Description = 'Input signal 1';
input1.Min         = -3;
input1.Max         =  3;
input1.DocUnits    = 'rpm';

input2 = Simulink.Signal; 
input2.RTWInfo.StorageClass = 'ExportedGlobal'; 
input2.Description = 'Input signal 2';
input2.Min         = -10;
input2.Max         =  10;
input2.DocUnits    = 'rpm';

sig1 = Simulink.Signal; 
sig1.RTWInfo.StorageClass = 'ExportedGlobal'; 
sig1.Description = 'Intermediate signal value sig1';
sig1.Min         = -2;
sig1.Max         =  2;
sig1.DocUnits = 'm/(s^2)';
            
sig2 = Simulink.Signal; 
sig2.RTWInfo.StorageClass = 'ExportedGlobal'; 
sig2.Description = 'Intermediate signal value sig2';
sig2.Min         = -20;
sig2.Max         =  20;
sig2.DocUnits    = 'm/(s^2)';
