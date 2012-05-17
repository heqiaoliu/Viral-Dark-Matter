%% Integrating the Generated Code into the External Environment
% *Overview:* Provides an overview of the external build
% process, including what files are required and the interfaces you use to call the
% generated code.
%
% *Time*: 45 minutes
%
% *Goals*
% 
% Understand...
%
% * How to collect files required for building outside of Simulink(R)
% * How to interface with external variables and functions
%
% <matlab:RTWDemos.pcgd_open_pcg_model(5,0); *Task:* Open the model.> 
%% Building and Collecting the Required Data and Files
% <html>
%   <a name="MyLink2"></a> 
%   <! Note: by adding my own "name" I control the link no matter what publish does>
% </html>
%
% <html>
%   The code that Real-Time Workshop(R) generates is dependent on 
%   support files provided by The MathWorks.  If you need to relocate 
%   generated code to another development environment, such as a dedicated build system, 
%   you must also relocate the required support files. You can automatically 
%   collect all generated and necessary support files and package them in a
%   zip file by using the Real-Time Workshop </tt>packNGo</tt> utility. This
%   utility uses tools for customizing the build process after code
%   generation, including a <tt>buildinfo_data</tt> structure, and a <tt>packNGo</tt> function 
%   to find and package all files needed to build an executable image, including 
%   external files you define in the <b>Real-Time Workshop > Custom Code</b> pane
%   of the Configuration Parameters dialog. The files are packaged in a standard 
%   zip file. The <tt>buildinfo</tt> MAT-file is saved automatically
%   in the directory <tt><i>model</i>_ert_rtw</tt>.
% </html>
%
% The demo model is configured to run |packNGo| automatically after code
% generation. 
%
% <matlab:RTWDemos.pcgd_buildDemo(5,0) *Task:* Generate code for the full model.> 
%
% To generate the zip file manually, do the following in the MATLAB(R) Command Window:
%
% <html>
%   <ol>
%      <li>Load the file <tt>buildInfo.mat</tt> (located in the
%      subdirectory <tt>rtwdemo_PCG_Eval_P5_ert_rtw</tt>).
%      <li>Enter the command <tt>packNGo(buildInfo)</tt>.
%   </ol>
% </html>
% 
% The number of files included in the zip file depends on the version of
% Real-Time Workshop Embedded Coder(TM) and the configuration of the model you
% use. Not all of the files in the zip file are required by the compiler.
% The compiled executable size (RAM/ROM) is
% dependent on the link process.  The linker should be configured to include  
% only required object files.
%
%% Background: Integrating the Generated Code into an Existing System
% <html>
%   <a name="MyLink1"></a> 
%   <! Note: by adding my own "name" I control the link no matter what
%   publish does>
% </html>
%
% This module covers tasks required to integrate the
% generated code into an existing code base.  For this evaluation, the  
% Eclipse IDE and Cygwin/gcc compiler are used.  The required integration 
% tasks are common to all integration environments.  
%
%% Background: Overview of the Integration Environment
% A full embedded controls system is comprised of multiple components, both
% hardware and software. Control algorithms are just one type of
% component.  The other standard types of components include:
%
% * An operating system (OS)
% * A scheduling layer
% * Physical hardware I/O 
% * Low-level hardware device drivers
%
% In general, Real-Time Workshop Embedded Coder does not generate code for any
% of these components.  Instead, it generates interfaces that connect
% with the components. The MathWorks provides hardware interface block
% libraries for many common embedded controllers.  For examples, see the
% block libraries for Target for Freescale(TM) MPC5xx,
% Target for Infineon C166(R), and Target for TI C2000(TM).
%
% For this evaluation, files are provided to demonstrate how you can build a 
% full system.  The main file is |example_main.c|. It is a simple main function 
% that performs the basic actions required to exercise the code.  It is _not_ 
% intended as an example of an actual application main. 
%
% <matlab:edit(fullfile(matlabroot,'toolbox','rtw','rtwdemos','EmbeddedCoderOverview','stage_5_files','example_main.c')) *Task:* View |example_main.c|.>
%
% <html><img vspace="5" hspace="5" src="example_main_s5.jpg"></html>
%
% Functions of |example_main.c| include the following:
%
% * Defines function interfaces (function prototypes)
% * Includes required files for data definition
% * Defines |extern| data
% * Initializes data
% * Calls simulated hardware
% * Calls algorithmic functions
% 
% The order of execution of functions in |example_main.c| matches the order
% in which the subsystems are called in the test harness and in
% |rtwdemo_PCG_Eval_P5.h|.  If you change the order of execution in |example_main.c|, 
% results produced by the executable image will differ from simulation
% results.
%
%% Matching the System Interfaces
% Integration requires matching both the _Data_ and _Function_ interfaces
% of the generated code and the existing system code.  In this example, the
% |example_main.c| file defines the data through #includes and calls the
% functions from the generated code.
%
%% Matching Data Interfaces: Input Data Specification
% The system has three input signals: |pos_rqst|, |fbk_1|, and
% |fbk_2|.  The two feedback signals are imported externs and the position 
% signal is an imported extern pointer.  Due to how the signals are defined,
% Real-Time Workshop does not define (create) variables for them.  Instead, the
% signal variables are defined in a file that is external to the MATLAB environment.  
% 
% For the demo, the file |defineImportedData.c| was created.  This file is a
% simple C stub used to define the signal variables.  The generated code has
% access to the data from the |extern| definitions in the file 
% |rtwdemo_PCG_Eval_P5_Private.h|.  In a real system, the data would come from other 
% software components or from hardware devices.
%
% <matlab:edit(fullfile(matlabroot,'','toolbox','rtw','rtwdemos','EmbeddedCoderOverview','stage_5_files','defineImportedData.c')) *Task:* View |defineImportedData.c|.>
%
% <html><img vspace="5" hspace="5" src="defineImportedData.jpg"></html>
%
% <matlab:RTWDemos.pcgd_showSection(5,'private'); *Task:* View |rtwdemo_PCG_Eval_P5_Private.h|.>
%
% <html><img vspace="5" hspace="5" src="Private_Extern_Define.jpg"></html>
%
%% Matching Data Interfaces: Output Data Specification
% The system does not require you to do anything with the
% output data. However, you can access the data by referring to the
% file |rtwdemo_PCG_Eval_P5.h|.  
%
% The module *Testing the Generated Code* shows how the output data can be saved to a standard log file.
%
% <matlab:RTWDemos.pcgd_showSection(5,'data_def'); *Task:* View |rtwdemo_PCG_Eval_P5.h|.>
%
%% Matching Data Interfaces: Accessing Additional Data
% Real-Time Workshop Embedded Coder creates several data
% structures during the code generation process.  For this demo accessing
% these structures was not required.  Examples of common data elements that
% users wish to access include:
% 
% * Block state values (integrator, transfer functions)
% * Local parameters
% * Time
%
% The following table lists the common Real-Time Workshop data structures.
% Depending on the configuration of the model, some or all of 
% these structures will appear in the generated code.  In this example, the
% data is declared in the file |rtwdemo_PCG_Eval_P5.h|.
%
% <html>
%     <table border = "1">
%         <tr valign = "top">
%             <td align = "center"><b>Data Type</b></td>
%             <td align = "center"><b>Data Name</b></td>
%             <td align = "center"><b>Data Purpose</b></td>
%         </tr>    
%         <tr valign = "top">
%             <td>Constants</td>
%             <td><tt>model_cP</tt></td>
%             <td>Constant parameters</td>
%         </tr>
%         <tr valign = "top">
%             <td>Constants</td>
%             <td><tt>model_cB</tt></td>
%             <td>Constant block I/O</td>
%         </tr>
%         <tr valign = "top">
%             <td>Output</td>
%             <td><tt>model_U</tt></td>
%             <td>Root and atomic subsystem input</td>
%         </tr>
%         <tr valign = "top">
%             <td>Output</td>
%             <td><tt>model_Y</tt></td>
%             <td>Root and atomic subsystem output</td>
%         </tr>
%         <tr valign = "top">
%             <td>Internal data</td>
%             <td><tt>model_B</tt></td>
%             <td>Value of block output</td>
%         </tr>
%         <tr valign = "top">
%             <td>Internal data</td>
%             <td><tt>model_D</tt></td>
%             <td>State information vectors</td>
%         </tr>
%         <tr valign = "top">
%             <td>Internal data</td>
%             <td><tt>model_M</tt></td>
%             <td>Time and other<br>system level data</td>
%         </tr>
%         <tr valign = "top">
%             <td>Internal data</td>
%             <td><tt>model_Zero</tt></td>
%             <td>Zero-crossings</td>
%         </tr>
%         <tr valign = "top">
%             <td>Parameters</td>
%             <td><tt>model_P</tt></td>
%             <td>Parameters</td>
%         </tr>
%     </table>
% </html>
%% Matching Function Call Interfaces
% Functions generated by Real-Time Workshop have a |void Func(void)|
% interface, by default.  If the model or atomic subsystem is configured as
% reentrant code, Real-Time Workshop creates a more complex function prototype.
% As shown below, the |example_main| function is configured to call the
% functions with the correct input arguments.
%
% <html><img vspace="5" hspace="5" src="functionInterface.jpg"></html>
%
% Calls to the function |PI_Cntrl_Reusable| use a mixture of user-defined
% variables and Real-Time Workshop structures.  The structures are defined
% in |rtwdemo_PCG_Eval_P5.h|.  The preceding code fragment also shows how the 
% structures can be mapped onto user-defined variables.  
%
%% Building a Project in the Eclipse Environment
% This demo uses the Eclipse IDE and the Cygwin GCC debugger
% to build the embedded system.  The installation files for both programs are
% provided as part of this demo. The following table lists the software
% components and versions numbers:
%
% <html>
%     <table border = "1">
%         <tr valign = "top">
%             <td align = "center"><b>Software</b></td>
%             <td align = "center"><b>Version #</b></td>
%         </tr>    
%         <tr valign = "top">
%             <td>Eclipse SDK</td>
%             <td>3.2</td>
%         </tr>
%         <tr valign = "top">
%             <td>Eclipse CDT</td>
%             <td>3.3</td>
%         </tr>
%         <tr valign = "top">
%             <td>Cygwin/GCC</td>
%             <td>3.4.4-1</td>
%         </tr>
%         <tr valign = "top">
%             <td>Cygwin/GDB</td>
%             <td>20060706-2</td>
%         </tr>
%     </table>
% </html>
%
% Instructions on how to install and use Eclipse and GCC appear in 
% *Installing and Using Cygwin and Eclipse*.
%
% To install the files for this module automatically, do the following:
%
% <matlab:RTWDemos.pcgd_autoSetup(5) *Task:* Automatically set up the build directory.>
%
% To manually install the files, do the following:
% 
% <html>
%        <ol>
%           <li>Create a build directory (<tt>Eclipse_Build_P5</tt>).
%           <li>Unzip the file <tt>rtwdemo_PCG_Eval_P5.zip</tt> into your build directory.
%           <li>Delete these files, which are replaced by <tt>example_main.c.</tt>
%              <ul>
%                 <li><tt>rtwdemo_PCG_Eval_P5.c</tt>
%                 <li><tt>ert_main.c</tt>
%                 <li><tt>rt_logging.c</tt>
%             </ul>
%        </ol>
% </html> 
%
% <html>
%   <b>Note:</b> If code has not been generated for the model or the zip file
%   does not exist, complete the steps in the module 
%   <a href="#MyLink2">Required Data and Files</a> before continuing to
%   the next module.
% </html>
%
% You can use the Eclipse debugger to step through and evaluate the
% execution behavior of the generated C code. *Testing the Generated Code* includes an
% example on how to exercise the model with input data.
%
%% Further Study Topics
%
% * <matlab:helpview([docroot,'/toolbox/rtw/helptargets.map'],'pack_and_go_util'); Using the Pack-and-Go utility>
%   Copyright 2007-2008 The MathWorks, Inc.

displayEndOfDemoMessage(mfilename)
