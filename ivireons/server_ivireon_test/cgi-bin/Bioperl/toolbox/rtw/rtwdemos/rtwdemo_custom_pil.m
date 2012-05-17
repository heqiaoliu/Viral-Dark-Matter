%% Creating a Custom Processor-in-the-Loop (PIL) Configuration
% In this demo you will create a target connectivity configuration using the
% target connectivity APIs. With a target connectivity configuration you can run
% PIL simulations on custom embedded hardware.
%
% You will learn how to:
%
%    * Adapt the build process to support PIL
%    * Configure a tool to use for downloading and starting execution of a PIL
%      executable on the target hardware
%    * Configure a communication channel between host and target that is used to
%      support PIL simulation on the target processor
%
% You will start with a model configured for SIL simulation. This demo will
% guide you through the process of creating a target connectivity configuration
% that allows you to simulate this model in PIL mode. You will start with an
% incomplete PIL connectivity configuration that gives errors when you attempt
% to use it. You will learn how to fix these errors and create a fully working
% PIL configuration. To fix the errors, you have these options:
%
%    * Edit MATLAB programs and fix the errors yourself
%    * Alternatively, allow the demo to make the changes automatically
%
% Note that this demo requires the Real-Time Workshop Embedded Coder product.
% 
% See also <matlab:showdemo('rtwdemo_sil_pil_script') rtwdemo_sil_pil_script>,
% <matlab:showdemo('rtwdemo_rtiostream') rtwdemo_rtiostream>

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.10 $

%% Preliminaries

% Later in this exercise you will add a directory to the path
sl_customization_path = fullfile(matlabroot,...
    'toolbox',...
    'rtw',...
    'rtwdemos',...
    'pil_demo');
% If this directory is already on the path, remove it
if strfind(path,sl_customization_path)
    rmpath(sl_customization_path)
end
% Reset any customizations
sl_refresh_customizations


%% Verify Generated Code Using Software-in-the-Loop (SIL) Simulation
% Simulate a model configured for SIL. This uses SIL to verify the generated
% code compiled for your host platform by comparing the simulation behavior
% with behavior of the corresponding generated code.


% Familiarization with Model block SIL; make sure the demo model is freshly
% opened
close_system('rtwdemo_sil_modelblock',0);
close_system('rtwdemo_sil_counter',0)
open_system('rtwdemo_sil_modelblock')

% Note that the Model block CounterA has the text (SIL) displayed on it.  This
% shows that the model referenced by this Model block is configured for SIL
% simulation.

% Run a simulation of this system
set_param('rtwdemo_sil_modelblock','StopTime','10');
sim('rtwdemo_sil_modelblock');

disp(' ')
disp('Review the output displayed above. In particular, note that a new')
disp('process was launched at the start of the simulation and killed at')
disp('the end of the simulation.')
disp(' ')

%% Start Work on a Target Connectivity Configuration
% In the previous step you ran a simulation in SIL mode. You are now ready to
% start work on a target connectivity configuration for PIL. To do this, you
% will use a set of skeleton classes that must be modified to create the target
% connectivity configuration for PIL.

% Make a local copy of the skeleton classes with new package directory name
src_dir = ...
    fullfile(matlabroot,'toolbox','rtw','rtw','+rtw','+mypil');
if exist(fullfile('.','+mypil'),'dir')
    rmdir('+mypil','s')
end
mkdir +mypil
copyfile(fullfile(src_dir,'Launcher.m'), '+mypil');
copyfile(fullfile(src_dir,'TargetApplicationFramework.m'), '+mypil');
copyfile(fullfile(src_dir,'ConnectivityConfig.m'), '+mypil');

% Ensure the copied files are writable
fileattrib('+mypil\*','+w');

% It is necessary to update one of the class files to reflect the change of
% package name from rtw.mypil to mypil
rtw.mypil.Utils.UpdateClassName(...
    './+mypil/ConnectivityConfig.m',...
    'rtw.mypil',...
    'mypil');

% Check that you now have a folder +mypil in the current directory including
% three files Launcher.m, TargetApplicationFramework.m and ConnectivityConfig.m
dir './+mypil'

