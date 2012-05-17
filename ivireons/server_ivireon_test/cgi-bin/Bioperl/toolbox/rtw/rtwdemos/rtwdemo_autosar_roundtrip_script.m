%% Import and Export an AUTOSAR Software Component
% This demonstration shows you how to use an AUTOSAR authoring tool with
% Simulink(R) to develop AUTOSAR software components. This demo addresses the
% following tasks:
%
% # Design the software component interfaces in an AUTOSAR authoring tool and import this information into Simulink.
% # Export the completed software component from Simulink and merge this information back into an AUTOSAR authoring tool.
%

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/07/27 20:24:15 $


%% Overview of the AUTOSAR Software Component Description Files
% You can distribute the artifacts that constitute an AUTOSAR software
% component among multiple XML files. You can create the files with an
% AUTOSAR authoring tool or Simulink(R).
%

%% Design the Software Component Interfaces
% You can use an AUTOSAR authoring tool to define the following information for
% the software component:
%
% * Data types
% * Sender-receiver, client-server, calibration interfaces
% * Software components and their respective ports, which are typed by the above interfaces
%
% This demonstration includes two sets of software component interface XML files for the purpose of this demonstration.
%
% An AUTOSAR view of the two software components is shown below:
%
% <<AutosarComposition.jpg>>
%
%

%% Create arxml.importer Objects for the AUTOSAR Software Component Description Files
% Each software component requires an |arxml.importer| object. For each
% |arxml.importer| object, you need to specify the file that contains the software
% component of interest.

preprocessingFileName = fullfile(matlabroot,'toolbox','rtw', ...
    'rtwdemos','rtwdemo_autosar_preprocessing.arxml');
controlSystemFileName = fullfile(matlabroot,'toolbox','rtw', ...
    'rtwdemos','rtwdemo_autosar_control_system_component.arxml');

preprocessingImporter = arxml.importer( preprocessingFileName );
controlSystemImporter = arxml.importer( controlSystemFileName );

%%
% Now specify the additional files containing the information that
% completes the software component description (e.g., data types, 
% interfaces).
%

controlSystemFileNameDep1 = fullfile(matlabroot,'toolbox','rtw', ...
    'rtwdemos','rtwdemo_autosar_control_system_datatype.arxml');
controlSystemFileNameDep2 = fullfile(matlabroot,'toolbox','rtw', ...
    'rtwdemos','rtwdemo_autosar_control_system_interface.arxml');
controlSystemImporter.setDependencies( { controlSystemFileNameDep1, ...
    controlSystemFileNameDep2 } );

%% Create the Simulink Model Skeletons
% Using the two import objects, you can now create the
% skeleton Simulink models and associated data types. After you create
% the skeleton files, you can see that the preprocessing skeleton model 
% has two inports corresponding to the two data elements of the
% AUTOSAR port "in". These inports have bus objects associated with
% them that correspond to the C structure data type used to define the data
% elements. The fault inport is composed of a bus object that contains two
% Boolean elements, primary and secondary. The value inport is composed of
% a bus object that contains two elements of type double, primary and
% secondary.

% Create the Simulink model skeletons
preprocessingImporter.createComponentAsModel( '/ComponentType/preprocessing' );
controlSystemImporter.createComponentAsModel( '/ComponentType/controlSystem' );

% View all the imported AUTOSAR data types that you have imported 
who

%% Implement the Functionality Within the Simulink Model Skeletons
% Typically, the control engineer would now fill in the implementation for
% the two Simulink models. For this demo, you can open completed models:

% open the completed models
open_system( fullfile(matlabroot,'toolbox','rtw', ...
    'rtwdemos','rtwdemo_autosar_preprocessing' ) );
open_system( fullfile(matlabroot,'toolbox','rtw', ...
    'rtwdemos','rtwdemo_autosar_control_system' ) );

%% Create a Suitable Test Harness
% It is good practice to construct a test harness for controller functionality.
% You should click the *Run* button and view the scope after you open the
% model, using the following commands:
%

testHarnessFileName = fullfile(matlabroot,'toolbox','rtw', ...
    'rtwdemos','rtwdemo_autosar_testharness');
open_system( testHarnessFileName );
sim( testHarnessFileName );

%% Export and Generate Code for the AUTOSAR Software Components
% After you verify the output of the test harness, export the AUTOSAR
% software component files with the C code implementation.
% All the software component XML files are exported during code generation.

rtwbuild( 'rtwdemo_autosar_preprocessing' );
rtwbuild( 'rtwdemo_autosar_control_system' );

%% Merge into the Authoring Tool
% You can now merge the generated AUTOSAR software component files into an
% AUTOSAR authoring tool for further refinement or sign off. To facilitate
% merging, the software component information is in separate files, for example,
% one for data types and one for internal behavior. This partitioning minimizes
% the number of merges you need to do. In general, the data type file does not
% need to be merged into the authoring tool because data types are usually
% defined early in the design process.  You must, however, merge the internal
% behavior file because this information is part of the model implementation.
%
% <matlab:helpview([docroot,'/toolbox/ecoder/helptargets.map'],'autosar_export_details') Further details of exported files>
% 
% For example, to merge the generated AUTOSAR software component files into
% DaVinci System Architect (<matlab:web('http://www.vector-worldwide.com')
% Vector Informatik GmbH>).
%
% # Run DaVinci System Architect (2.3 or higher).
% # Either open an existing workspace, or create a new one: Select |File| > |New Workspace|, Enter a workspace name such as |Simulink_Demonstration|. Click |Open|.
% # Select |File| > |Import XML File| > |Add|.
% # Locate all of the generated XML files in the model build directory.
% # Click |Okay|.
% # Accept any further dialogs.
% 
% You have now successfully merged the software component, which includes a
% complete internal behavior description. You can verify the results by navigating to
% the implementation tab of the software component and viewing the number of runnable entities.

%% Further Information
%
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'ecoder_autosar') AUTOSAR Target documentation>

displayEndOfDemoMessage(mfilename)
