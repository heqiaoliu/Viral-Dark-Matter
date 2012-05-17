%% Introduction
% 
% The process for designing and implementing a control algorithm 
% varies from one organization to the next. However, some basic steps
% in the process are common. This demo provides an interactive experience
% of applying MathWorks products to those common basic steps. You work with
% a supplied Simulink(R) model and using Real-Time Workshop(R) Embedded
% Coder, generate code for the model, integrate the generated code
% with an existing system, and validate simulation and executable results.
% 
%% Format
% This demo consists of  the following seven modules:  
%
% * Understanding the Model
% * Configuring the Data Interface
% * Function Partitioning within the Generated Code
% * Calling External C Code from the Simulink Model and Generated Code
% * Integrating the Generated Code into the External Environment
% * Testing the Generated Code
% * Evaluating the Generated Code
% 
% Each module provides the following information and builds on what you learned 
% and generated in previous modules:
% 
% * Estimated completion time
% * Goals
% * Background information, models, tasks, and task activation links that
% help you achieve the module goals
% * Links to the previous and next modules
% * Links to more information about module topics, including alternative
% methods for completing tasks 
% 
% This demo uses scripts that simplify use of the demo. Everything that is done
% by script can be done from the MATLAB(R) prompt or from Simulink menus.
% You execute a script by clicking a Task link. 
% For example, click the following link to execute a script that briefly 
% displays the dialog box shown after the link:
%
% <matlab:RTWDemos.pcgd_example_script *Task:* Run a script to show a dialog box.> 
%
% <html><img vspace="5" hspace="5" src="exampleScript.jpg"></html>
% 
%% Prerequisite Knowledge
% This demo assumes the following prerequisite knowledge: 
% 
% MathWorks products
%
% * How to read, write, and apply MATLAB scripts
% * How to create a basic Simulink and Stateflow model
% * How to run Simulink simulations and evaluate the results
% 
% C programming
%
% * C data types and storage classes
% * Function prototypes and methods of calling functions
% * How to compile a C function 
%
% Metrics for evaluating embedded software
%
% * Basic code readability issues
% * RAM/ROM usage
% 
%% Using This Demo  
% Each module focuses on a specific aspect of code generation or integration.  
% You can complete the modules independently, during different sessions, or
% in a single session. The total estimated completion time is four hours.
%
% <html>
% <p>For most tasks, you have the option of completing the task on
% your own by following the instructions, or you can execute a script by
% clicking its <b><font color="blue">Task</font></b> link. Some scripts require
% time to run.  In such cases, a dialog box appears when the task is complete.
% If for any reason the link fails, error messages appear in the MATLAB 
% Command Window.</p>
% </html>
%
% Each module has a unique model and data set. As a result, the modules are
% fully independent and can be run in any order.  When you transition between 
% modules, the demo saves the current model locally, capturing your
% modifications to the model and model data.
% 
% To recover a model in its original state, delete the local copy of the
% model and model data.  The model data is saved as |PCG_Demo_#_data.mat|.
%
%% Third-Party Software
% The modules *Integrating the Generated Code into the External Environment*
% and *Testing the Generated Code* use the Eclipse IDE and the Cygwin/gcc 
% compiler. Instructions on how to install and use Eclipse and Cygwin/gcc 
% appear at the end of the demo in *Installing and Using Cygwin and Eclipse*.

%   Copyright 2007-2010 The MathWorks, Inc.

displayEndOfDemoMessage(mfilename)
