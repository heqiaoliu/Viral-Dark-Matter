%TARGETSEXTERNALMODEOPEN Implements external mode using the External Mode Open Protocol
%   TARGETSEXTERNALMODEOPEN Implements target independent functionality for 
%   external mode using the External Mode Open Protocol

%   Copyright 1990-2007 The MathWorks, Inc.
%   $Revision: 1.1.10.7 $  $Date: 2010/04/05 22:30:44 $

function hfcns = TargetsExternalModeOpen()

hfcns.i_UserHandleError           = @i_UserHandleError;
hfcns.i_UserInit                  = @i_UserInit;
hfcns.i_UserConnect               = @i_UserConnect;
hfcns.i_UserSetParam              = @i_UserSetParam;
hfcns.i_UserGetParam              = @i_UserGetParam;
hfcns.i_UserSignalSelect          = @i_UserSignalSelect;
hfcns.i_UserSignalSelectFloating  = @i_UserSignalSelectFloating;
hfcns.i_UserTriggerSelect         = @i_UserTriggerSelect;
hfcns.i_UserTriggerSelectFloating = @i_UserTriggerSelectFloating;
hfcns.i_UserTriggerArm            = @i_UserTriggerArm;
hfcns.i_UserTriggerArmFloating    = @i_UserTriggerArmFloating;
hfcns.i_UserCancelLogging         = @i_UserCancelLogging;
hfcns.i_UserCancelLoggingFloating = @i_UserCancelLoggingFloating;
hfcns.i_UserStart                 = @i_UserStart;
hfcns.i_UserStop                  = @i_UserStop;
hfcns.i_UserPause                 = @i_UserPause;
hfcns.i_UserStep                  = @i_UserStep;
hfcns.i_UserContinue              = @i_UserContinue;
hfcns.i_UserGetTime               = @i_UserGetTime;
hfcns.i_UserDisconnect            = @i_UserDisconnect;
hfcns.i_UserDisconnectImmediate   = @i_UserDisconnectImmediate;
hfcns.i_UserDisconnectConfirmed   = @i_UserDisconnectConfirmed;
hfcns.i_UserTargetStopped         = @i_UserTargetStopped;
hfcns.i_UserFinalUpload           = @i_UserFinalUpload;
hfcns.i_UserCheckData             = @i_UserCheckData;


%**************************************************************************
%                          PUBLIC FUNCTIONS
%**************************************************************************

function glbVars = i_UserHandleError(glbVars, action)
%
% This function is a user specified error handler and gets called whenever an
% error occurs
%
if strcmp(get_param(glbVars.glbModel, 'SimulationStatus'), 'external')
  if strcmp(get_param(glbVars.glbModel, 'ExtModeConnected'), 'on')
    % This will be called when external mode can help us to clean up
    set_param(glbVars.glbModel, 'SimulationCommand', 'disconnect');
  end
else
  % Catch others
  if glbVars.target.running
    % This will be called if we have a CCP connection and external mode is not
    % going to help us clean up
    % We need to do this to avoid a restart of MATLAB
    glbVars.target.ExternalModeOpen.disconnect();
    glbVars.target.running = false;
  else
    % This will be called if there is an error and there is no clean up required
    % e.g. in the 'Init' case. 
    %
    % We just want to exit external mode
    % 
    % Force an error to propagate to the next level - apparently external
    % mode ignores the actual message; it replaces it with its own.   
    %
    error('TargetsExternalModeOpen:UserHandleError', 'forceErrorToPropagate');
  end
end

% end i_UserHandleError

function glbVars = i_UserInit(glbVars)
%
% Called at the very beginning of the External Mode connect process before
% the model has been compiled and before the 'Connect' message has been issued.
% This is the place to perform any initialization needed at the start of an
% External Mode session, so long as the model checksum is not changed (which
% will cause the ensuing 'Connect' message to fail).
%

% This code relates to the model checksum
glbVars.myGlbTime = 0;

% Dummy values for the checksum, disable checksum validation
glbVars.myGlbChecksum1 = 1;
glbVars.myGlbChecksum2 = 2;
glbVars.myGlbChecksum3 = 3;
glbVars.myGlbChecksum4 = 4;
set_param(glbVars.glbModel, 'ExtModeSkipChecksumValidation', 'on');

glbVars.myGlbStopTime = str2num(get_param(glbVars.glbModel, 'StopTime'));

