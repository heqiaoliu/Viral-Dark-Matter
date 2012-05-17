%% Testing the Generated Code
% *Overview:* Shows two approaches for validating the generated code: the
% use of system-level S-functions and running code in an external
% environment.
%
% *Time*: 45 minutes
%
% *Goals*
% 
% Understand...
%
% * Different methods available for testing generated code
% * How to test generated code in Simulink(R)
% * How to test generated code outside of Simulink
%
% <matlab:RTWDemos.pcgd_open_pcg_model(6,0); *Task:* Open the model.> 
%% Validation Methods for Generated Code
% Simulink supports multiple system testing methods for validating the
% behavior 
% of generated code.  
%
% <html>
%     <table border = "1">
%         <tr valign = "top">
%             <td align = "center"><b>Test Method</b></td>
%             <td align = "center"><b>Description</b></td>
%             <td align = "center"><b>Pros</b></td>
%             <td align = "center"><b>Cons</b></td>
%         </tr>    
%         <tr valign = "top">
%             <td>Windows run-time executable</td>
%             <td align = "left">Generate a Microsoft Windows based executable and run the executable from the command prompt.</td>
%             <td align = "left"><ul>
%                                  <li>Easy to create
%                                  <li>Can use C debugger to evaluate code
%                                </ul></td>
%             <td align = "left"><ul>
%                                  <li>Partial emulation of target hardware
%                                </ul></td>
%         </tr>
%         <tr valign = "top">
%             <td>Software-in-the-loop (SIL)</td>
%             <td align = "left">Use an S-function wrapper to include the generated code back into the Simulink model.</td>
%             <td align = "left"><ul>
%                                 <li>Easy to create
%                                 <li>Allows you to reuse the Simulink test environment
%                                 <li>Can use C debugger to evaluate code
%                               </ul></td>
%             <td align = "left"><ul>
%                                  <li>Partial emulation of target hardware
%                                </ul></td>
%         </tr>
%         <tr valign = "top">
%             <td>Processor in the loop (PIL)</td>
%             <td align = "left">Run a non-real-time cosimulation with Simulink executing a portion of the model (e.g. Plant Model), and the target processor running a portion of the model (e.g. Controller). Code is downloaded to the target processor, and processor-in-the-loop handles the communication of signals between Simulink and the target during cosimulation.</td>
%             <td align = "left"><ul>
%                                  <li>Allows you to reuse the Simulink test environment
%                                  <li>Can use C debugger with the simulation
%                                  <li>Actual processor is used
%                                </ul></td>
%             <td align = "left"><ul>
%                                  <li>Requires additional steps to set up test environment
%                                  <li>Processor does not run in real time
%                                </ul></td>
%         </tr>
%         <tr valign = "top">
%             <td>On-target rapid prototyping</td>
%             <td align = "left">Run generated code on the target processor as part of the full system.</td>
%             <td align = "left"><ul>
%                                  <li>Can determine actual hardware constraints
%                                  <li>Allows testing of component within the full system
%                                  <li>Processor runs in real time
%                                </ul></td>
%             <td align = "left"><ul>
%                                  <li>Requires hardware
%                                  <li>Requires additional steps to set up test environment
%                                </ul></td>
%         </tr>
%         <tr valign = "top">
%             <td>External Mode</td>
%             <td align = "left">Run generated code on the target processor as part of the full system.</td>
%             <td align = "left"><ul>
%                                  <li>Can determine actual hardware constraints
%                                  <li>Allows testing of component within the full system
%                                </ul></td>
%             <td align = "left"><ul>
%                                  <li>Requires hardware
%                                  <li>Requires additional steps to set up test environment
%                                </ul></td>
%         </tr>
%     </table>
% </html>
%
%% Reusing Test Data: Test Vector Import/Export
% In this demo, the same test data has been used by previous modules.
% While the unit under test was in Simulink this was easy to achieve.  The 
% test data can be reused outside of the Simulink environment. To 
% accomplish this task:
%
% * Save the Simulink data into a file.
% * Format the data in a way that the system code can access.
% * Read the data file as part of the system code procedures.
%
% Likewise, the test environment can be reused provided that the data from
% the external environment is saved in a format that MATLAB(R) can read.  In 
% this example, the file |hardwareInputs.c| contains the output data from
% the Signal Builder block in the test harness model.
%
% <html><img vspace="5" hspace="5" src="Test_Impor_Output_Data.jpg"></html>
%
%% Testing via Software-in-the-Loop (Model Block SIL)
% *Creating the Model Block and Configuring it for SIL*
%
% Simulink can generate code from a Model block, wrap it into an
% S-Function, and bring the resultant S-Function back into the model for
% Software-in-the-loop testing.
% 
% <matlab:rtwdemo_PCGEvalHarnessHTGTSIL *Task:* Open the test harness model.>
% 
% The test harness uses a Model block to access the model we want
% run software-in-the-loop test on.
% 
% <html>
% <ol>
%   <li> Right-click on the Model block and select <b>ModelReference
%   Parameters</b>.
%   <li> In the <b>Model name</b> field, enter the name of the model to be
%   tested like in the dialog view below.
%   <li> In the <b>Simulation mode</b> field, select
%   <b>Software-in-the-loop (SIL)</b> like in the following dialog view:
% </ol> 
% </html>
%
% <html><img vspace="5" hspace="5" src="Model_Block_SIL.jpg"></html>
%
% After you create the Model block and configure it for SIL operation, the
% block will have a *(SIL)* tag attached to it:
%
% <html><img vspace="5" hspace="5" src="Model_Block_SIL2.jpg"></html>
%
% *Configuring the Model Block model for SIL*
% 
% Next, you need to configure several settings in the Model block model.
% 
% <matlab:RTWDemos.pcgd_open_pcg_model(6,0); *Task:* Open the Model block model.> 
%
% <html>
% <ol>
%   <li> Open the Model Explorer and navigate to the Model block model.
%   <li> Click <b>Configuration</b> in the <b>Model Hierarchy</b> pane.
%   <li> Click <b>Hardware Implementation</b> in the <b>Contents</b> pane.
%   <li> Select <b>Generic</b> in the Device vendor field and <b>32-bit x86
%   compatible</b> in the Device type field.
%   <img vspace="5" hspace="5" src="Model_Block_SIL_hardware.jpg">
% </ol> 
% </html>
% 
% We are now ready to start the simulation.
% 
% *Running the Model Block SIL*
% 
% The test harness model is reused with a modification; the Model 
% block has been configured for SIL as you did in the previous steps.
%
% <matlab:rtwdemo_PCGEvalHarnessHTGTSIL *Task:* Open the test harness.>
%
% <matlab:sim('rtwdemo_PCGEvalHarnessHTGTSIL') *Task:* Run the test harness.>
%
% Again, the results from running the generated code are the same as
% the simulation results.
% 
% <html><img vspace="5" hspace="5" src="FirstPassTest.jpg"></html>
%
%% Configuring the System for Testing via Test Vector Import/Export
% This module extends the integration example in *Integrating the Generated Code into the External Environment*.  In this case |example_main.c| has simulated hardware I/O. 
%
% The augmented |example_main.c| file now has the following order of execution:
% 
% <html>
%   <ol>
%     <li> Initialize data (one time)<br>
%     <tt>while < endTime</tt>
%     <li> Read simulated hardware inputs
%     <li> <tt>PI_cnrl_1</tt>
%     <li> <tt>PI_ctrl_2</tt>
%     <li> <tt>Pos_Command_Arbitration</tt>
%     <li> Write simulated hardware outputs
%     <tt>end while</tt>
%   </ol>
% </html>
% 
% <matlab:edit(fullfile(matlabroot,'toolbox','rtw','rtwdemos','EmbeddedCoderOverview','stage_6_files','example_main.c')) *Task:* View |example_main.c|.>
%
% The input test data is supplied by two functions, |plant| and |hardwareInputs|.
%
% <html>
%     <table border = "1">
%         <tr valign = "top">
%             <td align = "center"><b>File Name</b></td>
%             <td align = "center"><b>Function Signature</b></td>
%             <td align = "center"><b>Comments</b></td>
%         </tr>
%             <tr valign = "top">
%             <td align="left"><tt>Plant.c</tt></td>
%             <td align="left"><tt>void Plant(void)</tt></td>
%             <td align="left">
%             Code generated from the plant section of the test harness. Simulates
%             the throttle body response to throttle commands.</td>
%         </tr>
%         <tr valign = "top">
%             <td align="left"><tt>HardwareInputs.c</tt></td>
%             <td align="left"><tt>void hardwareInputs(void)</tt></td>
%             <td align="left">
%             Provides the <tt>pos_req</tt> signal and adds noise from the
%             <tt>Input_Signal_Scaling</tt> subsystems into the plant feedback signal.</td>
%         </tr>
%     </table>
% </html>
%
% Data logging is provided by the hand-coded function |WriteDataForEval.c|.  
% The function is executed once the test is complete.  The test data is 
% written to the file |PCG_Eval_ExternSimData.m|.  You can load the MATLAB 
% program into the MATLAB environment and compare it to the simulated data.
%
% To enable these additional files add them to the *Real-Time
% Workshop > Custom Code > Include list of additional: > Source files*
% dialog.
%
% <html><img vspace="5" hspace="5" src="customCode.jpg"></html>
%% Testing via Test Vector Import/Export (Eclipse Environment)
% Before building an executable in the Eclipse environment, regenerate the
% code without the S-function interface.  
%
% <matlab:RTWDemos.pcgd_buildDemo(6,0) *Task:* Build C code for integration.>
%
% Instructions on how to install and use Eclipse and GCC appear in 
% *Installing and Using Cygwin and Eclipse*.
%
% To install the files for this module automatically, do the following:
%
% <matlab:RTWDemos.pcgd_autoSetup(6) *Task:* Automatically set up the build directory.>
% 
% To manually install the files, do the following:
% 
% <html>
%        <ol>
%           <li>Create a build directory (<tt>Eclipse_Build_P6</tt>).
%           <li>Unzip the file <tt>rtwdemo_PCG_Eval_P6.zip</tt> into your build directory.
%           <li>Delete these files, which are replaced by <tt>example_main.c.</tt>
%              <ul>
%                 <li><tt>rtwdemo_PCG_Eval_P6.c</tt>
%                 <li><tt>ert_main.c</tt>
%                 <li><tt>rt_logging.c</tt>
%             </ul>
%        </ol>
% </html> 
%
% Running the control code in Eclipse generates the file
% |eclipseData.m|.  This file was generated by the file |writeDataForEval.c|.
% You can compare the data from the Eclipse run and the standard test harness 
% by loading the data and then running the plot routine.
%
%   Copyright 2007-2010 The MathWorks, Inc.

displayEndOfDemoMessage(mfilename)
