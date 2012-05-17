function ext_open_intrf(varargin)
%
% Main switch statement for External Mode Open Protocol communication.
% The Simulink engine calls into this file for communicating with a target.
% Each call performs the following steps:
%
%   Pre target-independent tasks
%   Target-dependent user-implemented function call
%   Process any errors in user-implemented functions
%   Post target-independent tasks
%
% The target-dependent user-implemented portion is contained in a separate
% m-file following a particular form.  The name of this user m-file is
% passed down via the Init command.
%

% Copyright 2005-2007 The MathWorks, Inc.

%
% Lock this file to prevent the persistent variables from being cleared.
%
mlock;

%
% Array of persistent variables for each model which connects to a target.
%
persistent models;

%
% Check for correct number of input arguments.
%
error(nargchk(1, Inf, nargin));

%
% The first argument to every call is the name of the model.  Pull out
% the model name to find the appropriate set of persistent variables.
%
model = varargin{1};
args  = varargin(2:end);

%
% Each model must maintain its own set of persistent variables.
%
if isempty(models)
    models(1).model        = model;
    models(1).glbVars      = [];
    models(1).messageQueue = [];
    idx = 1;
else
    idx = find(strcmp(model,{models.model}) == 1);
    if isempty(idx)
        models(end+1) = struct('model', model, 'glbVars', [], 'messageQueue', []);
        idx = length(models);
    else
        assert(length(idx) == 1);
    end
end

%
% Do not process any messages while CheckData is running.  Instead,
% queue up the messages and run them after CheckData has finished.
%
try
    if models(idx).glbVars.glbCheckDataIsProcessing == 1
        models(idx).messageQueue{end+1} = varargin;
        return;
    end
catch
end

%
% The second argument to every call is the action to perform.  Pull out
% the action to determine which case of the switch statement to execute.
%
action = args{1};
args   = args(2:end);

