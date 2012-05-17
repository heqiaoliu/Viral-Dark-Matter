%% Evaluating the Generated Code
% *Overview:* Reviews the build characteristics of the 
% generated code. Provides RAM/ROM data for several model
% configurations.
%
% *Time*: 15 minutes
%
% *Goals*
% 
% Understand...
%
% * How different configurations affect the RAM/ROM metric
%
%% Background on Code Evaluation
% Generated code is evaluated based on two primary metrics: _execution
% speed_ and _memory usage_.  There is often, though not always, a tradeoff 
% between execution speed and memory where faster execution requires more memory.
% Memory usage can be further classified into ROM (Read-only memory) and 
% RAM (Random access memory).  
%
% There are tradeoffs between using RAM and ROM. 
%
% * Accessing data from RAM is faster than accessing ROM.
% * Executables and data must be stored on ROM, because RAM does not maintain data
% between power cycles.
%
% This module shows memory requirements divided into
% function and data components. Execution speed was not evaluated.
%
%% Compiler Information
% The Freescale CodeWarrior was used in this evaluation. Details on
% the compiler appear below.
% 
% <html>
%     <table border = "1">
%         <tr valign = "top">
%             <td align = "center"><b>Compiler</b></td>
%             <td align = "center"><b>Version</b></td>
%             <td align = "center"><b>Target Processor</b></td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left">Freescale CodeWarrior </td>
%             <td align = "left">v5.5.1.1430</td>
%             <td align = "left">Power PC 565</td>
%         </tr>
%     </table>
% </html>
% 
%% Viewing the Code Metrics
% As described in *Integrating the Generated Code into the External Environment* and
% *Testing the Generated Code*, the generated code may require the use of
% utility functions.  The utility functions have a fixed overhead;
% their memory requirements is a one-time cost.  Because of this, the data in this module shows memory usage for:
% 
% * Algorithms: The C code generated from the Simulink(R) diagrams and the data
% definition functions
% * Utilities: Functions that are part of the Real-Time Workshop(R) library
% source
% * Full: The sum of both the Algorithm and Utilities
%
%% Build Options Configuration
% The same configuration options are used in all three evaluations.  
% Freescale CodeWarrior was configured to minimize memory usage and apply all allowed
% optimizations.
%
% <html><img vspace="5" hspace="5" src="CodeWarrior_Small_Full_Opt.jpg"></html>
%
%% Configuration 1: Reusable Functions Data Type Double
% * *Source files:* |PCG_Eval_File_1.zip|
% * *Data Type:* All doubles
% * *Included Data:* All data required for the build is included in the
% project (including data defined as |extern|: |pos_rqst|, |fbk_1|, and |fbk_2|)
% * *Main Function:* A modified version of |example_main| from *Integrating
% the Generated Code into the External Environment*
% * *Function Call Method:* Reusable functions for the PI controllers
% 
% <html><img vspace="5" hspace="5" src="CodeWarrior_P4_Data_Details.jpg"></html>
%
% <html>
%     <table border = "1">
%         <tr valign = "top">
%             <td align = "center"><b> </b></td>
%             <td align = "center"><b>Function</b></td>
%             <td align = "center"><b>Data</b></td>
%         </tr>    
%         <tr valign = "top">
%             <td align = "left"><b>Full</b></td>
%             <td align = "center">1764 bytes</td>
%             <td align = "center"> 589 bytes</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left"><b>Algorithms</b></td>
%             <td align = "center">1172 bytes</td>
%             <td align = "center"> 549 bytes</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left"><b>Utilities</b></td>
%             <td align = "center">592 bytes</td>
%             <td align = "center">40 bytes</td>
%         </tr>
%         <CAPTION><b>Memory Usage</b></CAPTION>
%     </table>
% </html>
%
%% Configuration 2: Reusable Functions Data Type Single
% In this configuration, the data types for the model where changed from the
% default of double to single.  
%
% *Model Configuration*
%
% * *Source files:* |PCG_Eval_File_2.zip|
% * *Data Type:* All singles
% * *Included Data:* All data required for the build is included in the
% project (including data defined as |extern|: |pos_rqst|, |fbk_1|, and |fbk_2|)
% * *Main Function:* A modified version of example_main from *Integrating
% the Generated Code into the External Environment*
% * *Function Call Method:* Reusable functions for the PI controllers
%
% <html>
%     <table border = "1">
%         <tr valign = "top">
%             <td align = "center"><b> </b></td>
%             <td align = "center"><b>Function</b></td>
%             <td align = "center"><b>Data</b></td>
%         </tr>    
%         <tr valign = "top">
%             <td align = "left"><b>Full</b></td>
%             <td align = "center">1392 bytes</td>
%             <td align = "center"> 348 bytes</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left"><b>Algorithms</b></td>
%             <td align = "center">800 bytes</td>
%             <td align = "center">308 bytes</td>
%         </tr>
%         <tr valign = "top">                      
%             <td align = "left"><b>Utilities</b></td>
%             <td align = "center">592 bytes</td>
%             <td align = "center"> 40 bytes</td>
%         </tr>
%         <CAPTION><b>Memory Usage</b></CAPTION>
%     </table>
% </html>
%
% Comparing the memory used by the algorithms in the first configuration to
% the current configuration we see a large drop in the data memory,
% from 549 bytes to 308 bytes or 56 percent.  The function size also 
% decreased from 1172 to 800 bytes, or 68 percent.  Running the simulation
% with data type set to single does not reduce the accuracy of the control
% algorithm, therefore this would be an acceptable design decision.
%
%% Configuration 3: Nonreusable Functions Data Type Single
% * *Source files:* PCG_Eval_File_3.zip
% * *Data Type:* All singles
% * *Included Data:* All data required for the build is included in the
% project (including data defined as |extern|: |pos_rqst|, |fbk_1|, and |fbk_2|)
% * *Main Function:* A modified version of |example_main| from *Integrating
% the Generated Code into the External Environment*
% * *Function Call Method:* The function interface is |void void|.  Data
% is passed by global parameters
%
% <html>
%     <table border = "1">
%         <tr valign = "top">
%             <td align = "center"><b> </b></td>
%             <td align = "center"><b>Function</b></td>
%             <td align = "center"><b>Data</b></td>
%         </tr>    
%         <tr valign = "top">
%             <td align = "left"><b>Full</b></td>
%             <td align = "center">1540 bytes</td>
%             <td align = "center"> 388 bytes</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left"><b>Algorithms</b></td>
%             <td align = "center">948 bytes</td>
%             <td align = "center">348 bytes</td>
%         </tr>
%         <tr valign = "top">
%             <td align = "left"><b>Utilities</b></td>
%             <td align = "center">592 bytes</td>
%             <td align = "center"> 40 bytes</td>
%         </tr>
%         <CAPTION><b>Memory Usage</b></CAPTION>
%     </table>
% </html>
%
% The memory requirements for the third configuration are higher than the
% second configuration.  Had the data type been double they would have been
% higher than the first configuration as well.   

%   Copyright 2007-2009 The MathWorks, Inc.

displayEndOfDemoMessage(mfilename)
