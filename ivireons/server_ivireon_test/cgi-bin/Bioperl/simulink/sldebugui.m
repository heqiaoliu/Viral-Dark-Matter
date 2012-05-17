function varargout = sldebugui(varargin)
% SLDEBUGUI creates and manages the graphical Simulink debugger

%   Copyright 1990-2007 The MathWorks, Inc.
%   $Revision: 1.8.2.12 $
%   Sanjai Singh 01-26-00

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define PERSISTENT variables that track the state of the Debugger %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  persistent DEBUGGER_HANDLE;
  persistent MODEL_HANDLE;
  persistent MODEL_NAME;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Lock the file to prevent tampering %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  mlock

  %%%%%%%%%%%%%%%%%%%%%%%%%
  %% Determine arguments %%
  %%%%%%%%%%%%%%%%%%%%%%%%%
  error(nargchk(1, 2, nargin));
  Action = varargin{1};

  %%%%%%%%%%%%%%%%%%%%
  %% Process Action %%
  %%%%%%%%%%%%%%%%%%%%
  switch (Action)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Create Debugger if needed or make it visible %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'Create'

    % Test for existence of java
    if ~usejava('MWT')
      DAStudio.error('Simulink:tools:slDebuguiRequiresJava');
    end

    model = varargin{2};
    if (strcmp(get_param(0,'SlDebugEnable'),'on'))
      if (isempty(DEBUGGER_HANDLE))
        if isempty(find_system('type','blockdiagram','Name',model))
          load_system(model);
        end

        DEBUGGER_HANDLE = com.mathworks.toolbox.simulink.debugger.SimDebugger.CreateSimulinkDebugger(model);
        MODEL_HANDLE    = get_param(model, 'Handle');
        MODEL_NAME      = get_param(model, 'Name');
      else
        frame = DEBUGGER_HANDLE.getParent;
        awtinvoke(frame,'show()');
        name = get_param(MODEL_HANDLE, 'Name');
        if ~strcmp(model, name)
          errordlg(DAStudio.message('Simulink:tools:slDebuguiInUse',name,model));
        end
      end
    else
          DAStudio.warning('Simulink:tools:NoSLDebugWithTLCDebug');
    end

    %%%%%%%%%%%%%%%%%%%%
    %% Start Debugger %%
    %%%%%%%%%%%%%%%%%%%%
   case 'Start'
    frame = DEBUGGER_HANDLE.getParent;
    if isempty(find_system('type','block_diagram','Name',MODEL_NAME))
      load_system(MODEL_NAME);
      MODEL_HANDLE = get_param(MODEL_NAME, 'Handle');
    end
    name  = get_param(MODEL_NAME, 'Name');
    DEBUGGER_HANDLE.updateWindowTitle(frame,name);
    origVB = warning('query','verbose');
    origBT = warning('query','backtrace');
    warning('off','verbose');
    warning('off','backtrace');
    sldebug(name)
    warning(origBT);
    warning(origVB);
    
    %%%%%%%%%%%%%%%%%%%%
    %% Close Debugger %%
    %%%%%%%%%%%%%%%%%%%%
   case 'Close'
    frame = DEBUGGER_HANDLE.getParent;
    DEBUGGER_HANDLE = [];
    MODEL_HANDLE    = -1;
    awtinvoke(frame,'dispose()');

    %%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get Debugger Handle %%
    %%%%%%%%%%%%%%%%%%%%%%%%%
   case 'GetHandle'
    varargout{1} = DEBUGGER_HANDLE;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get current block if not virtual %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'GetCurrentBlock'
    blk = gcb;
    msg = '';
    if isempty(blk)
        msg = DAStudio.message('Simulink:tools:slDebugCurrentBlockIsEmpty', ...
                               MODEL_NAME);
    elseif ~isequal(bdroot(blk), MODEL_NAME)
        msg = DAStudio.message('Simulink:tools:slDebugCurrentBlockNotInModel', ...
                               strrep(getfullname(blk), sprintf('\n'), ' '), ...
                               MODEL_NAME);
    elseif isequal(get_param(blk, 'Virtual'), 'on')
        msg = DAStudio.message('Simulink:tools:slDebugBreakpointSetOnVirtualBlock', ...
                               strrep(getfullname(blk), sprintf('\n'), ' '), ...
                               MODEL_NAME);
    end
    if isempty(msg)
        blk = strrep(getfullname(blk), sprintf('\n'), ' ');
    else
        errordlg(msg);
        blk = '';
    end
    varargout{1} = blk;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get simulation state of the model %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'GetModelState'
    state = get_param(MODEL_HANDLE, 'SimulationStatus');
    varargout{1} = state;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get top level stack data %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'GetTopLevelStackData'
    topstack = feature('sldebug', get_param(MODEL_HANDLE, 'Name'), 'stack');
    varargout{1} = i_ConvertStackToObject(topstack, 0);

    %%%%%%%%%%%%%%%%%%%%
    %% Get stack data %%
    %%%%%%%%%%%%%%%%%%%%
   case 'GetStackData'
    indices = varargin{2};
    indices = double([indices{:}]);

    stack = feature('sldebug', get_param(MODEL_HANDLE, 'Name'), 'stack', indices);
    varargout{1} = i_ConvertStackToObject(stack, indices);

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Refresh entire stack %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'RefreshStack'
    if ~isempty(DEBUGGER_HANDLE)
      DEBUGGER_HANDLE.refreshStack;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get break points set via "break gcb" %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'GetBlockBreakPoints'
    fullnames = {};
    bPoints   = feature('sldebug', get_param(MODEL_HANDLE, 'Name'), 'breakpoints');
    if ~isempty(bPoints) && isstruct(bPoints)
      blockPoints = bPoints(find([bPoints.nodeIndex] == -1));
      if ~isempty(blockPoints)
        fullnames = getfullname([blockPoints.handle]);
      end
    end
    varargout{1} = fullnames;

   case 'IsPauseRequested'
    varargout{1} = DEBUGGER_HANDLE.querySimulationPause;
   case 'GetAnimationDelay'
    varargout{1} = DEBUGGER_HANDLE.queryAnimationDelay;
  end

%%
% Local function to convert the stack data structure to an object to send
% to java
%%
function object = i_ConvertStackToObject(stack, indices)

  object = {};
  for i = 1:length(stack)
    isBlock = double(strcmp(get_param(stack(i).handle, 'Type'), 'block'));
    object{i} = com.mathworks.toolbox.simulink.debugger.StackObject(...
        stack(i).name, stack(i).handle, stack(i).status, ...
        stack(i).breakOnEntry, indices(i), stack(i).childNodeIndices, isBlock);
  end