% Targets code
glbVars.target.signalCountInfo = [];
glbVars.target.signalSelect.firstTime = true;
glbVars.target.signals = [];

if (strcmp(get_param(glbVars.glbModel, 'ExtMode'), 'off')) ...
    || (strcmp(get_param(glbVars.glbModel, 'InlineParams'), 'off'))
  error([sprintf('\n') 'The model ' glbVars.glbModel ' has not been' ...
    ' correctly configured for external mode. To configure the model use'...
    ' the External Mode Switch Configuration block. Double click on the block' ...
    ' and select ''Building an executable''. Once the build is complete and the' ...
    ' application is downloaded, double click on the block and select ' ...
    ' ''External Mode'' to configure the model for external mode execution.' ...
    ' Alternatively follow the documented configuration steps for' ...
    ' building and executing external mode models.']);
end

[src_dir srcName] = targetsprivate('targets_get_build_dir', glbVars.glbModel);
glbVars.target.target_file_asap2 = fullfile(src_dir, [srcName '.a2l']);

% end i_UserInit

function [glbVars, status, checksum1, checksum2, checksum3, checksum4,...
  intCodeOnly, tgtStatus] = i_UserConnect(glbVars)
%
% Perform all operations needed to create a connection with the target
% executable.  The following information is returned:
%
%  1) glbVars     - If changes to global variables are needed.
%  2) status      - Was there an error during the connect process.
%  3) checksum1
%     checksum2
%     checksum3
%     checksum4   - Target executable checksum.
%  4) intCodeOnly - Is target executable built as integer only (no floats).
%  5) tgtStatus   - Is target executable running (3) or waiting to be started (1).
%

checksum1   = glbVars.myGlbChecksum1;
checksum2   = glbVars.myGlbChecksum2;
checksum3   = glbVars.myGlbChecksum3;
checksum4   = glbVars.myGlbChecksum4;
intCodeOnly = 0;
tgtStatus   = 3;

% Targets code
success = glbVars.target.ExternalModeOpen.connect();
if success
  glbVars.target.running = true;
end
% ext mode open expects status to be double
status = double(~success);

% end i_UserConnect

function [glbVars, status] = i_UserSetParam(glbVars, params)
%
% Download the values of the specified parameters to the target executable.
% The input argument 'params' is an array of structures with the following
% fields:
%
%   BlockName     - Full pathname of the block which owns the parameter.
%   ParameterName - Name of the parameter to download.
%   Values        - Parameter values to download.
%
% For the case of a workspace parameter, the field 'BlockName' will be empty.
% This case arises when in-line parameters is 'On' and a tunable workspace
% variable is used for some block's parameter (for example, the variable 'k'
% maybe used as a gain's parameter).
%
% Example:
%   Suppose a model named 'test' has a block named 'foo' with two parameters
%   named 'p1' and 'p2'.  The params variable would be
%
%     >> params
%     params
%
%     params =
%
%     1x2 struct array with fields:
%        BlockName
%        ParameterName
%        Values
%
%     >> params(1)
%     params(1)
%
%     ans =
%
%            BlockName: 'test/foo'
%        ParameterName: 'p1'
%               Values: 1
%
%
%     >> params(2)
%     params(2)
%
%     ans =
%
%            BlockName: 'test/foo'
%        ParameterName: 'p2'
%               Values: 0
%
status = 0;