%
% The main switch statement.  Each supported action has a case in the
% switch statement.  Each action will do some target independent
% pre-processing, call a target specific function, then do some target
% independent post-processing.  It is up to the implementer of the target
% specific portion of the interface to perform all target related actions
% and to follow the proper rules of the interface as documented.
%
switch (action)
    case 'Init'
        try
            models(idx).glbVars.glbModel                 = args{1};
            models(idx).glbVars.intrfFile                = feval(args{2});
            models(idx).glbVars.utilsFile                = feval(args{3});
            models(idx).glbVars.glbUpInfoWired           = [];
            models(idx).glbVars.glbUpInfoFloating        = [];
            models(idx).glbVars.glbCheckDataIsProcessing = 0;
            models(idx).messageQueue                     = [];
            
            models(idx).glbVars = i_UserInit(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'Init'

    case 'Connect'
        try
            [models(idx).glbVars, status, checksum1, checksum2, checksum3, checksum4,...
                intCodeOnly, tgtStatus] = i_UserConnect(models(idx).glbVars);                
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendConnectResponse(models(idx).glbVars, 1, 0, 0, 0, 0, 0, 0);
            return;
        end
        try
            i_SendConnectResponse(models(idx).glbVars, status, checksum1, checksum2,...
                checksum3, checksum4, intCodeOnly, tgtStatus);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'Connect'

    case 'SetParam'
        try
            params = args{1};
            [models(idx).glbVars, status] = i_UserSetParam(models(idx).glbVars, params);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendSetParamResponse(models(idx).glbVars, 1);
            return;
        end
        try
            i_SendSetParamResponse(models(idx).glbVars, status);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'SetParam'

    case 'GetParam'
        try
            [models(idx).glbVars, status, params] = i_UserGetParam(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendGetParamResponse(models(idx).glbVars, 1, []);
            return;
        end
        try
            i_SendGetParamResponse(models(idx).glbVars, status, params);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'GetParam'

    case 'SignalSelect',
        try
            models(idx).glbVars.glbUpInfoWired.upBlks        = i_ParseUpBlks(args{1});
            models(idx).glbVars.glbUpInfoWired.index         = args{1}.Index;
            models(idx).glbVars.glbUpInfoWired.trigger_armed = 0;
            [models(idx).glbVars, status] = i_UserSignalSelect(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendSignalSelectResponse(models(idx).glbVars, 1, models(idx).glbVars.glbUpInfoWired.index);
            return;
        end
        try
            i_SendSignalSelectResponse(models(idx).glbVars, status, models(idx).glbVars.glbUpInfoWired.index);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'SignalSelect'

    case 'SignalSelectFloating',
        try
            models(idx).glbVars.glbUpInfoFloating.upBlks        = i_ParseUpBlks(args{1});
            models(idx).glbVars.glbUpInfoFloating.index         = args{1}.Index;
            models(idx).glbVars.glbUpInfoFloating.trigger_armed = 0;
            [models(idx).glbVars, status] = i_UserSignalSelectFloating(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendSignalSelectResponse(models(idx).glbVars, 1, models(idx).glbVars.glbUpInfoFloating.index);
            return;
        end
        try
            i_SendSignalSelectResponse(models(idx).glbVars, status, models(idx).glbVars.glbUpInfoFloating.index);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'SignalSelectFloating'

    case 'TriggerSelect'
        try
            models(idx).glbVars.glbUpInfoWired.trigger = args{1};
            [models(idx).glbVars, status] = i_UserTriggerSelect(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendTriggerSelectResponse(models(idx).glbVars, 1, models(idx).glbVars.glbUpInfoWired.index);
            return;
        end
        try
            i_SendTriggerSelectResponse(models(idx).glbVars, status, models(idx).glbVars.glbUpInfoWired.index);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'TriggerSelect'

    case 'TriggerSelectFloating'
        try
            models(idx).glbVars.glbUpInfoFloating.trigger = args{1};
            [models(idx).glbVars, status] = i_UserTriggerSelectFloating(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendTriggerSelectResponse(models(idx).glbVars, 1, models(idx).glbVars.glbUpInfoFloating.index);
            return;
        end
        try
            i_SendTriggerSelectResponse(models(idx).glbVars, status, models(idx).glbVars.glbUpInfoFloating.index);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'TriggerSelectFloating'

    case 'TriggerArm'
        try
            [models(idx).glbVars, status] = i_UserTriggerArm(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            models(idx).glbVars.glbUpInfoWired.trigger_armed = 0;
            i_SendTriggerArmResponse(models(idx).glbVars, 1, models(idx).glbVars.glbUpInfoWired.index);
            return;
        end
        try
            models(idx).glbVars.glbUpInfoWired.trigger_armed = 1;
            i_SendTriggerArmResponse(models(idx).glbVars, status, models(idx).glbVars.glbUpInfoWired.index);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'TriggerArm'

    case 'TriggerArmFloating'
        try
            [models(idx).glbVars, status] = i_UserTriggerArmFloating(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            models(idx).glbVars.glbUpInfoFloating.trigger_armed = 0;
            i_SendTriggerArmResponse(models(idx).glbVars, 1, models(idx).glbVars.glbUpInfoFloating.index);
            return;
        end
        try
            models(idx).glbVars.glbUpInfoFloating.trigger_armed = 1;
            i_SendTriggerArmResponse(models(idx).glbVars, status, models(idx).glbVars.glbUpInfoFloating.index);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'TriggerArmFloating'

    case 'CancelLogging'
        try
            models(idx).glbVars.glbUpInfoWired.trigger_armed = 0;
            [models(idx).glbVars, status] = i_UserCancelLogging(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendCancelLoggingResponse(models(idx).glbVars, 1, models(idx).glbVars.glbUpInfoWired.index);
            set_param(models(idx).glbVars.glbModel,'ExtModeOpenProtocolTerminateLogSession',models(idx).glbVars.glbUpInfoWired.index);
            return;
        end
        try
            i_SendCancelLoggingResponse(models(idx).glbVars, status, models(idx).glbVars.glbUpInfoWired.index);
            set_param(models(idx).glbVars.glbModel,'ExtModeOpenProtocolTerminateLogSession',models(idx).glbVars.glbUpInfoWired.index);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        %case 'CancelLogging'

    case 'CancelLoggingFloating'
        try
            if ~isempty(models(idx).glbVars.glbUpInfoFloating)
                models(idx).glbVars.glbUpInfoFloating.trigger_armed = 0;
                [models(idx).glbVars, status] = i_UserCancelLoggingFloating(models(idx).glbVars);
            end
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendCancelLoggingResponse(models(idx).glbVars, 1, models(idx).glbVars.glbUpInfoFloating.index);
            set_param(models(idx).glbVars.glbModel,'ExtModeOpenProtocolTerminateLogSession',models(idx).glbVars.glbUpInfoFloating.index);
            return;
        end
        try
            if ~isempty(models(idx).glbVars.glbUpInfoFloating)
                i_SendCancelLoggingResponse(models(idx).glbVars, status, models(idx).glbVars.glbUpInfoFloating.index);
                set_param(models(idx).glbVars.glbModel,'ExtModeOpenProtocolTerminateLogSession',models(idx).glbVars.glbUpInfoFloating.index);
            end
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        %case 'CancelLoggingFloating'

    case 'Start'
        try
            [models(idx).glbVars, status] = i_UserStart(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendStartResponse(models(idx).glbVars, 1);
            return;
        end
        try
            i_SendStartResponse(models(idx).glbVars, status);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'Start'

    case 'Stop'
        try
            [models(idx).glbVars, status] = i_UserStop(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendStopResponse(models(idx).glbVars, 1);
            return;
        end
        try
            i_SendStopResponse(models(idx).glbVars, status);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'Stop'

    case 'Pause'
        try
            [models(idx).glbVars, status] = i_UserPause(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendPauseResponse(models(idx).glbVars, 1);
            return;
        end
        try
            i_SendPauseResponse(models(idx).glbVars, status);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'Pause'

    case 'Step'
        try
            [models(idx).glbVars, status] = i_UserStep(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendStepResponse(models(idx).glbVars, 1);
            return;
        end
        try
            i_SendStepResponse(models(idx).glbVars, status);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'Step'

    case 'Continue'
        try
            [models(idx).glbVars, status] = i_UserContinue(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendContinueResponse(models(idx).glbVars, 1);
            return;
        end
        try
            i_SendContinueResponse(models(idx).glbVars, status);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'Continue'

    case 'GetTime'
        try
            [models(idx).glbVars, time] = i_UserGetTime(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            return;
        end
        try
            i_SendGetTimeResponse(models(idx).glbVars, time);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'GetTime'

    case 'Disconnect'
        try
            [models(idx).glbVars, status] = i_UserDisconnect(models(idx).glbVars);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            i_SendDisconnectResponse(models(idx).glbVars, 1);
            return;
        end
        try
            i_SendDisconnectResponse(models(idx).glbVars, status);
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
        end
        % case 'Disconnect'

    case 'DisconnectImmediate'
        try
            models(idx).glbVars = i_UserDisconnectImmediate(models(idx).glbVars);

            % No response sent back
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            return;
        end
        % case 'DisconnectImmediate'

    case 'DisconnectConfirmed'
        try
            models(idx).glbVars = i_UserDisconnectConfirmed(models(idx).glbVars);

            % No response sent back
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            return;
        end
        % case 'DisconnectConfirmed'

    case 'FinalUpload'
        try
            models(idx).glbVars = i_UserFinalUpload(models(idx).glbVars);

            % No response sent back
        catch ME
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            return;
        end
        % case 'FinalUpload'

    case 'CheckData'
        try
            %
            % Process all commands which have accumulated in the queue.
            %
            models(idx).messageQueue = i_ProcessMessageQueue(models(idx).messageQueue);

            %
            % Set the flag so that any other calls to this file will be
            % queued up and executed later.  This makes the CheckData
            % command an atomic operation (no interruptions).
            %
            models(idx).glbVars.glbCheckDataIsProcessing = 1;
            
            %
            % Handle wired blocks.
            %
            if ~isempty(models(idx).glbVars.glbUpInfoWired) && ...
                    ~isempty(models(idx).glbVars.glbUpInfoWired.upBlks) && ...
                    models(idx).glbVars.glbUpInfoWired.trigger_armed
                models(idx).glbVars = i_UserCheckData(models(idx).glbVars, models(idx).glbVars.glbUpInfoWired);
                models(idx).glbVars = feval(models(idx).glbVars.utilsFile.i_SendTerminate, models(idx).glbVars, models(idx).glbVars.glbUpInfoWired.index);
            end

            %
            % Handle floating blocks.
            %
            if ~isempty(models(idx).glbVars.glbUpInfoFloating) && ...
                    ~isempty(models(idx).glbVars.glbUpInfoFloating.upBlks) && ...
                    models(idx).glbVars.glbUpInfoFloating.trigger_armed
                models(idx).glbVars = i_UserCheckData(models(idx).glbVars, models(idx).glbVars.glbUpInfoFloating);
                models(idx).glbVars = feval(models(idx).glbVars.utilsFile.i_SendTerminate, models(idx).glbVars, models(idx).glbVars.glbUpInfoFloating.index);
            end

            %
            % Check if the target executable has terminated.
            %
            [models(idx).glbVars, status] = i_UserTargetStopped(models(idx).glbVars);
            if (status)
                i_SendStopResponse(models(idx).glbVars, 0);
            end
            
            %
            % Clear the flag to allow normal processing of commands.
            %
            models(idx).glbVars.glbCheckDataIsProcessing = 0;
        catch ME
            [models(idx).glbVars, status] = i_UserTargetStopped(models(idx).glbVars);
            if (status)
                i_SendStopResponse(models(idx).glbVars, 0);
            end
            
            models(idx).glbVars = i_ThrowError(models(idx).glbVars, action, ME.message);
            models(idx).glbVars.glbCheckDataIsProcessing = 0;
            return;
        end
        % case 'CheckData'

    otherwise,
        DAStudio.error('Simulink:tools:extModeOpenInvCommand');
        % otherwise
end

function glbVars = i_ThrowError(glbVars, action, err)
%
% If a try...catch statement fails, the error is thrown to the user
% via this function.
%

%
% Tag the error dlg box thrown by this function with a special tag so we
% can find it later.
%
specialTag = 'Targets_External_mode_Error';

%
% Are there any open error dlgs with the special tag, if yes close them so
% we enforce the new error box.
%
openErrDlgs = findall(0, 'Tag', specialTag);
for k = 1:length(openErrDlgs)
    delete(openErrDlgs(k));
end

%
% Display the new error.
%
errHandle = errordlg(DAStudio.message('Simulink:tools:extModeOpenGenericError', ...
                                      action, err), 'Error');

%
% Set the special tag.
%
set(errHandle, 'Tag', specialTag);

%
% Call the user defined error handler.
%
glbVars = i_UserHandleError(glbVars, action);

% end i_ThrowError

function i_SendConnectResponse(glbVars, status, checksum1, checksum2,...
    checksum3, checksum4, intCodeOnly, tgtStatus)
%
% Formats and sends the response to a 'Connect' action back to Simulink.
%
mat    = cell(1,7);
mat{1} = status;
mat{2} = checksum1;
mat{3} = checksum2;
mat{4} = checksum3;
mat{5} = checksum4;
mat{6} = intCodeOnly;
mat{7} = tgtStatus;
set_param(glbVars.glbModel,'ExtModeOpenProtocolConnectResponse',mat);

% end i_SendConnectResponse

function i_SendSetParamResponse(glbVars, status)
%
% Formats and sends the response to a 'SetParam' action back to Simulink.
%
set_param(glbVars.glbModel,'ExtModeOpenProtocolSetParamResponse',status);

% end i_SendSetParamResponse

function i_SendGetParamResponse(glbVars, status, params)
%
% Formats and sends the response to a 'GetParam' action back to Simulink.
%
mat    = cell(1,2);
mat{1} = status;
mat{2} = params;
set_param(glbVars.glbModel,'ExtModeOpenProtocolGetParamResponse',mat);

% end i_SendGetParamResponse

function i_SendSignalSelectResponse(glbVars, status, index)
%
% Formats and sends the response to a 'SignalSelect' or
% 'SignalSelectFloating' action back to Simulink.
%
mat    = cell(1,2);
mat{1} = status;
mat{2} = index;
set_param(glbVars.glbModel,'ExtModeOpenProtocolSignalSelectResponse',mat);

% end i_SendSignalSelectResponse

function i_SendTriggerSelectResponse(glbVars, status, index)
%
% Formats and sends the response to a 'TriggerSelect' or
% 'TriggerSelectFloating' action back to Simulink.
%
mat    = cell(1,2);
mat{1} = status;
mat{2} = index;
set_param(glbVars.glbModel,'ExtModeOpenProtocolTriggerSelectResponse',mat);

% end i_SendTriggerSelectResponse

function i_SendTriggerArmResponse(glbVars, status, index)
%
% Formats and sends the response to a 'TriggerArm' or
% 'TriggerArmFloating' action back to Simulink.
%
mat    = cell(1,2);
mat{1} = status;
mat{2} = index;
set_param(glbVars.glbModel,'ExtModeOpenProtocolArmTriggerResponse',mat);

% end i_SendTriggerArmResponse

function i_SendCancelLoggingResponse(glbVars, status, index)
%
% Formats and sends the response to a 'CancelLogging' or
% 'CancelLoggingFloating' action back to Simulink.
%
mat    = cell(1,2);
mat{1} = status;
mat{2} = index;
set_param(glbVars.glbModel,'ExtModeOpenProtocolCancelLoggingResponse',mat);

% end i_SendCancelLoggingResponse

function i_SendStartResponse(glbVars, status)
%
% Formats and sends the response to a 'Start' action back to Simulink.
%
set_param(glbVars.glbModel,'ExtModeOpenProtocolStartResponse',status);

% end i_SendStartResponse

function i_SendStopResponse(glbVars, status)
%
% Formats and sends the response to a 'Stop' action back to Simulink.
% Notifies Simulink about the target shutting down.
%
set_param(glbVars.glbModel,'ExtModeOpenProtocolShutdown',status);

% end i_SendStopResponse

function i_SendPauseResponse(glbVars, status)
%
% Formats and sends the response to a 'Pause' action back to Simulink.
%
set_param(glbVars.glbModel,'ExtModeOpenProtocolPauseResponse',status);

% end i_SendPauseResponse

function i_SendStepResponse(glbVars, status)
%
% Formats and sends the response to a 'Step' action back to Simulink.
%
set_param(glbVars.glbModel,'ExtModeOpenProtocolStepResponse',status);

% end i_SendStepResponse

function i_SendContinueResponse(glbVars, status)
%
% Formats and sends the response to a 'Continue' action back to Simulink.
%
set_param(glbVars.glbModel,'ExtModeOpenProtocolContinueResponse',status);

% end i_SendContinueResponse

function i_SendGetTimeResponse(glbVars, time)
%
% Formats and sends the response to a 'GetTime' action back to Simulink.
%
set_param(glbVars.glbModel,'ExtModeOpenProtocolGetTimeResponse',time);

% end i_SendGetTimeResponse

function i_SendDisconnectResponse(glbVars, status)
%
% Formats and sends the response to a 'Disconnect' action back to Simulink.
%
set_param(glbVars.glbModel,'ExtModeOpenProtocolDisconnectResponse',status);

% end i_SendDisconnectResponse

function messageQueue = i_ProcessMessageQueue(messageQueue)
%
% Any messages received from Simulink while the m-file is currently
% processing in CheckData will be stored in a queue.  When CheckData has
% finished, the messages in the queue are processed in a first-in-first-out
% manner.  In this way, CheckData becomes an atomic operation which can not
% be interrupted.
%
if ~isempty(messageQueue)
    messageQueueLen = length(messageQueue);
    for messageIdx=1:messageQueueLen
        message = messageQueue{messageIdx};
        argsStr = [];
        argsLen = length(message);
        for argIdx=1:argsLen
            argsStr = [argsStr 'message{' num2str(argIdx) '}'];
            if argIdx ~= argsLen
                argsStr = [argsStr ', '];
            end
        end
        messageStr = [mfilename '(' argsStr ');'];
        eval(messageStr);
    end
    messageQueue = [];
end
% end i_ProcessMessageQueue

function parsedUpBlks = i_ParseUpBlks(selectSigsMsg)
%
% Given the 'SignalSelect' message from Simulink, parse it into something
% more easily manageable by user code.
%
parsedUpBlks = cell(size(selectSigsMsg.UploadBlocks));

if ~isempty(selectSigsMsg.UploadBlocks)
    %
    % There may be any number of blocks uploading data back to
    % Simulink and each block can have any number of signals.
    % Handle each uploading block separately.
    %
    for nUpBlk=1:length(selectSigsMsg.UploadBlocks)
        parsedUpBlks{nUpBlk}.Name              = selectSigsMsg.UploadBlocks(nUpBlk).Name;
        parsedUpBlks{nUpBlk}.LogEventCompleted = false;
        
        %
        % Remove duplicate and unconnected source signals.
        %
        srcSignals = selectSigsMsg.UploadBlocks(nUpBlk).SrcSignals;
        str        = {};
        for i=1:length(srcSignals)
            blockPath   = srcSignals{i}.BlockPath;
            portIndex   = srcSignals{i}.PortIndex;
            unconnected = (strcmp(blockPath, '<unconnected>')) && (portIndex == -1);

            if (~unconnected)
                % Create a string uniquely identifying this source signal
                str{i} = [blockPath num2str(portIndex)];
            end
        end
        [unused uniqueIdx] = unique(str);

        %
        % Save the array of unique source signals for this uploading block.
        %
        parsedUpBlks{nUpBlk}.SrcSignals = cell(1,length(uniqueIdx));
        for i=1:length(uniqueIdx)
            parsedUpBlks{nUpBlk}.SrcSignals{i} = srcSignals{uniqueIdx(i)};
        end
        
        %
        % Remove duplicate and unconnected source dworks.
        %
        srcDWorks = selectSigsMsg.UploadBlocks(nUpBlk).SrcDWorks;
        str        = {};
        for i=1:length(srcDWorks)
            blockPath = srcDWorks{i}.BlockPath;
            dworkName = srcDWorks{i}.DWorkName;
            
            % Create a string uniquely identifying this source dwork
            str{i} = [blockPath dworkName];
        end
        [unused uniqueIdx] = unique(str);

        %
        % Save the array of unique source dworks for this uploading block.
        %
        parsedUpBlks{nUpBlk}.SrcDWorks = cell(1,length(uniqueIdx));
        for i=1:length(uniqueIdx)
            parsedUpBlks{nUpBlk}.SrcDWorks{i} = srcDWorks{uniqueIdx(i)};
        end
    end
end

% end i_ParseUpBlks

function glbVars = i_UserHandleError(glbVars, action)

glbVars = feval(glbVars.intrfFile.i_UserHandleError, glbVars, action);

% end i_UserHandleError

function glbVars = i_UserInit(glbVars)

glbVars = feval(glbVars.intrfFile.i_UserInit, glbVars);

% end i_UserInit

function [glbVars, status, checksum1, checksum2, checksum3, checksum4,...
    intCodeOnly, tgtStatus] = i_UserConnect(glbVars)

[glbVars, status, checksum1, checksum2, checksum3, checksum4, ...
    intCodeOnly, tgtStatus] = feval(glbVars.intrfFile.i_UserConnect, glbVars);

% end i_UserConnect

function [glbVars, status] = i_UserSetParam(glbVars, params)

[glbVars, status] = feval(glbVars.intrfFile.i_UserSetParam, glbVars, params);

% end i_UserSetParam

function [glbVars, status, params] = i_UserGetParam(glbVars)

[glbVars, status, params] = feval(glbVars.intrfFile.i_UserGetParam, glbVars);

% end i_UserGetParam

function [glbVars, status] = i_UserSignalSelect(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserSignalSelect, glbVars);

% end i_UserSignalSelect

function [glbVars, status] = i_UserSignalSelectFloating(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserSignalSelectFloating, glbVars);

% end i_UserSignalSelectFloating

function [glbVars, status] = i_UserTriggerSelect(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserTriggerSelect, glbVars);

% end i_UserTriggerSelect

function [glbVars, status] = i_UserTriggerSelectFloating(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserTriggerSelectFloating, glbVars);

% end i_UserTriggerSelectFloating

function [glbVars, status] = i_UserTriggerArm(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserTriggerArm, glbVars);

% end i_UserTriggerArm

function [glbVars, status] = i_UserTriggerArmFloating(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserTriggerArmFloating, glbVars);

% end i_UserTriggerArmFloating

function [glbVars, status] = i_UserCancelLogging(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserCancelLogging, glbVars);

% end i_UserCancelLogging

function [glbVars, status] = i_UserCancelLoggingFloating(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserCancelLoggingFloating, glbVars);

% end i_UserCancelLoggingFloating

function [glbVars, status] = i_UserStart(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserStart, glbVars);

% end i_UserStart

function [glbVars, status] = i_UserStop(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserStop, glbVars);

% end i_UserStop

function [glbVars, status] = i_UserPause(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserPause, glbVars);

% end i_UserPause

function [glbVars, status] = i_UserStep(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserStep, glbVars);

% end i_UserStep

function [glbVars, status] = i_UserContinue(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserContinue, glbVars);

% end i_UserContinue

function [glbVars, time] = i_UserGetTime(glbVars)

[glbVars, time] = feval(glbVars.intrfFile.i_UserGetTime, glbVars);

% end i_UserGetTime

function [glbVars, status] = i_UserDisconnect(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserDisconnect, glbVars);

% end i_UserDisconnect

function glbVars = i_UserDisconnectImmediate(glbVars)

glbVars = feval(glbVars.intrfFile.i_UserDisconnectImmediate, glbVars);

% end i_UserDisconnectImmediate

function glbVars = i_UserDisconnectConfirmed(glbVars)

glbVars= feval(glbVars.intrfFile.i_UserDisconnectConfirmed, glbVars);

% end i_UserDisconnectConfirmed

function [glbVars, status] = i_UserTargetStopped(glbVars)

[glbVars, status] = feval(glbVars.intrfFile.i_UserTargetStopped, glbVars);

% end i_UserTargetStopped

function glbVars = i_UserFinalUpload(glbVars)

glbVars = feval(glbVars.intrfFile.i_UserFinalUpload, glbVars);

% end i_UserFinalUpload

function glbVars = i_UserCheckData(glbVars, upInfo)

glbVars = feval(glbVars.intrfFile.i_UserCheckData, glbVars, upInfo);

% end i_UserCheckData
