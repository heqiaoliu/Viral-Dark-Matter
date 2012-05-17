function varargout = embedded_target_download(varargin)
%   EMBEDDED_TARGET_DOWNLOAD Download files to an embedded target over a communication link.
%
%   embedded_target_download launches the Download Control Panel GUI that allows files to be downloaded
%   to the target (eg. MPC555) over a communication link (eg. CAN, Serial).
%
%   embedded_target_download('force') completely resets and re-launches the Download Control
%   Panel GUI.   Use this option only if the GUI cannot be raised by calling 
%   embedded_target_download with no arguments.
%
%   embedded_target_download('install', installDir) installs embedded_target_download.bat 
%   in "installDir" for use outside of the MATLAB environment.

%   Copyright 2002-2010 The MathWorks, Inc.

persistent StandaloneMPC555Control Listener %#ok<PUSE>

if (nargin == 0) 
    % end user case - launch the GUI
    if (isempty(StandaloneMPC555Control))
        % create GUI
        [StandaloneMPC555Control, Listener] = i_creategui;
        awtinvoke(java(StandaloneMPC555Control), 'show()');
    else
        % bring existing GUI to the front
        i_bringToFront(StandaloneMPC555Control);
    end;
else 
    % MathWorks internal options...
    % process varargin
    action = varargin{1};
    switch (lower(action))
    case 'clearpersistentvariables'
        % clear the persistent variables to allow
        % a new GUI to be created
        clear Listener;
        clear StandaloneMPC555Control;
    case 'commandline'
        % commandline usage
        if (isempty(StandaloneMPC555Control))
            % create GUI
            [StandaloneMPC555Control, Listener] = i_creategui;
        else 
            % hide any existing GUI!
            awtinvoke(java(StandaloneMPC555Control), 'hide()');
        end;
    case 'hidegui'
        % hide the gui
        if (i_guiIsInitialised(StandaloneMPC555Control))
            awtinvoke(java(StandaloneMPC555Control), 'hide()');
        end;
    case 'showgui'
        % show the gui
        if (i_guiIsInitialised(StandaloneMPC555Control))
            awtinvoke(java(StandaloneMPC555Control), 'show()');
        end;
    case 'startdownload'
        % commence the download programmatically
        if (i_guiIsInitialised(StandaloneMPC555Control))
            StandaloneMPC555Control.startDownloadAndWait;
        end;
    case 'startdownloadnowait' 
      % commence the download programmatically 
      if (i_guiIsInitialised(StandaloneMPC555Control)) 
        StandaloneMPC555Control.startDownload; 
      end;
    case 'setconnecttimeout' 
      % commence the download programmatically 
      timeout = varargin{2};
      if (i_guiIsInitialised(StandaloneMPC555Control))
        StandaloneMPC555Control.setConnectTimeout(timeout); 
      end;
    case 'force'
        % clear any existing download GUI state
        % and launch a new one
        if (~isempty(StandaloneMPC555Control))
            embedded_target_download('hidegui');
        end;
        embedded_target_download('clearPersistentVariables');
        embedded_target_download;
    case 'set'
        % set Download options
        if (i_guiIsInitialised(StandaloneMPC555Control))
          methodName = ['set' varargin{2}];
          awtInvokeToken = i_getAwtinvokeToken(methodName, StandaloneMPC555Control);
          methodSig = [methodName '(' awtInvokeToken ')'];
          argument = varargin{3};
          awtinvoke(java(StandaloneMPC555Control), methodSig, argument);
        end;
    case 'status'
        if isempty(StandaloneMPC555Control)
            varargout = { 'idle' };
        elseif StandaloneMPC555Control.isDownloading
            varargout = { 'downloading' };
        else
            varargout = { 'idle' };
        end
    case 'install'
        error(nargchk(2, 2, nargin, 'struct'))
        % get the installation dir
        installDir = varargin{2};
        % install standalone download utility
        i_install(installDir);
    otherwise
        disp(['Unknown action ' action]);
    end;
end;


function i_install(installDir)
%
% install standalone download utility
%

% create dir if necessary
i_Mkdir(installDir);

mpc555SubDir = fullfile(installDir, 'mpc555dk', 'mpc555dk');
% create dir if necessary
i_Mkdir(mpc555SubDir);

batchFile = fullfile(matlabroot, ...
                     'toolbox', ...
                     'rtw', ...
                     'targets', ...
                     'common', ...
                     'tgtcommon', ...
                     'embedded_target_download.bat');
jarDir = fullfile(matlabroot, ...
                  'java', ...
                  'jar');
              
