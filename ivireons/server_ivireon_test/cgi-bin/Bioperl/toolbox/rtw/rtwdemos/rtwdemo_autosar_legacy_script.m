%% AUTOSAR Code Generation
% This demonstration shows you how to generate AUTOSAR-compliant code and export
% AUTOSAR software component description XML files from a Simulink(R) model.

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/10/08 17:53:56 $

%% Prepare the Model
% You can use the rtwdemo_autosar_counter demo model to see the steps needed
% to generate AUTOSAR-compliant code. 
%
% # Open the model rtwdemo_autosar_counter.
% # Click the *Tools* menu and select: *Real-Time Workshop* > *Options*
% # Change the system target file to the AUTOSAR target (|autosar.tlc|).
%
% An alternative method to change the system target file is to execute the
% following commands:
%

% Model defines
modelName = 'rtwdemo_autosar_counter';

% open the model
open_system( modelName );

% Programmatically set the system target file to autosar.tlc
set_param( modelName, 'SystemTargetFile', 'autosar.tlc' );

%% Change the Default AUTOSAR Port Settings
% By default the AUTOSAR port name, data element name, and interface name
% are the same as the Simulink(R) port name. You can change these default
% settings by using the AUTOSAR Interface dialog or command-line objects.
%

%% Change the Default AUTOSAR Port Settings: Using the AUTOSAR Interface Dialog
% <matlab:helpview([docroot,'/toolbox/ecoder/helptargets.map'],'autosar_interface_dialog_box') Overview of the AUTOSAR Interface dialog>
%
% # Click the *Tools* menu and select: *Real-Time Workshop* > *Configure Model
% as AUTOSAR Component* 
% # In the AUTOSAR Interface dialog box, click the *Get
% Default Configuration* to configure the model interface dialog to the default
% values.  
% # After making any changes, click the *Validate* button to confirm
% that any changes conform to AUTOSAR identifier naming conventions.
%
% An alternative method to change AUTOSAR port settings is to modify an
% existing configuration programmatically using an |RTW.AutosarInterface|
% object.

% Retrieve the RTW.AutosarInterface object
autosarInterface = RTW.getFunctionSpecification( modelName );

autosarInterface.getDefaultConf;    
autosarInterface.setIOAutosarPortName( 'Output', 'Counter' );
autosarInterface.setIODataAccessMode(  'Output', 'ImplicitSend' );
autosarInterface.setIODataElement(     'Output', 'data' );
autosarInterface.setIOInterfaceName(   'Output', 'genericInterface' );

[success, errmsg] = autosarInterface.runValidation();
if ~success
    error('rtwdemo:AUTOSAR', errmsg);
end


%% Generate AUTOSAR-Compliant Code
% Generate AUTOSAR-compliant code from the model by pressing Ctrl-B, or by using
% the following command.

rtwbuild( modelName );

%%
% |INC|, |K|, |LIMIT|, |RESET| have been configured as AUTOSAR calibration
% parameters, which are accessed using the AUTOSAR Rte_Calprm function signature
% in the generated code.

%%
% You can import the resulting generated XML files and C code into an AUTOSAR
% authoring tool. You will also need to import the calibration interface
% referenced by the calibration parameters
% (<matlab:web(fullfile(matlabroot,'toolbox','rtw','rtwdemos','CalibrationComponent.arxml'))
% CalibrationComponent.arxml>).
%

%% Verify the AUTOSAR Code Using Software-in-the-Loop Testing
% A common technique to verify the generated code is to wrap the generated
% code in an S-function. This allows you to verify the generated code in
% simulation. The AUTOSAR target automatically configures the generated
% S-function to route simulation data using AUTOSAR run-time
% environment (RTE) API calls.

% Configure the model for SIL
set_param( modelName, 'GenerateErtSFunction', 'on' );
set_param( modelName, 'GenCodeOnly', 'off' );

%%
% Use the following command to build the SIL block. Once the block has been
% built, you can create a test harness to verify that the SIL block produces the
% same data as the original model.  You can view more information about SIL
% verification in the *Testing Real-Time Code* section of the Real-Time
% Workshop(R) Embedded Coder(TM) guided introductions demonstration.
%

rtwbuild( modelName );

%% Further Information
%
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'ecoder_autosar') AUTOSAR Target documentation>

displayEndOfDemoMessage(mfilename)