%% View the Skeleton Classes
% The skeleton classes in the directories you have created represent a starting
% point that you will use for your target connectivity configuration.
% Commented-out sections in these classes implement a target connectivity
% configuration for running PIL on your host machine. This demo runs entirely on
% your host machine, however, you can follow the same steps to create a
% connectivity configuration for your embedded target hardware. Later in this
% exercise you will edit these commented out sections to activate the
% connectivity configuration.

% You can view these skeleton classes (do not make any changes at this
% stage)
edit mypil.Launcher
edit mypil.TargetApplicationFramework
edit mypil.ConnectivityConfig

%% Use sl_customization to Register the Target Connectivity Configuration
% To use the new PIL configuration you must provide an sl_customization
% file. The sl_customization file registers your new target connectivity
% configuration and specifies the conditions that must be satisfied in order to
% use it. The conditions specified in this file may include the name of your
% System Target File and your Hardware Implementation settings.

% You can view the sl_customization file (for the demo there is no need to
% make any changes to this file
edit(fullfile(sl_customization_path,'sl_customization.m'))

% Add the sl_customization directory to the path and refresh the
% customizations
addpath(sl_customization_path);
sl_refresh_customizations;

%% Try to Run a Simulation Using the Skeleton Configuration Classes
% Make sure the demo model is freshly opened: it is important to close and
% re-open the model, otherwise the updated configuration classes will not be
% picked up
close_system('rtwdemo_sil_modelblock',0)
open_system('rtwdemo_sil_modelblock')
set_param('rtwdemo_sil_modelblock/CounterA','SimulationMode','processor-in-the-loop (pil)');

% Attempt to run the simulation
set_param('rtwdemo_sil_modelblock','StopTime','10');
try
    sim('rtwdemo_sil_modelblock');
catch exceptionObj
    disp(' ')
    disp('What errors occurred? Review the error message above. The error')
    disp('message should indicate that there are some undefined functions:')
    disp('rtIOStreamOpen, rtIOStreamSend, rtIOStreamRecv. These are the')
    disp('names of functions needed by the PIL application running on')
    disp('the target; they are needed to communicate with the host machine.')
    disp('You must provide an implementation of these functions for your')
    disp('target hardware')
    disp(' ');
end

%% Review the Target-Side Communications Drivers
% View the file rtiostream_tcpip.c (do not make any changes):
rtiostreamtcpip_dir=fullfile(matlabroot,'rtw','c','src','rtiostream',...
    'rtiostreamtcpip');
edit(fullfile(rtiostreamtcpip_dir,'rtiostream_tcpip.c'))

% Scroll down to the end of this file and note that it file contains an
% implementation of the functions rtIOStreamOpen rtIOStreamSend, rtIOStreamRecv
% that were noted as 'undefined' in the error reported above

% To fix the error message above, this file must be added to the build.

%% Add Target-Side Communications Drivers to the Connectivity Configuration
% The class that configures additional files to include in the build is
% mypil.TargetApplicationFramework. Open this class in the editor:
edit(which('mypil.TargetApplicationFramework'))

% Review the commented lines ending with %UNCOMMENT. What files will be
% added to the build when these lines are uncommented?

% Once you have completed this review, you can use the MATLAB Editor menu
% command Text->Uncomment to uncomment the lines ending with %UNCOMMENT. You can
% make these changes manually or they will be performed automatically in the
% next step.

%% Use the Target-Side Communications Drivers

% Automatically uncomment sections in the file (if not already done manually)
rtw.mypil.Utils.Uncomment(fullfile('./+mypil/TargetApplicationFramework.m'));

% Attempt to run the simulation
close_system('rtwdemo_sil_modelblock',0)
open_system('rtwdemo_sil_modelblock')
set_param('rtwdemo_sil_modelblock/CounterA','SimulationMode','processor-in-the-loop (pil)');
set_param('rtwdemo_sil_modelblock','StopTime','10');
try
    sim('rtwdemo_sil_modelblock');
catch exceptionObj
    disp(' ')
    disp(exceptionObj.getReport)
    disp(' ')
    disp('What errors occurred? Review the error message above. The error')
    disp('message should indicate that there was a communications failure')
    disp('between the host and target. This is the error that occurs if')
    disp('the target application has not actually been launched. Was there')
    disp('any indication that a process for the PIL executable was started?')
    disp(' ')
end

%% Implement Code to Launch the PIL Executable
% The class that configures a tool for launching the PIL executable is
% mypil.Launcher. Open this class in the editor:
edit(which('mypil.Launcher'))

% Review the commented lines ending with %UNCOMMENT. Note the method
% setArgString that allows additional command line parameters to be
% supplied to the executable; these parameters may include a TCP/IP
% port number; for implementation on an embedded processor, it could be
% more difficult to supply start-up parameters and you may choose to
% have these settings hard-coded. Note the disp commands within the
% setArgString method that display debugging information to indicate
% when this method is called and the name of the calling file.

% Remove the comment characters when you have understood the purpose of
% the commented out sections

%% Use the Launcher to Start the PIL Executable

% Automatically uncomment lines in the file
rtw.mypil.Utils.Uncomment('./+mypil/Launcher.m')

% Attempt to run the simulation
close_system('rtwdemo_sil_modelblock',0)
open_system('rtwdemo_sil_modelblock')
set_param('rtwdemo_sil_modelblock/CounterA','SimulationMode','processor-in-the-loop (pil)');
set_param('rtwdemo_sil_modelblock','StopTime','10');
try
    sim('rtwdemo_sil_modelblock');
catch exceptionObj
    disp(' ')
    disp(exceptionObj.getReport)
    disp(' ')
    disp(' ')
    disp('What errors occurred? Carefully review the build log above. Was')
    disp('a process for the PIL application started successfully? You should')
    disp('see that although the PIL application started there was still a failure')
    disp('communicating with the target. Was the setArgString method called? If')
    disp('the setArgString method was not called, the host-target communications')
    disp('were not fully configured.')
    disp(' ')
end

%% Configure the Communications Channel
% To complete the configuration of the host-target communications channel, edit
% the class mypil.ConnectivityConfig:
edit(which('mypil.ConnectivityConfig'))

% Review the lines ending with %UNCOMMENT. You should be able to identify
%
% * a call to the setArgString method of Launcher that configures
%   the target side of the communications channel
% * configuration of the host-side of communications channel
%
% When you are satisfied, remove the comment characters.

%% Use the Newly Configured Host-Target Communications

% Automatically uncomment lines in the file
rtw.mypil.Utils.Uncomment('./+mypil/ConnectivityConfig.m')


% Attempt to run the simulation
close_system('rtwdemo_sil_modelblock',0)
open_system('rtwdemo_sil_modelblock')
set_param('rtwdemo_sil_modelblock/CounterA','SimulationMode','processor-in-the-loop (pil)');
set_param('rtwdemo_sil_modelblock','StopTime','10');
sim('rtwdemo_sil_modelblock');

disp(' ')
disp('Review the output in the command window: were there any errors? There may be ')
disp('errors if you tried making your own edits; in this case you should review your ')
disp('changes and try to identify the problem. To diagnose and fix the problem, it ')
disp('may be helpful to:')
disp(' ')
disp('  - use the command "netstat -a", from a command prompt on the host computer, to ')
disp('    check for any TCP/IP connections left open on port 14646')
disp('  - kill any zombie processes, on your host computer, called "rtwdemo_sil_counter"')
disp(' ')
disp('If the simulation ran successfully and there were no errors: congratulations, you')
disp('have implemented a target connectivity configuration for PIL! You can now')
disp('use the same APIs to implement a connectivity configuration for your own')
disp('combination of embedded processor, download tool and communications channel.')

%% Clean Up

% Remove the path that was added temporarily
rmpath(sl_customization_path)
% Reset any customizations
sl_refresh_customizations

% Close the models
close_system('rtwdemo_sil_modelblock',0)
close_system('rtwdemo_sil_counter',0)

displayEndOfDemoMessage(mfilename)