jarExtDir = fullfile(matlabroot, ...
                     'java', ...
                     'jarext');                                 

binDir = fullfile(matlabroot, ...
                  'bin', ...
                  'win32');
              
installDirFiles = {batchFile, ...
                   fullfile(jarDir, 'common.jar'), ...
                   fullfile(jarDir, 'util.jar'), ...
                   fullfile(jarDir, 'services.jar'), ...
                   fullfile(jarDir, 'jmi.jar'), ...
                   fullfile(jarDir, 'beans.jar'), ...
                   fullfile(jarDir, 'mwt.jar'), ...
                   fullfile(jarDir, 'mwswing.jar'), ...
                   fullfile(jarDir, 'toolbox', 'ecoder.jar'), ...
                   fullfile(jarExtDir, 'RXTXcomm.jar'), ...
                   fullfile(binDir, 'vector_can_library_exports.dll'), ...
                   fullfile(binDir, 'vector_can_library_standalone.dll'), ...
                   fullfile(binDir, 'rxtxSerial.dll')};
i_installFiles(installDirFiles, installDir);
               
mpc555SubDirFiles = {fullfile(matlabroot, ...
                       'toolbox', ...
                       'rtw', ...
                       'targets', ...
                       'mpc555dk', ...
                       'mpc555dk', ...
                       'mpc555bootver.txt')};
i_installFiles(mpc555SubDirFiles, mpc555SubDir);                   


function i_installFiles(files, installDir)
for i=1:length(files)
   f = files{i};
   [success, message, messageid] = copyfile(f, installDir, 'f');
   if ~success
      error(messageid, '%s', message); 
   end    
end

function i_Mkdir(dirPath)        
if ~exist(dirPath, 'dir')    
    [success, message, messageid] = mkdir(dirPath);
    if ~success
       error(messageid, '%s', message); 
    end
end
                   
  
function init = i_guiIsInitialised(javahandle)
    if (isempty(javahandle))
        % Java GUI has not been initialised
        disp('Error: The Download Control Panel GUI has not been correctly initialised.');
        disp('The Download Control Panel GUI may be initialised by any of the following:');
        disp('embedded_target_download, embedded_target_download(''force''), embedded_target_download(''commandline'')');
        init = 0;
    else
        init = 1;
    end;
return;

function i_bringToFront(javahandle)
    % bring existing GUI to the front
    javahandle.toFront;
return;

function [javahandle, listener] = i_creategui
    % instead of the MATLAB work dir, use the current dir
    % as the work dir
    work_dir_path = pwd;
    % need to provide the path to matlab/toolbox/rtw/targets so that
    % the download code can find the appropriate bootcodeversion.txt file
    bootverpath = fullfile(matlabroot, 'toolbox', 'rtw', 'targets', '');
    
    % get a suitable icon image - desktop is not always available    
    if isempty(javachk('desktop'))
       icon  = com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame.getIconImage;
    else
       icon  = [];
    end
    
    % create the java object and store a handle to it.
    StandaloneMPC555Controljava = awtcreate('com.mathworks.toolbox.ecoder.canlib.CanDownload.StandaloneMPC555Control', ...
                                            'Ljava.awt.Image;Ljava.lang.String;Ljava.lang.String;Z', ...
                                            icon, work_dir_path, bootverpath, 0);
    
    javahandle = handle(StandaloneMPC555Controljava,'callbackproperties');
    
    % use the @cancommon/@candownloadprefs preferences to 
    % initialise the GUI
    prefs = RTW.TargetPrefs.load('cancommon.candownloadprefs');
     
    javahandle.setCCP_CRO_Id(prefs.CAN_message_id_CRO);
    javahandle.setCCP_DTO_Id(prefs.CAN_message_id_DTO);
    javahandle.setCCP_Station_Id(prefs.CCP_Station_Address);
    javahandle.setCanHardware(prefs.CAN_Hardware);
    javahandle.setBitRate(prefs.Bit_Rate);
    javahandle.setNumQuanta(prefs.Num_Quanta);
    javahandle.setSamplePoint(prefs.Sample_Point);
    javahandle.setDownloadType(prefs.Download_Type);
    javahandle.setNetworkType(prefs.ConnectionType);
    javahandle.setSerialCommPort(prefs.SerialPort);
    javahandle.setApplicationChannel(prefs.Application_Channel);
    
    % create a listener for ActionPerformed callbacks from Java.
    listener = handle.listener(javahandle,'ActionPerformed',{@i_action_callback javahandle});
    
    % -- Layout the dialog in the center of the screen ---
    screen_size = java.awt.Toolkit.getDefaultToolkit.getScreenSize;
    dialog_size = javahandle.getSize;
    new_pos = java.awt.Dimension((screen_size.width-dialog_size.width)/2, ...
        (screen_size.height-dialog_size.height)/2);
    awtinvoke(java(javahandle), 'setLocation(II)', new_pos.width, new_pos.height);
    drawnow;
