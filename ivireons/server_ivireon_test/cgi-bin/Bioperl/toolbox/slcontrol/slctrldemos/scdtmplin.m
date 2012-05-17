%% Linearization of a Pulp Paper Process
% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/05/23 08:20:49 $

%% Introduction
% Thermo-mechanical pulping (TMP) is a process used for producing
% mechanical pulp for newsprint. The Simulink(R) model scdtmp is of a typical
% process arrangement for a two stage TMP operation: two pressured refiners
% operate in sequence, the primary refiner produces a course pulp from a
% feed of wood chips and water, the secondary refiner further develops the
% pulp bonding properties so that it is suitable for paper making. The
% refiners physically consist of two disks (either contra-rotating or one
% static and the other rotating) with overlaid grooved surfaces. These
% surfaces physically impact on a three phase flow of wood fibers, steam
% and water that passes from the center of the refiner disks to their
% periphery. The physical impact of the disk surfaces on the wood fibers:
% i.) breaks rigid chemical and physical bonds between them; ii.)
% microscopically roughens the surface of individual fibers enabling them
% to mesh together on the paper sheet. The primary objective of controlling
% the TMP plant is to apply sufficient energy to derive pulp with good
% physical properties without incurring excess energy costs or fiber damage
% due imposition of overly high stresses as fibers pass through the
% refiners. For practical purposes this amounts to controlling the ratio of
% the total electrical energy applied by the two refiners to the dry mass
% flow rate of wood fibers, i.e., controlling the estimated specific energy
% applied to the pulp. A secondary control objective is to control the
% ratio of dry mass flow rate (fibers) to overall mass flow rate (water &
% fibers) (known as pulp consistency) to a value which optimizes a
% trade-off between cost (energy consumed) and pulp quality. 

%% 
% The process I/O for a TMP system is as follows

%%
% Inputs: 
%
% * Feed rate of chips (Feed rpm), 
% * Dilution water flow to each of the refiners (Primary and secondary dilution set points), 
% * Set points to two regulatory controllers which control the gap between the rotating disks in each set of refiners. 

%% 
% Outputs: 
%
% * Primary and secondary refiner consistencies, 
% * Primary and secondary refiner motor loads, 
% * Vibration monitor measurements on the two refiners. 

%%
% In this example it is desired to find a linear model of this system at a 
% steady state operating condition for the following input set point conditions: 
%
% * Feed Rate = 30 
% * Primary Gap = 0.8 
% * Primary Diluation = 170 
% * Secondary Gap = 0.5 
% * Secondary Dilution = 120

%% Generation of Operating Points
% Open the Simulink model
open_system('scdtmp')
 
%%
% To get operating point specification object use the command 
opspec = operspec('scdtmp')

%%
% The Feed Rate set point specification is set by
opspec.Inputs(1).Known = 1;
opspec.Inputs(1).u = 30;

%%
% The Primary Gap set point specification is set by
opspec.Inputs(2).Known = 1;
opspec.Inputs(2).u = 0.8;

%% 
% The Primary Dilution set point specification is set by
opspec.Inputs(3).Known = 1;
opspec.Inputs(3).u = 170;

%%
% The Secondary Gap set point specification is set by
opspec.Inputs(4).Known = 1;
opspec.Inputs(4).u = 0.5;

%%
% The Secondary Dilution set point is set by
opspec.Inputs(5).Known = 1;
opspec.Inputs(5).u = 120;

%%
% The steady state operating point that meets this specification is found by
op = findop('scdtmp',opspec);

%% Model Linearization
% The operating points are now ready for linearization. The first step is to specify the input and output points using the commands: 
io(1) = linio('scdtmp/Feed rpm',1,'in');
io(2) = linio('scdtmp/Pri gap set point',1,'in');
io(3) = linio('scdtmp/Pri dil flow set point',1,'in');
io(4) = linio('scdtmp/Sec. gap set point',1,'in');
io(5) = linio('scdtmp/Sec. dilution set point',1,'in');
io(6) = linio('scdtmp/Mux',1,'out');

%%
% The model can then be linearized using the command.
sys = linearize('scdtmp',op,io);

%%
% The Bode plot for the transfer function between the Primary Gap set point and the Primary Consistency can be seen by using the command: 
bode(sys(2,2))

%%
% Close the model.
bdclose('scdtmp')
displayEndOfDemoMessage(mfilename)