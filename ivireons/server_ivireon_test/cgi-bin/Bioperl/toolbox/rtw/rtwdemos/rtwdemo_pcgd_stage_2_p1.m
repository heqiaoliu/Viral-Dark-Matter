%% Configuring the Data Interface
% *Overview:* Covers the specification of signals and parameters
% in the generated code.
%
% *Time:* 45 minutes
%
% *Goals*
%
% Learn how to control the following attributes of signals and parameters 
% in the generated code:
%
% * Name
% * Data type
% * Data storage class
%
% <matlab:RTWDemos.pcgd_open_pcg_model(2,0); *Task:* Open the model.> 
%% Background: Declaration of Data
% Most programming languages require that you _declare_ data and functions
% before using them. The declaration specifies: 
% 
% <html>
%     <table border = "1">
%         <tr valign = "top">
%             <td align = "left">Scope</td>
%             <td align = "left">The region of the program that has access to the data</td>
%         </tr>    
%         <tr valign = "top">
%             <td align = "left">Duration</td>
%             <td align = "left">The period during which the data is resident in memory</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left">Data type</td>
%             <td align = "left">The amount of memory allocated for the data</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left">Initialization</td>
%             <td align = "left">A value, a pointer to memory, or NULL</td>
%         </tr>
%     </table>
% </html>
%
% The combination of scope and duration is the _storage class_.  If you do not
% provide an initial value, most compilers assign a zero value or a null pointer.
%
% <html>
%     <table border = "1">
%         <tr valign = "top">
%             <td align = "center"><b>Name</b></td>
%             <td align = "center"><b>Description</b></td>
%         </tr>    
%         <tr valign = "top">
%             <td align = "left"><tt>double</tt></td>
%             <td align = "left">Double-precision floating point</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left"><tt>single</tt></td>
%             <td align = "left">Single-precision floating point</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left"><tt>int8</tt></td>
%             <td align = "left">Signed 8-bit integer</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left"><tt>uint8</tt></td>
%             <td align = "left">Unsigned 8-bit integer</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left"><tt>int16</tt></td>
%             <td align = "left">Signed 16 bit integer</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left"><tt>uint16</tt></td>
%             <td align = "left">Unsigned 16 bit integer</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left"><tt>int32</tt></td>
%             <td align = "left">Signed 32 bit integer</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left"><tt>uint32</tt></td>
%             <td align = "left">Unsigned 32 bit integer</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left">Fixed Point</td>
%             <td align = "left">8-, 16-, 32-bit word lengths</td>
%         </tr>
%         <CAPTION><b>Supported Data Types</b></CAPTION>
%     </table>
%     <p></p>
%     <table border = "1">
%         <tr valign = "top">
%             <td align = "center"><b>Name</b></td>
%             <td align = "center"><b>Description</b></td>
%             <td align = "center"><b>Parameters<br>Supported</b></td>
%             <td align = "center"><b>Signals<br>Supported</b></td>
%             <td align = "center"><b>Data Types</b></td>
%         </tr>    
%         <tr valign = "top">
%             <td align = "left">Const</td>
%             <td align = "left">Use <tt>const</tt> type qualifier in declaration</td>
%             <td align = "center">Y</td>
%             <td align = "center">N</td>
%             <td align = "center">All</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left">ConstVolatile</td>
%             <td align = "left">Use <tt>const volatile</tt> type qualifier in declaration</td>
%             <td align = "center">Y</td>
%             <td align = "center">N</td>
%             <td align = "center">All</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left">Volatile</td>
%             <td align = "left">Use <tt>volatile</tt> type qualifier in declaration</td>
%             <td align = "center">Y</td>
%             <td align = "center">Y</td>
%             <td align = "center">All</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left">ExportToFile</td>
%             <td align = "left">Generate and include files, with user-specified name, containing global variable declarations and definitions</td>
%             <td align = "center">Y</td>
%             <td align = "center">Y</td>
%             <td align = "center">All</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left">ImportFromFile</td>
%             <td align = "left">Include predefined header files containing global variable declarations</td>
%             <td align = "center">Y</td>
%             <td align = "center">Y</td>
%             <td align = "center">All</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left">Exported Global</td>
%             <td align = "left">Declare and define variables of global scope</td>
%             <td align = "center">Y</td>
%             <td align = "center">Y</td>
%             <td align = "center">All</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left">Imported Extern</td>
%             <td align = "left">Import a variable that is defined outside of the scope of the model</td>
%             <td align = "center">Y</td>
%             <td align = "center">Y</td>
%             <td align = "center">All</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left">BitField</td>
%             <td align = "left">Embed boolean data in a named bit field</td>
%             <td align = "center">Y</td>
%             <td align = "center">Y</td>
%             <td align = "center">Boolean</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left">Define</td>
%             <td align = "left">Represent parameters with a <tt>#define</tt> macro</td>
%             <td align = "center">Y</td>
%             <td align = "center">N</td>
%             <td align = "center">All</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left">Struct</td>
%             <td align = "left">Embed data in a named struct to encapsulate sets of data</td>
%             <td align = "center">Y</td>
%             <td align = "center">Y</td>
%             <td align = "center">All</td>
%         </tr>
%         <CAPTION><b>Supported Storage Classes</b></CAPTION>
%     </table>
% </html>
%
%% Controlling Data in Simulink and Stateflow
% Two methods are available for declaring data in Simulink(R) and Stateflow(R): _data
% objects_ and _direct specification_.  This demo uses the data object
% method.  Both methods allow full control over the data type and storage
% class.  You can mix the two methods in a single model.
%
% You can use data objects in a variety of ways in the MATLAB(R) and Simulink
% environment.  The demo focuses on three types of data objects.
%
% * Signal
% * Parameter
% * Bus
%
% The code generator uses data objects from the MATLAB base workspace.  You
% can create and inspect them by entering commands in the MATLAB Command Window
% or by using the Model Explorer. 
%
% The following example shows the definition of Simulink signal object
% |pos_cmd_one|:
%
% <html><img vspace="5" hspace="5" src="data_objects_MATLAB.jpg"></html>
% 
% You can open the Model Explorer and display details about a specific data
% object in the demo model.
%
% Click each object name in the following table:
%
% <html>
%     <table border = "1">
%         <tr valign = "bottom">
%             <td align = "center"> </td>
%             <td align = "center"><a href="matlab:RTWDemos.pcgd_open_dialog('pos_cmd_one','',2)"><tt>pos_cmd_one</tt></a></td>
%             <td align = "center"><a href="matlab:RTWDemos.pcgd_open_dialog('pos_rqst','',2)"><tt>pos_rqst</tt></a></td>
%             <td align = "center"><a href="matlab:RTWDemos.pcgd_open_dialog('P_InErrMap','',2)"><tt>P_InErrMap</tt></a></td>
%             <td align = "center"><a href="matlab:RTWDemos.pcgd_open_dialog('ThrotComm','',2)"><tt>ThrotComm</tt><sup>(1)</sup></a></td>
%             <td align = "center"><a href="matlab:RTWDemos.pcgd_open_dialog('ThrottleCommands','',2)"><tt>ThrottleCommands</tt><sup>(1)</sup></a></td>
%         </tr>    
%         <tr valign = "top">
%             <td><b>Description</b></td>
%             <td align = "left">Top-level output</td>
%             <td align = "left">Top-level input</td>
%             <td align = "left">Calibration parameter</td>
%             <td align = "left">Top-level output structure</td>
%             <td align = "left">Bus definition</td>
%         </tr>
%         <tr valign = "top">
%             <td><b>Data Type</b></td>
%             <td align = "left">Double</td>
%             <td align = "left">Double</td>
%             <td align = "left">Auto</td>
%             <td align = "left">Auto</td>
%             <td align = "left">Struct</td>
%         </tr>
%         <tr valign = "top">
%             <td><b>Storage Class</b></td>
%             <td align = "left">Exported Global</td>
%             <td align = "left">Imported Extern Pointer</td>
%             <td align = "left">Constant</td>
%             <td align = "left">Exported Global</td>
%             <td align = "v">None</td>
%         </tr>
%     </table>
% </html>
%
% (1) |ThrottleCommands| defines a Simulink Bus object, 
% |ThrotComm| is the instantiation of the bus.  If the bus is a nonvirtual 
% bus, the signal will generate a structure in the C code. 
% 
% As in C, you can use a bus definition (|ThrottleCommands|) to instantiate 
% multiple instances of the structure.  In a model diagram, a bus object 
% appears as a wide line with central dashes, as shown below. 
%
% <html><img vspace="5" hspace="5" src="BusObjectLine.jpg"></html>
%
% The following figure shows the Model Explorer display if you click the
% signal name |pos_rqst|:
%
% <html><img vspace="5" hspace="5" src="show_storage_class_pos_rqst.jpg"></html>
%
% A data object has a mixture of _active_ and _descriptive_ fields.  Active
% fields affect simulation or code generation.  Descriptive fields do not
% affect simulation or code generation, but are used with data
% dictionaries and model-checking tools.  
%
% *Active Fields*
%
% * Data type 
% * Storage class 
% * Value (parameters)
% * Initial value (signals)
% * Alias (define a different name in the generated code)
% * Dimension (inherited for parameters)
% * Complexity (inherited for parameters)
%
% *Descriptive Fields*
%
% * Minimum
% * Maximum
% * Units
% * Description
%
%% Adding New Data Objects
% You can create data objects for named signals, states, and parameters.
% To associate a data object with a construct, the construct must have a
% name. 
%
% The Data Object Wizard is a tool that finds constructs for which you
% can create data objects, then creates the objects for you.  The demo 
% model includes two signals that are not associated with data objects:
% |fbk_1| and |pos_cmd_two|.
%
% To find the signals and create data objects for them:
%
% 1. <matlab:dataobjectwizard('rtwdemo_PCG_Eval_P2') *Task:* Open the Data Object Wizard.> 
%
% <html><img vspace="5" hspace="5" src="data_object_wiz.jpg"></html> 
%
% 2. Click *Find* to find candidate constructs. 
%
% 3. Click *Check All* to select all candidates.
%
% 4. Click *Apply Packages* to apply the Simulink package for the data
% objects.
%
% 5. Click *Create* to create the data objects.
%
%% Configuring Data Objects
% The next step is to set the data type and storage class.
% 
% 1.Click the names in the following table to edit the Data Objects:
%
% <html>
%     <table border = "1">
%         <tr valign = "top">
%             <td align = "center"><b>Data Object</b></td>
%             <td align = "center"><b>Data Type</b></td>
%             <td align = "center"><b>Storage Class</b></td>
%         </tr>    
%         <tr valign = "top">
%             <td><a href="matlab:RTWDemos.pcgd_open_dialog('fbk_1','',2)"><tt>Edit fbk_1</tt></a></td>
%             <td align = "left">Double</td>
%             <td align = "left">Imported Extern</td>
%         </tr>
%         <tr valign = "top">
%             <td><a href="matlab:RTWDemos.pcgd_open_dialog('pos_cmd_two','',2)"><tt>Edit pos_cmd_two</tt></a></td>
%             <td align = "left">Double</td>
%             <td align = "left">Exported Global</td>
%         </tr>
%     </table>
% </html>
%
% Clicking a name opens the Model Explorer to show the base workspace. 
%
% 2. For each object listed in the preceding table, click the signal name in
% the *Contents* pane.
%
% 3. Change the field settings in the *Data* pane to match those in the table. 
%
% *Note:* If the Model Explorer does not open for either of the two signals,
% repeat the steps in *Adding New Data Objects*.
%
%% Controlling File Placement of Parameter Data
% Real-Time Workshop(R) Embedded Coder(TM) allows you to control the files in which the
% parameters and constants are defined.  For the demo model, all parameters
% were written to the file |eval_data.c|.  
%
% To change the placement of parameter and constant definitions, set the appropriate
% data placement options for the model configuration. Within the 
% Model Explorer, you set the options at *Configuration > Real-Time
% Workshop > Data Placement*.  For the demo, the model has already been
% configured.
%
% 1. <matlab:RTWDemos.pcgd_open_dialog('RTW','DAT',2) *Task:* Open the *Data Placement* pane of the Configuration Parameters dialog.>
% 
% 2. Enter data in the *Data Placement* pane as shown in the following figure:
%
% <html><img vspace="5" hspace="5" src="DataPlacmentDialog.jpg"></html>
%
% The generated code that results for |eval_data.c| is shown below.
%
% <html><img vspace="5" hspace="5" src="eval_data_file.jpg"></html>
%
%% Enabling Data Objects in Generated Code
% The next step is to ensure that the data objects you have created appear 
% in the generated code. To enable parameters in generated code, set the *Inline parameters* 
% option for the model configuration.  In the Model Explorer, this option is: 
%
% <html>
% <b>Configuration &#62 Optimizations &#62 Simulation and code generation
% &#62 Inline parameters</b>
% </html>
%
% <html><img vspace="5" hspace="5" src="Sim_And_Code_Gen_Optimizations.jpg"></html>
%
% <matlab:RTWDemos.pcgd_open_dialog('OPT','',2) *Task:* Set the *Inline parameters* option.>
%
% To enable a signal in generated code: 
% 
% 1. Right-click the signal line.
%
% 2. From the context menu, select *Signal Properties*.  A Signal Properties dialog
% box appears. 
%
% 3. Make sure the option *Signal name must resolve to a Simulink signal
% object* is selected.
%
% <html><img vspace="5" hspace="5" src="signal_object.jpg"></html>
%
% You can enable signals associated with data objects individually, or you 
% can enable all such signals in a model at once by entering  
% |disableimplicitsignalresolution| in the MATLAB Command Window.
%
% <matlab:disableimplicitsignalresolution(pcgDemoData.Models{2}) *Task:* Enable all signals with associated data objects.>
%
%% Effects of Simulation on Data Typing
% For the demo model, all data types are set to |double|. Since Simulink uses 
% the |double| data type for simulation, no changes are expected in the
% model behavior when you run the generated code. To
% verify this, run the test harness model.  The test harness model is
% automatically updated to include the rtwdemo_PCG_Eval_P2 model. That is the only 
% change made to the test harness.
%
% <matlab:RTWDemos.pcgd_open_pcg_model(2,1); *Task:* Open the test harness.>  
%
% <matlab:RTWDemos.pcgd_runTestHarn(1,2) *Task:* Run the test harness.>
%
% The resulting plot shows that the difference between the golden and simulated 
% versions of the model remains zero.
%
% <html><img vspace="5" hspace="5" src="FirstPassTest.jpg"></html>
%
%% Viewing Data Objects in Generated Code
% Now view the file |rtwdemo_PCG_Eval_P2.c| to see how the use of data objects changed 
% the generated code.
%
% <matlab:RTWDemos.pcgd_buildDemo(2,0) *Task:* Generate code for the model.>
%
% Click the file names in the following table to view generated codes:
% 
% <html>
%     <table border = "1">
%         <tr valign = "top">
%             <td align = "center"><b>File</td>
%             <td align = "center"><b>Definition</b></td>
%             <td align = "center"><b>Notes</b></td>
%         </tr>    
%         <tr valign = "top">
%             <td><a href="matlab:RTWDemos.pcgd_showSection(2,'func');"> <tt>rtwdemo_PCG_Eval_P2.c</tt></a></td>
%             <td align = "left">Provides step and initialization function</td>
%             <td align = "left">Uses the defined data objects</td>
%         </tr>
%         <tr valign = "top">
%             <td><a href="matlab:RTWDemos.pcgd_showSection(2,'eval_data_c');"><tt>eval_data.c</tt></a></td>
%             <td align = "left">Assigns values to the defined parameters</td>
%             <td align = "left">Has the file name specifically defined</td>
%         </tr>
%         <tr valign = "top">
%             <td><a href="matlab:RTWDemos.pcgd_showSection(2,'eval_data_h');"><tt>eval_data.h</tt></a></td>
%             <td align = "left">Provides extern definitions to the defined parameters</td>
%             <td align = "left">Has the file name specifically defined</td>
%         </tr>
%         <tr valign = "top">
%             <td><a href="matlab:RTWDemos.pcgd_showSection(2,'ert_main');"><tt>ert_main.c</tt></a></td>
%             <td align = "left">Provides scheduling functions</td>
%             <td align = "left">No change</td>
%         </tr>
%         <tr valign = "top">
%             <td><a href="matlab:RTWDemos.pcgd_showSection(2,'data_def');"><tt>rtwdemo_PCG_Eval_P2.h</tt></a></td>
%             <td align = "left">Defines data structures</td>
%             <td align = "left">Using data objects shifted some parameters out of this file into <tt>user_data.h</tt></td>
%         </tr>
%         <tr valign = "top">
%             <td><a href="matlab:RTWDemos.pcgd_showSection(2,'private');"><tt>PCG_Eval_p2_private.h</tt></a></td>
%             <td align = "left">Defines private (local) data for the generated functions</td>
%             <td align = "left">Objects now defined in <tt>eval_data</tt> were removed</td>
%         </tr>
%         <tr valign = "top">
%             <td><a href="matlab:RTWDemos.pcgd_showSection(2,'func_types');"><tt>rtwdemo_PCG_Eval_P2_types.h</tt></a></td>
%             <td align = "left">Defines the model data structure</td>
%             <td align = "left">No change</td>
%         </tr>
%         <tr valign = "top">
%             <td><a href="matlab:RTWDemos.pcgd_showSection(2,'rtwtypes');"><tt>rtwtypes.h</tt></a></td>
%             <td align = "left">Provides mapping to data types defined by Real-Time Workshop</td>
%             <td align = "left">Used for integration with external systems</td>
%         </tr>
%         <CAPTION><b>Files generated for rtwdemo_PCG_Eval_P2</b></CAPTION>
%     </table>
% </html>
%
% The following figure shows the code for function |rtwdemo_PCG_Eval_P2_step| as it appears
% in |rtwdemo_PCG_Eval_P2.c| before the use of data objects:
% 
% <html><img vspace="5" hspace="5" src="wo_data_objects.jpg"></html>
%
% The figure below shows the code as it appears in |rtwdemo_PCG_Eval_P2.c| with
% data objects.
%
% <html><img vspace="5" hspace="5" src="WithDataObjects.jpg"></html>
%
% This figure shows that most of the Real-Time Workshop data structures have been 
% replaced with user-defined data objects.  The local variable |rtb_Sum2| and the 
% state variable |rtwdemo_PCG_Eval_P2_DWork.Discrete_Time_Integrator1_DSAT|
% still use the Real-Time Workshop data structures.  
%
%% Data Management
% Data objects exist in the MATLAB base workspace. They are 
% saved in a separate file from the model.  
% To save the data manually, enter |save| in the MATLAB Command Window.
%
% The separation of data from the model provides many benefits. 
%
% <html>
%     <ul>
%         <li>One model, multiple data sets
%         <ul>
%             <li>Use of different data types to change the targeted  
%                   hardware (for example, for floating-point and fixed-point targets)
%             <li>Use of different parameter values to change 
%                   the behavior of the control algorithm (for example, for reusable components
%                   with different calibration values)
%         </ul>
%         <li>Multiple models, one data set
%         <ul>
%             <li>Sharing of data between Simulink models in a system
%             <li>Sharing of data between projects (for example, 
%                   transmission, engine, and wheel controllers might all use the same CAN
%                   message data set)
%         </ul>
%     </ul>
% </html>
%
%% Further Study Topics
%
% * <matlab:helpview([docroot,'/toolbox/simulink/helptargets.map'],'sl_data'); Data types, including fixed-point data, data objects, and data classes>
% * <matlab:helpview([docroot,'/toolbox/ecoder/helptargets.map'],'custom_storage_classes'); Custom storage classes>
% * <matlab:helpview([docroot,'/toolbox/ecoder/helptargets.map'],'data_placement'); Managing file placement of data definitions and declarations>
%
%   Copyright 2007-2008 The MathWorks, Inc.

displayEndOfDemoMessage(mfilename)
