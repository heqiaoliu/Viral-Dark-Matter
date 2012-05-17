%% Generating Code Using the Real-Time Workshop Product
% 
% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/11/13 04:56:23 $
%
% This demonstration shows you how to quickly generate C code for
% real-time simulation, rapid prototyping, or hardware-in-the-loop (HIL)
% testing applications. 
%
% You select a Real-Time Workshop target for a model, generate
% code, and view the resulting files.
%
%% Open a Model
% In this demo, you generate code for a simple counter model. Open this 
% model by typing the following MATLAB commands:
model='rtwdemo_rtwintro';
open_system(model)

%% Configuring for Different Targets
% You can configure the Real-Time Workshop software to generate code for a 
% variety of targets using code generation options and parameters. The options
% and parameters are consolidated in the configuration set of the model, 
% which you can view in the stand-alone Configuration Parameters dialog
% box or in the Simulink Model Explorer.  
%
% Launch the stand-alone model Configuration Parameters dialog box from the 
% model Simulation menu, or by typing the following MATLAB commands:
cs = getActiveConfigSet(model);
openDialog(cs);

%%
% <<rtw_main_page_grt.jpg>>
%

%% Configuring Model for Standalone Executables and Rapid Prototyping
% You can generate code for a particular target environment or purpose. Some
% built-in targeting options are provided using system target files.
%
% Using the Rapid Simulation Target, you can create standalone executables
% suited for Monte Carlo simulations. If you combine this software with the Parallel
% Computing Toolbox software, you can execute numerous simulations of a
% model faster on a computer cluster than you can execute them on a single
% computer. You can also generate code to perform
% rapid prototyping and hardware-in-the-loop testing using the xPC Target
% product.
%
% In the *Configuration Parameters > Real-Time Workshop* pane, click
% *Browse* to view the list of available targets installed on your computer.
%
% <<rtw_browse_stf_button_grt.jpg>>
%
% <<rtw_target_selection_grt.jpg>>
%

%% Configuring Code Generation Options 
% For this demo, you will use the default general purpose Generic
% Real-Time (GRT) target to generate ANSI C code for a real-time simulator.
% Several code generation options are available with the GRT target. To
% generate code for the default settings, click *Build* 
% in the *Configuration Parameters > Real-Time Workshop* pane.
%
% <<rtw_build_button_grt.jpg>>

%% Generating and Viewing the Code
% After you generate code, the code generation report appears. The file,
% |rtwdemo_rtwintro.c|, is generated with the associated utility and 
% header files. The code contains instrumentation and infrastructure ideal 
% for rapid-prototyping, real-time simulation, and
% hardware-in-the-loop applications where the visibility of all intermediate
% signals and parameters is vital.
%
% <<rtw_report_grt.jpg>>
%
% For more concise and traceable code, use the Embedded Real-Time (ERT) target
% provided with the Real-Time Workshop Embedded Coder product.
%

displayEndOfDemoMessage(mfilename)
