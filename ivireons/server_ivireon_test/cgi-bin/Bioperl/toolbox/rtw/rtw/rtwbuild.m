function [varargout] = rtwbuild(sys, varargin)
%RTWBUILD - Invoke the RTW build procedure on a block diagram or a
%           subsystem
%
%   rtwbuild('model') will invoke the Real-Time Workshop build procedure
%   using the Real-Time Workshop configuration settings in the model to
%   create an executable from your model.
%
%   [blkH] = rtwbuild('subsystem') will invoke the Real-Time Workshop subsystem
%   build procedure using the Real-Time Workshop configuration settings in the
%   model.
%   It will return a non-empty block handle to an auto-generated
%   S-Function wrapper, if the selected target creates a S-Function block.
%
%   [blkH] = rtwbuild('subsystem','Mode','ExportFunctionCalls') will invoke the
%   Real-Time Workshop export function-calls from subsystem procedure.  It will
%   return a non-empty block handle to an auto-generated S-Function wrapper
%   block, if 'Create block' is set to 'SIL' in the Real-Time Workshop SIL and
%   PIL Verification pane of the Configuration Parameters dialog.
%    
%   [blkH] = rtwbuild('subsystem','Mode','ExportFunctionCalls','ExportFunctionFileName','fileName') 
%   will invoke the Real-Time Workshop export function-calls from subsystem procedure.
%   The argument 'ExportFunctionFileName' is used to specify the output file name.
%
%   Copyright 1994-2010 The MathWorks, Inc.
%   $Revision: 1.4.2.25 $

  % Check property name and value pairs
  if nargin < 1
      DAStudio.error('RTW:buildProcess:incorrectUsage');
  end
  % We want to check that the arguments starting from the second
  % appear in property-value pairs.  Currently, we are introducing
  % only the 'Mode' property, so we will not do a general check engine
  % at this time.  This algorithm needs to be extended as more properties
  % are added.

  % Setting up default
  buildMode = 'Normal'; % Assume
  pushNags  = false;
  blkH = [];
  storedChecksum = [];
  expFcnFileName = '';
  expFcnInitFcnName = '';
  
  nargs = nargin;
  if nargs > 1
      % Read in param-value pair
      pvPairsStartIdx = 1;
      nargs = nargs - 1;

      if (2*floor(nargs/2) ~= nargs)
          DAStudio.error('Simulink:utility:invalidArgPairing','rtwbuild');
      end
      nPairs = nargs/2;
      for i=0:(nPairs-1),
        pIdx = pvPairsStartIdx + 2*i;
        name = varargin{pIdx};
        val = varargin{pIdx+1};

        switch name
          case {'mode', 'Mode'}
            if ~strcmpi(val, 'normal') && ...
                    ~strcmpi(val, 'ExportFunctionCalls')
                DAStudio.error('RTW:buildProcess:incorrectUsageInvProp');
            end
            buildMode = val;

          case 'OkayToPushNags'
            if ~islogical(val)
                DAStudio.error('RTW:buildProcess:incorrectUsageInvProp');
            end
            pushNags = val;

          case 'StoredChecksum'
            storedChecksum = val;

          case 'ExportFunctionFileName'
            expFcnFileName = val;
                
          case 'ExportFunctionInitializeFunctionName'
            if ~iscvar(val)
                DAStudio.error('RTW:buildProcess:invalidInitializeFunctioName',val);
            end
            expFcnInitFcnName = val;
            
          otherwise
            DAStudio.error('RTW:buildProcess:incorrectUsageInvProp');
        end
      end
  end

  root = get_param(0, 'Object');
  if root.isValidSlObject(sys)
    sysType = get_param(sys, 'Type');
  else
    sysType = 'unknown';
  end
  mdlHdl = [];
  err = 0;
  isSubsysBuild = false;

  if strcmp(sysType, 'block') && ...
          strcmp(get_param(sys, 'BlockType'), 'SubSystem')

      isSubsysBuild = true;
      ssBlkH = get_param(sys, 'Handle');

      if pushNags
          slsfnagctlr('Clear', getfullname(ssBlkH), 'Subsystem build');
      end
      
      ss2mdlArgs = {'PushNags', pushNags};     
      
      % Determine if a SIL / PIL block is being generated 
      if rtwprivate('isCreateSILPILBlock', getActiveConfigSet(bdroot(ssBlkH)))
          ss2mdlArgs = [ss2mdlArgs 'SILPILBlock' true];
      end

      if strcmpi(buildMode, 'ExportFunctionCalls')
          if ecoderinstalled(bdroot(sys))

              load_system('simulink');
              load_system('expfcnlib');
              
              % Create SID Map (for Traceability)
              rtwprivate('rtwattic','createSIDMap');
              
              [mdlHdl, strPorts, err, mExc] = rtwprivate('ss2mdl', ssBlkH, ...
                                                         ss2mdlArgs{:}, ...
                                                         'ExportFunctions', 1, ...
                                                         'ExpFcnFileName',expFcnFileName,...
                                                         'ExpFcnInitFcnName',expFcnInitFcnName);
          else
              DAStudio.error('RTW:buildProcess:invalidSubsystemBuild');
          end
      else
          % Create SID Map (for Traceability)
          rtwprivate('rtwattic','createSIDMap');
          
          [mdlHdl, strPorts, err, mExc] = rtwprivate('ss2mdl', ssBlkH, ss2mdlArgs{:});
      end
      if err == 0 && ~isempty(mdlHdl)
          sys = get_param(mdlHdl, 'Name');
          set_param(0, 'CurrentSystem', sys);
          if ~rtwbuildutils('HasTargetVariableStepSolverSupport', mdlHdl)
            rtwbuildutils('SetSolverToFixStepSolver', mdlHdl);
          end
      else
          err = 1;
      end
  end

  if err == 0
      % Prevent undesired model autosaves with disable-and-restore
      % of autosave state
      old_autosave_state=get_param(0,'AutoSaveOptions');
      new_autosave_state=old_autosave_state;
      new_autosave_state.SaveOnModelUpdate=0;
      set_param(0,'AutoSaveOptions',new_autosave_state);
      try
          slbuild(sys, 'StandaloneRTWTarget', ...
                  'StoredChecksum', storedChecksum, ...
                  'OkayToPushNags', pushNags);
      catch mExc
          % Since there is no rethrow here, this restoration
          % of autosave state is redundant but harmless and is left
          % here in case someone adds a rethrow in the future.
          set_param(0,'AutoSaveOptions',old_autosave_state);
          err = 1;
          
          if pushNags
             rtwprivate('createAndPushNag',mExc, sys); 
          end
          
      end
      set_param(0,'AutoSaveOptions',old_autosave_state);
  end

  if root.isValidSlObject(mdlHdl)
      %
      % Save the new model name, so skrips can used rtwattic to determine
      % the code generation directory and files
      %
      rtwattic('setNewModelName', sys);
      if ~err
        %
        % Create the code node inforamtion and attach it to the parent model.
        %
        rtwbuildutils('SetupCodeNode', mdlHdl, ssBlkH);
      end
      %
      % Close the intermediate model once all the needed information have been
      % retrieved.
      %
      close_system(mdlHdl, 0);
  end

  % Delete SID Map
  rtwprivate('rtwattic','deleteSIDMap');
    
  if err
      if pushNags
          slsfnagctlr('View');
      end

      if isSubsysBuild
          newMsg = regexprep(mExc.message, ['''', sys, '/'], ...
                             ['''',get_param(ssBlkH,'Parent'),'/']);
          
          newExc = MException(mExc.identifier, '%s', newMsg);
          if ~isempty(mExc.cause)
              newExc = newExc.addCause(mExc.cause{1});
          end
          throw(newExc);
      else
          rethrow(mExc);
      end
  elseif isSubsysBuild
    %
    % Do post-processing of generated S-Function (early return if not found)
    %
    try
      blkH = rtwprivate('ssgensfunpost', sys, ssBlkH, strPorts);
    catch exc %#ok
      % User may have chosen not to create a new model.
      return;
    end
  end
  if nargout > 0
    varargout{1} = blkH;
  end

%endfunction rtwbuild

%[eof] rtwbuild.m