return;

function i_savePrefs(javahandle)
    % use the @cancommon/@candownloadprefs preferences 
    % to store the prefs.
    prefs = RTW.TargetPrefs.load('cancommon.candownloadprefs'); 
    
    % get the current settings from the gui
    prefs.CAN_message_id_CRO = javahandle.getCCP_CRO_Id;
    prefs.CAN_message_id_DTO = javahandle.getCCP_DTO_Id;
    prefs.CCP_Station_Address = javahandle.getCCP_Station_Id;
    prefs.CAN_Hardware = char(javahandle.getCanHardware);
    prefs.Bit_Rate = javahandle.getBitRate;
    prefs.Num_Quanta = javahandle.getNumQuanta;
    prefs.Sample_Point = javahandle.getSamplePoint;
    prefs.Download_Type = char(javahandle.getDownloadType);
    prefs.ConnectionType = char(javahandle.getNetworkType);
    prefs.SerialPort = char(javahandle.getSerialCommPort);
    prefs.Application_Channel = javahandle.getApplicationChannel;
    
    % save the preferences
    prefs.save;
return;
    
function i_action_callback(source, event, javahandle) %#ok<INUSL>
   import('com.mathworks.toolbox.ecoder.canlib.CanDownload.*');

   % get the ActionPerformed callback data.
   data = get(javahandle,'ActionPerformedCallbackData');
   
   switch char(data.getActionCommand)
   case char(StandaloneMPC555Control.DOWNLOAD_ACTION)
       % callback no longer used - GUI controls this
   case char(StandaloneMPC555Control.CANCEL_DOWNLOAD_ACTION)
       % callback no longer used - GUI control this
   case char(StandaloneMPC555Control.GENERIC_CANCEL_ACTION)
       % callback for the main cancel button
       % this will allow a new GUI to be created with a call 
       % toembedded_target_download 
       embedded_target_download('clearPersistentVariables');
   case char(StandaloneMPC555Control.HELP_ACTION) 
       % link to help here.
       helpview([docroot '/toolbox/mpc555dk/mpc555dk.map'], 'can_download');
   case char(StandaloneMPC555Control.SAVE_PREFS_ACTION)
       i_savePrefs(javahandle);
   otherwise
       disp('Unknown action callback.');
       disp(data.getActionCommand);
   end;
return;

function awtInvokeToken = i_getAwtinvokeToken(methodNameToFind, javaHandle)
awtInvokeToken = '';
% Do some reflection on the StandaloneMPC555Control class
class = javaHandle.getClass();
% Get a list of the methods of this class
methods = class.getMethods();
% Search the methods for the one we are interested in
for i = 1:length(methods)
  % Get the method name
  methodName = methods(i).getName;
  if strcmp(methodName, methodNameToFind)
    % Get the parameters of the method
    parameters = methods(i).getParameterTypes();
    % We are only expecting 1 parameter as the methods we are looking for are setYYY methods
    if parameters.length > 1
      TargetCommon.ProductInfo.error('common', 'InvalidParameters');
    end
    % Get the type of the parameter and translate it to the JNI type used by awtInvoke
    % We expect atomic types, no arrays or special classes
    type = parameters(1).getName;
    switch char(type)
      case 'boolean'
        awtInvokeToken = 'Z';        
      case 'byte'
        awtInvokeToken = 'B';
      case 'char'
        awtInvokeToken = 'C';
      case 'short'
        awtInvokeToken = 'S';
      case 'int'
        awtInvokeToken = 'I';
      case 'long'
        awtInvokeToken = 'J';
      case 'float'
        awtInvokeToken = 'F';
      case 'double'
        awtInvokeToken = 'D';
      case 'java.lang.String'
        awtInvokeToken = 'Ljava.lang.String;';
      otherwise
        TargetCommon.ProductInfo.error('common', 'UnexpectedType');
    end
  end
end
% We did not find the method we were looking for either it is not there or 
% something is wrong with the code above
if isempty(awtInvokeToken)
  TargetCommon.ProductInfo.error('common', 'MissingMethodInClass', methodNameToFind, char(class.getName()));
end