% Targets code
% This code only applies when inline parameters = on
for i=1:length(params)
  paramName = params(i).ParameterName;
  objs = evalin('base', ['who(''' paramName ''')']);
  if ~isempty(objs)
    raiseError = false;
    errorString = '';
    
    % Check that paramName is a Simulink.Parameter
    isSimulinkParameter = evalin('base', ['isa(' paramName ', ''Simulink.Parameter'')']);
    if ~isSimulinkParameter
      raiseError = true;
      errorString = [errorString 'Parameter ' paramName ' must be a Simulink.Parameter' sprintf('\n')];
    end
    
    % Check the storage class of paramName is ExportedGlobal
    storageClass = evalin('base', [paramName '.RTWInfo.StorageClass']);
    if ~strcmp(storageClass, 'ExportedGlobal')
      raiseError = true;
      errorString = [errorString 'Parameter ' paramName ' must have storage class ExportedGlobal' sprintf('\n')];
    end
    
    % Check that paramName is a scalar
    dimensions = evalin('base', [paramName '.Dimensions']);
    % [1 1] are the dimensions of a scalar parameter object
    if ~all(dimensions == [1 1])
      raiseError = true;
      errorString = [errorString 'Parameter ' paramName ' must be a scalar value' sprintf('\n')];
    end

    if raiseError
      error([sprintf('\n') 'It was not possible to tune the parameter ' paramName '. To' ...
        ' tune parameter ' paramName ' the following conditions need to be' ...
        ' satisfied:' errorString]);
    end

    value = params(i).Values;
    dataType = evalin('base', [paramName '.DataType']);    
    % Create a parameter object
    param = TargetsMemoryMappedData_Parameter('symbolName', paramName, 'address', '000000', 'dataType', dataType);
    glbVars.target.ExternalModeOpen.setParameter(param, value);
  else
    % No information in the base workspace about parameter
    error([sprintf('\n') 'Information about parameter ' paramName ' was not found in the' ...
      ' base workspace. To tune parameter ' paramName ' a Simulink.Parameter' ...
      ' with storage class ExportedGlobal needs to be created in the base' ...
      ' workspace and associated with the parameter to tune. Parameters can' ...
      ' only be scalar values.']);
  end
end

% end i_UserSetParam

function [glbVars, status, params] = i_UserGetParam(glbVars)
%
% Upload the values of the specified parameters from the target executable.
% See i_UserSetParam() for an example of how to construct the return argument
% 'params'.
%
status = 0;
params = [];

% end i_UserGetParam

function [glbVars, status] = i_UserSignalSelect(glbVars)
%
% Setup the target executable to upload the signals specified in the cell array
% glbVars.glbUpInfoWired.upBlks.  Each cell in the array is a struct with the
% following fields
%
%   Name              - Full pathname of the uploading block.
%   SrcSignals        - Cell array of source signals to upload.
%   LogEventCompleted - Indicates if the block has completed uploading all data
%                       associated with a logging event.
%
% SrcSignals is a cell array of structs with the following fields:
%
%   Timeseries - Timeseries object completely describing the source signal
%                to upload and providing the buffers for time and data.
%
% Example:
%   Suppose a model has a single scope being uploaded.  In this case, the
%   glbVars.glbUpInfoWired.upBlks may look like the following:
%
%     >> glbVars.glbUpInfoWired.upBlks
%     glbVars.glbUpInfoWired.upBlks
%
%     ans =
%
%         [1x1 struct]
%
%     >> glbVars.glbUpInfoWired.upBlks{1}
%     glbVars.glbUpInfoWired.upBlks{1}
%
%     ans =
%
%               Name: 'mopen_intrf_wide/Scope'
%         SrcSignals: {[1x1 struct]  [1x1 struct]  [1x1 struct]}
%  LogEventCompleted: 0
%
%     >> glbVars.glbUpInfoWired.upBlks{1}.SrcSignals{2}
%     glbVars.glbUpInfoWired.upBlks{1}.SrcSignals{2}
%
%     ans =
%
%         Timeseries: [0x1 Simulink.Timeseries]
%
%     >> glbVars.glbUpInfoWired.upBlks{1}.SrcSignals{2}.Timeseries
%     glbVars.glbUpInfoWired.upBlks{1}.SrcSignals{2}.Timeseries
%               Name: 'unnamed2'
%          BlockPath: 'mopen_intrf_wide/Source2'
%          PortIndex: 1
%         SignalName: ''
%         ParentName: 'unnamed2'
%           TimeInfo: [1x1 Simulink.TimeInfo]
%               Time: []
%               Data: [0x3 embedded.fi]
%
status = 0;

% Targets code
for i = 1:length(glbVars.glbUpInfoWired.upBlks)
  if (length(glbVars.glbUpInfoWired.upBlks{i}.SrcSignals) > 1)
    error([sprintf('\n') 'A sink block ' glbVars.glbUpInfoWired.upBlks{i}.Name ...
      ' has multiple source signals. Sink blocks with multiple source' ...
      ' signals are not supported for data logging. Replace the existing' ... 
      ' sink block with multiple sink blocks each with 1 source signal' ...
      ' or remove the block from the list of blocks to be logged' ...
      ' using the Signal and Triggering configuration window of the' ...
      ' External Mode Control Panel.']);
  end
  for j = 1:length(glbVars.glbUpInfoWired.upBlks{i}.SrcSignals)
    currentSig = glbVars.glbUpInfoWired.upBlks{i}.SrcSignals{j};
    sigName = currentSig.SigName;
    
    % Check the signal name to see if it is a valid 
    if ~isvarname(sigName)
      % Invalid signal name connected to viewer and tell the user how to 
      % setup the signal
      viewerBlk = glbVars.glbUpInfoWired.upBlks{i}.Name;
      error([sprintf('\n') 'It was not possible to log one of the signals' ...
        ' connected to the block ' viewerBlk ' in the model as it can not be' ...
        ' mapped to a canlib.Signal in the base workspace.' ...
        ' This is because it is not a valid variable name.' ...
        ' To log a signal a canlib.Signal needs to be created in the ' ...
        ' base workspace. To do this, please right click on the' ...
        ' signal, select Signal Properties and name the signal' ...
        ' and check the box to resolve the signal to a Simulink signal' ...
        ' object. Then create a canlib.Signal object in the base workspace' ...
        ' with the same name and correct data type. Then rebuild and download' ...
        ' the application to the target.'
        ]);
    end
    
    % A signal name should have been specified
    if isempty(sigName)
      % No signal name was specified we want to throw an error
      sigName = 'unnamed';
      objs = [];
    else
      objs = evalin('base', ['who(''' sigName ''')']);

    if isempty(objs)
      % No information in the base workspace about signal
      error([sprintf('\n') 'To log signal ' sigName ' a canlib.Signal needs to be created' ...
        ' in the base workspace. To do this, please right click on the' ...
        ' signal ' sigName ', select Signal Properties and name the signal' ...
        ' and check. Then create a canlib.Signal object in the base workspace' ...
        ' with the same name and correct data type. Then rebuild and download' ...
        ' your application to the target.']);
    end
    end
    
    if isempty(glbVars.target.signals) || ~(ismember(currentSig.SigName, {glbVars.target.signals.signalName}))

      raiseError = false;
      errorString = '';

      % Check that this is a canlib.Signal
      isCanlibSignal = evalin('base', ['isa(' sigName ', ''canlib.Signal'')']);
      if ~isCanlibSignal
        raiseError = true;
        errorString = [errorString 'Signal ' sigName ' must be a canlib.Signal' sprintf('\n')];
      end
      
      % Check the width of the signal is scalar
      hs = get_param(currentSig.BlockPath, 'PortHandles');
      h = hs.Outport(currentSig.PortIndex);
      width = get_param(h,'CompiledPortWidth');
      if width > 1
        raiseError = true;
        errorString = [errorString 'Signal ' sigName ' must be a scalar' sprintf('\n')];
      end
      
      if raiseError
        error([sprintf('\n') 'It was not possible to log the signal ' sigName '. To' ...
          ' log signal ' sigName ' the following conditions need to be' ...
          ' satisfied:' sprintf('\n') errorString]);
      end
      
      sigDataType = evalin('base', [sigName '.DataType']);
      
      sigSampleTime = currentSig.SampleTime;
      if (sigSampleTime <= 0) || ~isfinite(sigSampleTime)
        error([sprintf('\n') 'It is not possible to log signal ' sigName ' with sample' ...
            ' time ' num2str(sigSampleTime) ' because a finite sample' ...
            ' time can not be determined. Remove the block ' ...
            glbVars.glbUpInfoWired.upBlks{i}.Name ' from the list of' ...
            ' blocks to be logged using the Signal and Triggering' ...
            ' configuration window of the External Mode Control Panel.']);
      end
      % Create a Signal object
      sig = TargetsMemoryMappedData_Signal('symbolName', sigName, 'address', '000000', 'dataType', sigDataType, 'sampleTime', sigSampleTime);

    else
      [member location] = ismember(sigName, {glbVars.target.signals.signalName});
      sig = glbVars.target.signals(location).signalObj;
    end
    glbVars.target.ExternalModeOpen.signalSelect(sig);
  end
end

glbVars.target.signalSelect.firstTime = false;

% end i_UserSignalSelect

function [glbVars, status] = i_UserSignalSelectFloating(glbVars)
%
% Setup the target executable to upload the signals specified in the cell array
% glbVars.glbUpInfoFloating.upBlks.  See i_UserSignalSelect() for an example of
% how to parse the signals to upload.
%
status = 0;

% end i_UserSignalSelectFloating

function [glbVars, status] = i_UserTriggerSelect(glbVars)
%
% Setup the target executable to trigger uploading the selected wired signals.
% The trigger signal is specified in glbVars.glbUpInfoWired.trigger as a struct
% with the following fields (for more in-depth discussion of each field, see
% the External Mode documentation):
%
%   Signal   - Non-empty struct if using a signal as the trigger.
%   OneShot  - If false, trigger re-arms automatically.
%   Duration - Number of base rate steps for which data logging event occurs.
%   BaseRate - Base rate of the model.
%
% If a signal is used as the trigger, the 'Signal' field is a struct with
% the following fields (for more in-depth discussion of each field, see
% the External Mode documentation):
%
%   Name      - Full pathname of the trigger signal block.
%   Port      - Port number of the trigger signal block.
%   Element   - Which element of the signal to use as trigger.
%   Sources   - Cell array of sources comprising the trigger signal.
%   Direction - Direction of trigger signal to fire an upload of data.
%   Level     - Value of trigger signal crossing to start a data logging event.
%   Delay     - Number of base rate steps to wait after trigger fires to begin
%               collecting data.
%   Holdoff   - Number of base rate steps to wait before re-arming the trigger.
%
% Sources is a cell array of structs with the following fields:
%
%   Name    - Full pathname of the source signal block.
%   Port    - Port number of the source signal block.
%   Element - Which element of the source signal is used to trigger.
%
% Example:
%   Suppose a model has a single scope being uploaded using a trigger signal
%   to start a data logging event.  In this case, glbVars.glbUpInfoWired.trigger
%   may look like the following:
%
%   >> glbVars.glbUpInfoWired.trigger
%   glbVars.glbUpInfoWired.trigger
%
%   ans =
%
%         Signal: [1x1 struct]
%        OneShot: 0
%       Duration: 100
%       BaseRate: 0.1000%
%
%   >> glbVars.glbUpInfoWired.trigger.Signal
%   glbVars.glbUpInfoWired.trigger.Signal
%
%   ans =
%
%            Name: 'mopen_intrf_wide/Scope'
%            Port: 1
%         Element: 'any'
%         Sources: {2x1 cell}
%       Direction: 'rising'
%           Level: 0
%           Delay: 0
%         HoldOff: 0
%
%   >> glbVars.glbUpInfoWired.trigger.Signal.Sources{2}
%   glbVars.glbUpInfoWired.trigger.Signal.Sources{2}
%
%   ans =
%
%          Name: 'mopen_intrf_wide/Source1'
%          Port: 1
%       Element: 2
%
status = 0;

% Targets code
duration = glbVars.glbUpInfoWired.trigger.Duration;
baseRate = glbVars.glbUpInfoWired.trigger.BaseRate;

for i = 1:length(glbVars.glbUpInfoWired.upBlks)
  for j = 1:length(glbVars.glbUpInfoWired.upBlks{i}.SrcSignals)
    currentSig = glbVars.glbUpInfoWired.upBlks{i}.SrcSignals{j};
    % Add signal to the signals list if it is not already there
    if isempty(glbVars.target.signals) || ~(ismember(currentSig.SigName, {glbVars.target.signals.signalName}));
      % Set the signal name
      glbVars.target.signals(end + 1).signalName = currentSig.SigName;
      % Create a signal object to represent this signal      
      sigDataType = evalin('base', [currentSig.SigName '.DataType']);
      currentSigSampleTime = currentSig.SampleTime;
      glbVars.target.signals(end).signalObj = TargetsMemoryMappedData_Signal('symbolName', currentSig.SigName, 'address', '000000', 'dataType', sigDataType, 'sampleTime', currentSigSampleTime);
      % Initialise the time and data series for the signal
      glbVars.target.signals(end).time = [];
      glbVars.target.signals(end).data = [];
      % Set the last data point received
      glbVars.target.signals(end).lastDataPoint = 0;
      % Set the number of samples required for a duration
      glbVars.target.signals(end).sampleCountBaseline = floor((duration / (currentSigSampleTime / baseRate)) + 1);
      % Initialise the sampleCount
      glbVars.target.signals(end).sampleCount = glbVars.target.signals(end).sampleCountBaseline;      
    end
  end
end

% end i_UserTriggerSelect

function [glbVars, status] = i_UserTriggerSelectFloating(glbVars)
%
% Setup the target executable to trigger uploading the selected floating
% signals.  See i_UserTriggerSelect() for an example of how to parse the
% trigger.
%
status = 0;

% end i_UserTriggerSelectFloating

function [glbVars, status] = i_UserTriggerArm(glbVars)
%
% Arm the trigger on the target executable for uploading the selected wired
% signals.
%
status = 0;

% This code overrides the scope x-axis scale
% scope x-axis limit = duration * baseRate
scopeXAxisLimit = (glbVars.glbUpInfoWired.trigger.Duration * 1.1 ) * glbVars.glbUpInfoWired.trigger.BaseRate;
set_param(glbVars.glbModel, 'OverrideScopeTimeRange', scopeXAxisLimit);

% Targets code
glbVars.target.ExternalModeOpen.triggerArm();

% end i_UserTriggerArm

function [glbVars, status] = i_UserTriggerArmFloating(glbVars)
%
% Arm the trigger on the target executable for uploading the selected floating
% signals.
%
status = 0;

% This code overrides the scope x-axis scale
% scope x-axis limit = duration * baseRate
scopeXAxisLimit = (glbVars.glbUpInfoWired.trigger.Duration * 1.1 ) * glbVars.glbUpInfoFloating.trigger.BaseRate;
set_param(glbVars.glbModel, 'OverrideFloatScopeTimeRange', scopeXAxisLimit);

% end i_UserTriggerArmFloating

function [glbVars, status] = i_UserCancelLogging(glbVars)
%
% Cancel logging on the target executable for uploading the selected wired
% signals.
%
status = 0;

% Targets code
glbVars.target.ExternalModeOpen.cancelLogging();

% end i_UserCancelLogging

function [glbVars, status] = i_UserCancelLoggingFloating(glbVars)
%
% Cancel logging on the target executable for uploading the selected floating
% signals.
%
status = 0;

% end i_UserCancelLoggingFloating

function [glbVars, status] = i_UserStart(glbVars)
%
% Start the target executable.
%
status = 0;

% end i_UserStart

function [glbVars, status] = i_UserStop(glbVars)
%
% Stop the target executable.
%
status = 0;

glbVars.target.ExternalModeOpen.targetStop()
glbVars.target.running = false;

% end i_UserStop

function [glbVars, status] = i_UserPause(glbVars)
%
% Pause the target executable.
%
status = 0;

% end i_UserPause

function [glbVars, status] = i_UserStep(glbVars)
%
% From a paused state, step the target executable one time step and return
% to a paused state.
%
status = 0;

% end i_UserStep

function [glbVars, status] = i_UserContinue(glbVars)
%
% From a paused state, continue running the target executable.
%
status = 0;

% end i_UserContinue

function [glbVars, time] = i_UserGetTime(glbVars)
%
% Get the simulation time from the target executable.
%
time = glbVars.myGlbTime;

% end i_UserGetTime

function [glbVars, status] = i_UserDisconnect(glbVars)
%
% Perform all operations needed to close a connection with the target
% executable.  This is considered a normal disconnection.
%
status = 0;

% Targets code
if glbVars.target.running
  glbVars.target.ExternalModeOpen.disconnect();
  glbVars.target.running = false;
end

% end i_UserDisconnect

function glbVars = i_UserDisconnectImmediate(glbVars)
%
% Perform all operations needed to close a connection with the target
% executable.  This is considered an abnormal disconnection resulting
% from some kind of error.  Simulink issues this action during an
% ungraceful connection and does not even know if communication with
% the target is still possible.  In this case, a 'DisconnectConfirmed'
% action will not be sent from Simulink.
%

% Targets code
if glbVars.target.running
  glbVars.target.ExternalModeOpen.disconnectImmediate();
  glbVars.target.running = false;
end

% end i_UserDisconnectImmediate

function glbVars = i_UserDisconnectConfirmed(glbVars)
%
% Perform any operations needed after Simulink has confirmed the connection
% is closed.
%

% Targets code
if glbVars.target.running
  glbVars.target.ExternalModeOpen.disconnect();
  glbVars.target.running = false;
end

% end i_UserDisconnectConfirmed

function [glbVars, status] = i_UserTargetStopped(glbVars)
%
% Returns true if the target has stopped, false otherwise.
%

status = false;
if (glbVars.myGlbTime > glbVars.myGlbStopTime)
  status = true;
end
% ext mode open expects status to be double
status = double(status);

% end i_UserTargetStopped

function glbVars = i_UserFinalUpload(glbVars)
%
% Uploads one last burst of data before the target shuts down.
%

% end i_UserFinalUpload

function glbVars = i_UserCheckData(glbVars, upInfo)
%
% This function is called periodically from Simulink to continuously
% check the target for available data.  Each uploading block specified
% in 'upInfo' is made up of some number of source signals.  Each source
% signal must have data uploaded from the target before the uploading
% block can be executed.  When data for a particular source signal is
% uploaded, the data must be written into the appropriate TimeSeries
% object via a call to:
%
%   glbVars = i_WriteSourceSignal(glbVars, src, time, data);
%
% The data written into the TimeSeries object must be the same type as
% the source signal in the Simulink model.  The data vector can be
% converted to the appropriate type via a call to:
%
%   data = i_ConvertToType(type, raw_data);
%
% Once all source signals for a particular uploading block have been
% written, the block must be executed via a call to:
%
%   glbVars = i_SendBlockExecute(glbVars, upInfoIdx, nUpBlk);
%
% The data for a particular logging event (one duration worth of data)
% does not have to be uploaded all at once.  When all of the data has
% been uploaded (whether it was in one chunk or spaced out over several
% calls to i_SendBlockExecute), the uploading block must be marked as
% completed via a call to:
%
%   glbVars = i_BlockLogEventCompleted(glbVars, upInfo.index, nUpBlk);
%

% Targets code
if glbVars.target.running

  % Early return if no signals to upload (DWork uploading is not supported)
  if isempty(glbVars.target.signals)
      return;
  end
  
  % Collect data from the target
  for srcSignal=1:length(glbVars.target.signals)
    [glbVars.target.signals(srcSignal).time glbVars.target.signals(srcSignal).data] = glbVars.target.ExternalModeOpen.checkData(glbVars.target.signals(srcSignal).signalObj, glbVars.target.signals(srcSignal).lastDataPoint);
    if ~isempty(glbVars.target.signals(srcSignal).time)
      glbVars.target.signals(srcSignal).lastDataPoint = glbVars.target.signals(srcSignal).time(end);
    end
    sampleCount = length(glbVars.target.signals(srcSignal).data);
    glbVars.target.signals(srcSignal).sampleCount = glbVars.target.signals(srcSignal).sampleCount - sampleCount;
  end

  % Update global time
  combinedTimes = [glbVars.target.signals.time];
  if ~isempty(combinedTimes)
    glbVars.myGlbTime = max(combinedTimes);
  end

  % Pass data collected from the target to external mode
  for upBlk = 1:length(upInfo.upBlks)
    allEmpty = true;
    
    for srcSignal = 1:length(upInfo.upBlks{upBlk}.SrcSignals)
      
      % Get the data for this signal that we collected from the target
      signalName = upInfo.upBlks{upBlk}.SrcSignals{srcSignal}.SigName;
      [member location] = ismember(signalName, {glbVars.target.signals.signalName});
      time = glbVars.target.signals(location).time;
      data = glbVars.target.signals(location).data;
      
      % If we did not collect an data then dont pass empty data to
      % external mode
      if ~isempty(time) && ~isempty(data)
        % Pass the data we collected from the target to external mode
        glbVars = feval(glbVars.utilsFile.i_WriteSourceSignal, glbVars, upInfo.index, upBlk, srcSignal, time', data');
        allEmpty = false;
      end
      
    end % for srcSignal = 1:length(upInfo.upBlks{upBlk}.SrcSignals)

    % If the signals for this block did not upload any data dont execute the block
    if ~allEmpty
      % Draw on the scope
      glbVars = feval(glbVars.utilsFile.i_SendBlockExecute, glbVars, upInfo.index, upBlk);

      if glbVars.target.signals(location).sampleCount <= 0
        % Reset the scope and start drawing from 0 again. We collected 1
        % durations worth of data
        glbVars = feval(glbVars.utilsFile.i_BlockLogEventCompleted, glbVars, upInfo.index, upBlk);
        % Reset the counter for this block
        glbVars.target.signals(location).sampleCount = glbVars.target.signals(location).sampleCountBaseline;
      end
    end
  end % for upBlk = 1:length(upInfo.upBlks)
end % if glbVars.target.running

% end i_UserCheckData
