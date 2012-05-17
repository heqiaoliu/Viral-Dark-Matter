%% Linearization of Multirate Models
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/05/23 08:20:29 $

%%
% This example illustrates the process that the command linearize uses
% when extracting a linear model of a nonlinear multirate Simulink(R) model. 
% To illustrate the concepts, the process is first performed using 
% functions from the Control System Toolbox(TM) 
% before it is repeated using the linearize command.

%% Example Problem
%% 
% In the Simulink model |scdmrate.mdl| there are three different sample
% rates specified in five blocks. These blocks are:
%
% * |sysC| - a continuous linear block, 
% * |Integrator| - a continuous integrator,
% * |sysTs1| - a block that has a sample time of 0.01 seconds,
% * |sysTs2| - a block that has a sample time of 0.025 seconds, and
% * |Zero-Order Hold| - a block that samples the incoming signal at 0.01 seconds.
%
sysC = zpk(-2,-10,0.1);
Integrator = zpk([],0,1);
sysTs1 = zpk(-0.7463,[0.4251 0.9735],0.2212,0.01);
sysTs2 = zpk([],0.7788,0.2212,0.025);

%%
% The model below shows how the blocks are connected.
scdmrate

%% 
% In this example we linearize the model between the output of the Constant
% block and the output of the block |sysTs2|.

%% Step 1: Linearizing the Blocks in the Model 
% The first step of the linearization is to linearize each block in the
% model.  The linearization of the Saturation and Zero-Order Hold blocks is 1.  
% The LTI blocks are already linear and therefore remain the same. The new
% model with linearized blocks is shown below.
scdmratestep1

%% Step 2: Rate Conversions
% Because the blocks in the model contain different sample rates, it is not
% possible to create a single-rate linearized model for the system without 
% first using rate conversion functions to convert the various sample rates 
% to a representative single rate. The rate conversion functions use an
% iterative method. The
% iterations begin with a least common multiple of the sample times in the
% model. In this example the sample times are 0, 0.01, and 0.025
% seconds which yields a least common multiple of 0.05.  The rate conversion 
% functions then take the combination of blocks with the fastest sample rate 
% and resample them at the next fastest sample rate. In this example the 
% first iteration converts the combination of the linearized continuous 
% time blocks, |sysC| and |integrator| to a sample time of 0.01 using a 
% zero order hold continuous to discrete conversion.  
sysC_Ts1 = c2d(sysC*Integrator,0.01);

%% 
% The blocks |sysC| and |Integrator| are now replaced by |sysC_Ts1|.
scdmratestep2

%%
% The next iteration converts all the blocks with a sample
% time of 0.01 to a sample time of 0.025. First, the following command 
% represents the combination of these blocks by closing the feedback loop.
sysCL = feedback(sysTs1*sysC_Ts1,1);

%%
% Next, a zero-order hold method converts the closed loop system, sysCL,
% from a sample rate of 0.01 to 0.025.
sysCL_Ts2 = d2d(sysCL,0.025);

%% 
% The system |sysCL_Ts2| then replaces the feedback loop in the model.
scdmratestep3

%% 
% The final iteration resamples the combination of the closed loop system 
% and the block |sysTs2| from a rate of 0.025 seconds to a rate of 0.05 
% seconds.
sys_L = d2d(sysCL_Ts2*sysTs2,0.05)

%% Linearizing the Model using Simulink(R) Control Design(TM) Commands
% We can reproduce these results using the command line interface of 
% Simulink(R) Control Design(TM).
model = 'scdmrate';
io(1) = linio('scdmrate/Constant',1,'in'); 
io(2) = linio('scdmrate/sysTs2',1,'out','on'); 
sys = zpk(linearize(model,io))


displayEndOfDemoMessage(mfilename)