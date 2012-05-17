function [success,mdlRefBlkH] = convertToModelReference(subsys,mdlRef,varargin)
% Simulink.SubSystem.convertToModelReference converts a subsystem to model
% reference.
%   
% Simulink.SubSystem.convertToModelReference converts an atomic, function-call,
% or triggered subsystem to a referenced model.  It works by creating a new
% model, copying the contents of the subsystem into the model, and reconfiguring
% the root level Inport, Outport and Trigger blocks and configuration parameters
% of the model to match the compiled attributes of the original subsystem.
% During the conversion, the contents of the Model workspace of the original
% model are copied over to the new model.
%
% Note: 
% This function works only for models and subsystems that meet 
% specific conditions. It produces error or warning messages for models and
% subsystems that it cannot handle. Your model must have the following 
% configuration parameter settings:
% 
%  (1) Optimization section, "Inline parameters" must be on.
%  (2) Diagnostics/"Data Validity" section, "Signal resolution" must be 
%      "Explicit only".
%  (3) Diagnostics/Connectivity section, Buses/"Mux blocks used to create 
%      bus signals" must be "error".
%    
% The above parameters can be set via command line as follows:
%  set_param(mdlName, 'InlineParams', 'on');
%  set_param(mdlName, 'SignalResolutionControl', 'UseLocalSettings');
%  set_param(mdlName, 'StrictBusMsg', 'ErrorLevel1');
%
% Further, in the cases where conversion is successful, you may need to 
% reconfigure the resulting model to meet your requirements. See the online 
% documentation for this function for more information. 
% 
% Usage:
%  [success,mdlRefBlkH] = Simulink.SubSystem.convertToModelReference(...
%                                               subsys, mdlRef, 'Param1', Val1, ...)
%
% Inputs:
%     subsys: Full name or handle of an atomic or function-call Subsystem block
%     mdlRef: Name of a new model
%     Param1, Val1: Optional name/value pairs where legal names and values are:
% 
%       ReplaceSubsystem: true or false (default is false). If it is true,
%       this function replaces the subsystem block with a Model block that
%       references the model created from the subsystem. If it is false, a
%       temporary model is created and opened that contains a Model block that
%       references the model derived from the subsystem block.
%
%       BusSaveFormat: This parameter can be 'Cell' or 'Object'.
%       If this parameter is specified, the function saves the created bus 
%       objects in a 'Cell' or 'Object' format in a MATLAB file.  Use the 
%       'Cell' format to save the objects in the compact form. If this 
%       parameter is not specified, the bus objects are not saved. 
%
%       BuildTarget: This parameter can be 'Sim' or 'RTW'.
%       If it is specified, the function generates a model reference Sim 
%       or RTW target for the new model. The function sets any
%       configuration options needed to generate the targets. If this parameter 
%       is not specified, no model reference target is generated.
%
%       Force: true or false (default is false). If this parameter is true, this
%       function reports some errors that would halt the conversion process as
%       warnings and continue with the conversion. This option allows you to use
%       this function to do the initial steps of conversion and then complete
%       the conversion process yourself.
%                     
%  Outputs:
%    success:    It is true if this function is successful. Otherwise, 
%                it is false.
%    mdlRefBlkH: Handle to the newly created Model block.
%      
%  Note: 
%    Because it is difficult to undo the changes when ReplaceSubsystem is true,
%    you should make a backup copy of your model before using this function.

    
%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.26 $

  success    = false; %#ok
  mdlRefBlkH = -1;
  
  if nargin < 2
    msgId = [msgIdPref_l, 'InvalidNumInputs'];
    msg   = xlate(['Invalid usage of convertToModelReference. ', ...
             'Two or more inputs are expected.']);
    handle_diagnostic_l('error', msgId, msg);
  end

  nargs = nargin-2; % length of varargin
  nPairs = nargs;
  if (2*floor(nPairs/2) ~= nPairs)
    msgId = [msgIdPref_l, 'InvalidNumNameValuePair'];
    msg = xlate(['Invalid usage of convertToModelReference. ', ...
           'Property names and values must come in pairs.']);
    handle_diagnostic_l('error', msgId, msg);
  end
  nPairs = nPairs/2;

  args = loc_get_default_args_l;
  
  for i=0:(nPairs-1),
    pIdx = 2*i;
    name = varargin{pIdx+1};
    val  = varargin{pIdx+2};
    
    switch(name)
      % Should the subsystem be replaced with the new Model block or not
     case {'ReplaceSubsystem'}
      if ~islogical(val)
        msgId = [msgIdPref_l, 'ReplaceSubsystem'];
        msg   = xlate(['Invalid value for ReplaceSubsystem parameter. ', ...
                 'ReplaceSubsystem parameter value must be a ', ...
                 'logical value, i.e., true/false.']);
        handle_diagnostic_l('error', msgId, msg);
      end
      args.ReplaceSubsystem = val;

      % Save bus objects with the specified format
     case  {'BusSaveFormat'}
      args.BusSaveFormat = val;
      
      % Build Model reference Sim or RTW target
     case {'BuildTarget'}
      if ~(ischar(val) && (strcmp(val,'Sim') || strcmp(val,'RTW')))
        msgId = [msgIdPref_l, 'BuildTarget'];
        msg   = xlate(['Invalid value for BuildTarget parameter.  BuildTarget ', ...
                 'must be  ''Sim'' or ''RTW''.']);
        handle_diagnostic_l('error', msgId, msg);
      end
      args.BuildTarget = val;
      
      case {'Force'}
       if ~(islogical(val) || isequal(val,'controlFromUI'))
           msgId = [msgIdPref_l, 'Force'];
           msg   = xlate(['Invalid value for ''Force'' parameter. ', ...
                    'This parameter must be a logical value, i.e., true/false.']);
           handle_diagnostic_l('error', msgId, msg);
       end
       
       if islogical(val) 
           if val
               args.Force = 'on';
           else
               args.Force = 'off';
           end
       else
           args.Force = val;
       end
       
     case{'ErrorOnly'}
       if ~islogical(val) 
           msgId = [msgIdPref_l, 'ErrorOnly'];
           msg   = xlate(['Invalid value for ''ErrorOnly'' parameter. ', ...
                    'This parameter must be a logical value, i.e., true/false.']);
           handle_diagnostic_l('error', msgId, msg);
       end
       if val
          args.ErrorOnly = true; 
          args.ReplaceSubsystem = false;
          args.Force = 'on';
          args.BuildTarget = '';
          args.BusSaveFormat = '';
       else
          args.ErrorOnly = false;
       end
       
     otherwise
      msgId = [msgIdPref_l, 'InvalidInputArgument'];
      msg   = sprintf('Invalid input argument: %s .',name);
      handle_diagnostic_l('error', msgId, msg);
    end
  end

  % Init diagnostic (warning/error). This helps us not to pass this flag
  % to all functions
  diagnostic_value_l(true, args.Force);
  
  % do not disp backtraces when reporting warning
  wStates = [warning; warning('query','backtrace')];
  warning off backtrace;

  mdl = '';
  try
    check_subsys_and_mdlref_l(subsys, mdlRef);
    mdl = bdroot(subsys);
    if ishandle(mdl)
        mdl = get_param(bdroot(subsys), 'name');
    end
    
    busNames = create_model_from_subsystem_l(mdl, subsys, mdlRef, args.ErrorOnly);
    
    % Build model reference target if necessary
    if ~isempty(args.BuildTarget)
      build_model_reference_target_l(mdlRef, args.BuildTarget)
    end
    
    % Save bus objects if necessary
    if ~isempty(args.BusSaveFormat)
      busFileName = [mdlRef, '_bus'];
      Simulink.Bus.save(busFileName, args.BusSaveFormat, busNames);
    end
  
    % Either replace the subsystem with a Model block or create a new model
    % with a new Model block referencing mdlRef
    if ~args.ErrorOnly
        mdlRefBlkH = create_model_block_l(subsys, mdlRef, args.ReplaceSubsystem);
    end
    
  catch myException
    cleanup_l(wStates, mdl);
    rethrow(myException);
  end
  
  success    = true;
  if ~args.ErrorOnly
      dispWithPrefix_l(DAStudio.message('Simulink:modelReference:successfullyConvertedSubsystem'));
  end
  cleanup_l(wStates, mdl);
end % convertToModelReference


% Function: cleanup_l ====================================================
% Abstract:
%    Reset the warning states, and end the compilation in the case of error.
function cleanup_l(wStates, mdl)
    warning(wStates);
    if ~isempty(mdl)
      simStatus = get_param(mdl,'SimulationStatus');
      if ~strcmpi(simStatus, 'stopped')
        cmd = [mdl,'([],[],[],''term'')'];
        evalc(cmd);
      end
    end
end % cleanup_l


% Function:  handle_diagnostic_l ==============================================
% This is a helper function for handling diagnostics. Report a diagnostic, 
% error or warning.
% 
function handle_diagnostic_l(diagOpt, strId, strMsg)
    if strcmpi(diagOpt, 'diag') && strcmp(diagnostic_value_l(false, ''),'controlFromUI')
        % We are controlling the diagnostic from UI
        response =  sl('slss2mdl_util', 'get_question_dialog_response_l',strMsg);

        if (isempty(response) || strcmp(response, 'Stop'))
            diagnostic_value_l(true, 'off');
        else
            diagnostic_value_l(true, 'on');
        end
    end
    
    switch diagOpt
      case 'diag'
        % Get the diagnostic value
        if strcmpi(diagnostic_value_l(false, ''),'on')
            warning(strId, strMsg);
        else
            error(strId, strMsg);
        end
        
      case 'warning'
        warning(strId, strMsg);
        
      case 'error'
        % Update the last error string.
        sl('slss2mdl_util', 'handleLastErrorString_l',true, strMsg);
        error(strId, strMsg);
      otherwise
        assert(false, 'Unexpected diagnostic value');
    end
end % handle_diagnostic_l


% Function: diagnostic_value_l ================================================
% Abstract:
%      Helper function to cache and get the diagnostic value.
%      true:  report warning (force error to be reported as warning)
%      false: report error
%
function diag = diagnostic_value_l(isInit, val)
  persistent diagnostic_value_persistent_l
  if isInit
    diagnostic_value_persistent_l = val;
  end
  diag = diagnostic_value_persistent_l;
end % diagnostic_value_l   


% Function: create_model_from_subsystem_l =====================================
% Abstract:
%    Given a subsystem block(subsys) in model (mdl) create a 
%    new model(mdlRef), and setup the configSet and root inport/outport 
%    attributes of the new model.
%    
function busNames = create_model_from_subsystem_l(mdl, subsys, mdlRef, isErrorOnly)

  subsysH = get_param(subsys,'Handle');

  % In order to get bus objects, before compiling the model, we need to 
  % set CacheCompiledBusStruct parameter for I/O of the subsystem block.

  ssPortBlocks = get_system_port_blocks_l(subsysH);
  ssInBlkHs = ssPortBlocks.inportBlksH;
  ssOutBlkHs = ssPortBlocks.outportBlksH;
  
  ssPortBlkPortHs = set_cache_compiled_bus_l(ssPortBlocks, subsysH);
    
  evalc('feval(mdl,[],[],[],''compileForSizes'');');
  
  % Report an error if the subsystem cannot be converted
  check_subsystem_after_compilation_l(subsysH, ssInBlkHs, ssOutBlkHs);
  
  busListBefore = get_bus_names_in_base_workspace_l();
  
  % Generate bus object and make sure bus object sample times are correct.
  % Also cache compiled Inport/Outport block attributes.
  compIOInfo = gen_bus_object_and_cache_comp_IO_info_l(mdl,ssPortBlocks,ssPortBlkPortHs);
  busListAfter = get_bus_names_in_base_workspace_l();
  busNames = setdiff(busListAfter, busListBefore);

  % Create a model and set model IO attributes.
  create_model_l(subsys, mdl, mdlRef);
  set_IO_attributes_l(compIOInfo, subsys, mdlRef);
  
  evalc('feval(mdl,[],[],[],''term'');');
  
  if isErrorOnly
      close_system(mdlRef, 0);
  else
      save_system(mdlRef);
  end
end % create_model_from_subsystem_l  


% Function: create_model_l ====================================================
% Abstract:
%   Create a new model using the subsystem block and setup new model configSet.
function create_model_l(subsys, mdl, mdlRef)
    subsysH = get_param(subsys,'Handle');
    mdlH    = get_param(mdl, 'Handle');
  
    mdlRefH = new_system(mdlRef,'Model', subsys);
    % The above function does not set the location of graph properly
    ssLocation = get_param(subsys, 'Location');
    set_param(mdlRef,  'Location', ssLocation);

    sl('slss2mdl_util', 'configure_configset', subsysH, mdlH, mdlRefH);
    sl('slss2mdl_util', 'copy_model_workspace', mdlH, mdlRefH);
    
    set_param(mdlRef, 'ZoomFactor', get_param(subsys, 'ZoomFactor'));        
end % create_model_l



% Function: get_system_port_blocks_l ==========================================
% Abstract:
%   Return a structure containing subsystem Inport, Outport and trigger blocks.
%
function sysPortBlocks = get_system_port_blocks_l(sysH)
  
  sysPortBlocks.inportBlksH = [];
  sysPortBlocks.outportBlksH = [];
  sysPortBlocks.triggerBlkH = [];
  
  sysPortBlocks.inportBlksH = find_system(sysH, ...
                                          'SearchDepth',1,...
                                          'FollowLinks','on',...  
                                          'LookUnderMasks','graphical', ...
                                          'BlockType','Inport');
  
  sysPortBlocks.outportBlksH = find_system(sysH, ...
                                          'SearchDepth',1,...
                                          'FollowLinks','on',...  
                                          'LookUnderMasks','graphical', ...
                                          'BlockType','Outport');
  
  sysPortBlocks.triggerBlkH = find_system(sysH, ...
                                          'SearchDepth',1,...
                                          'FollowLinks','on',...  
                                          'LookUnderMasks','graphical', ...
                                          'BlockType','TriggerPort');

  assert(isempty(sysPortBlocks.triggerBlkH) || ...
         length(sysPortBlocks.triggerBlkH) == 1);
         
  % Filter out function-call ports
  if (~isempty(sysPortBlocks.triggerBlkH) && ...
      strcmp(get_param(sysPortBlocks.triggerBlkH, 'TriggerType'), 'function-call'))
    sysPortBlocks.triggerBlkH = [];
  end
end % get_system_port_blocks_l

% Function: set_cache_compiled_bus_l ==========================================
% Abstract:
%    Before getting compiled port information, we need to set 
%    CacheCompiledBusStruct on the subsystem Inport and Outport blocks.
%
%    ssPortBlkPortHs is a vector containing 
%      - output port handle of subsystem inport blocks and
%      - input port handle of subsystem outport blocks
%      - trigger port handle of subsystem
function ssPortBlkPortHs = set_cache_compiled_bus_l(ssPortBlocks, subsysH)
  
  bh = [ssPortBlocks.inportBlksH; ssPortBlocks.outportBlksH];
  ssPortBlkPortHs = [];
  for idx = 1 : length(bh)
    bType     = get_param(bh(idx), 'BlockType');
    bpHandles = get_param(bh(idx), 'porthandles');
    
    if strcmpi(bType,'Inport')
      ph = bpHandles.Outport;
    else 
      ph = bpHandles.Inport;
    end

    set_param(ph,'CacheCompiledBusStruct','on');
    ssPortBlkPortHs(end+1) = ph;
  end
  
  if ~isempty(ssPortBlocks.triggerBlkH)
    subsysPH = get_param(subsysH, 'PortHandles');
    ssPortBlkPortHs(end+1) = subsysPH.Trigger;
  end
end % set_cache_compiled_bus_l

% Function: get_compiled_bus_l =================================================
% Abstract:
%   Return a structure containing:
%     - subsystem Inport, Outport, and Trigger blocks, 
%     - subsystem Inport and Outport block ports, and subsystem trigger port
%     - compiled bus information
function busInfo = get_compiled_bus_l(ssPortStruct, portHandles)
  busInfo = [];
  ssPortBlks = [ssPortStruct.inportBlksH; ssPortStruct.outportBlksH; ...
                ssPortStruct.triggerBlkH];
  for idx = 1: length(ssPortBlks)
    busInfo(idx).block = ssPortBlks(idx);
    busInfo(idx).port  = portHandles(idx);
    busInfo(idx).bus = get_param(portHandles(idx),'CompiledBusStruct');
  end
end % get_compiled_bus_l

% Function: get_sample_time_from_bus_l =========================================
% Abstract:
%    This function returns two values: mixed, ts
%     - mixed is true if the bus signal has mixed sample time. In this case,
%       ts does not have any information (ts = -1).
%     - If mixed is false, ts contains the bus sample time.
%
%    Note: Since this function is recursive, I used ts = -1, for the
%          initial value.
%
function [mixed, ts] = get_sample_time_from_bus_l(busName, ts)
  
  mixed  = false;
  busObj = sl('slbus_get_object_from_name', busName, true);
  
  for idx = 1:length(busObj.Elements)
    busElm = busObj.Elements(idx);
    dtypeIsABus = ~isempty(sl('slbus_get_object_from_name', ...
                              busElm.DataType, false));
    
    if dtypeIsABus
      [mixed, ts] = get_sample_time_from_bus_l(busElm.DataType, ts);
      if mixed, 
        return; 
      end
    else
      % Possibilities [ts ,elm]: (x and y are non-inherited sample time)
      % [-1, x], [-1, -1]    ----> newTs = elm
      % [x, -1], [x, x]      ----> newTs = ts (no change)
      % [x, y]               ----> mixed
      if ts == -1 % Initital Value
        ts =  busElm.SampleTime;
      else
        % ts is not -1
        if ~isequal(busElm.SampleTime, -1) && ~isequal(busElm.SampleTime, ts)
          mixed = true;
          ts    = -1;
          return;
        end
      end
    end
  end
end % get_sample_time_from_bus_l


% Function:  gen_bus_object_and_cache_comp_IO_info_l ========================
% Abstract:
%   Generate bus objects. Make sure bus object sample times are correct. Cache
%   compiled port attributes in the output structure.
%
function compIOInfo = gen_bus_object_and_cache_comp_IO_info_l(mdl, ...
                                                    ssPortBlks, ssPortBlkPortHs)
  
  compIOInfo = get_compiled_bus_l(ssPortBlks, ssPortBlkPortHs);
  
  % Get initial list of bus creators with inferred bus objects via bus object
  % back propagation from blocks with specified bus objects.
  bclist = get_param(mdl, 'BackPropagatedBusObjects');
  compIOInfo = sl('slbus_gen_object', compIOInfo, false, bclist);
  
  % Check bus sample times
  for idx = 1:length(compIOInfo)
    busName  = compIOInfo(idx).busName;
    % Cache attributes. set_IO_attributes_l will use them.
    compIOInfo(idx).portAttributes = sl('slport_get_compiled_info', ...
                                      compIOInfo(idx).port);
    if ~isempty(busName)
      [mixed, busSampleTime] = get_sample_time_from_bus_l(busName, -1);

      blk = compIOInfo(idx).block;
      blkType = get_param(blk,'BlockType');
      portNumber = get_param(blk, 'Port');
      
      if mixed
        msgId = [msgIdPref_l, 'BusWithMixedSampleTimes'];
        msg   = sprintf(...
            ['Invalid bus element sample time. Cannot use bus object ', ...
             '''%s'' for %s block (%s) in the new model. This bus object ', ...
             'has elements with different sample times. In order to ', ...
             'convert a subsystem to a model, all bus element sample ', ...
             'times must be the same or they must be inherited (-1).'], ...
            busName, blkType, portNumber);
        handle_diagnostic_l('error', msgId, msg);
      else
        if compIOInfo(idx).portAttributes.IsTriggered && ...
              ~isequal(busSampleTime, -1)
          msgId = [msgIdPref_l, 'BusWithKnownTsInTriggerSS'];
          msg   = sprintf(...
              ['Invalid bus element sample time. Bus object ''%s'' has ', ...
               'non-inherited sample time elements (or sub-elements). ', ...
               'Cannot use this bus object for %s block (%s) in the new ', ...
               'model. Since the new model must be configured to be sample ', ...
               'time independent, all bus element sample times must be ', ...
               'specified as inherited (-1).'], busName, blkType, portNumber);
          handle_diagnostic_l('error', msgId, msg);
        end
      end
    end
  end
end % gen_bus_object_and_cache_comp_IO_info_l

% Function: set_sample_time_l =================================================
% Abstract:
%    Helper function to set the sample time on a port
function set_sample_time_l(sampTimeInd, portInfo, srcBlock, dstBlock)

% Set sample time unless it is one of the following:
%  1. the sample time is triggered
%  2. the model is sample time independent
%  3. the sample time is constant
%  4. the sample time has a negative offset.
  if (~portInfo.IsTriggered && ...
      ~sampTimeInd && ...
      ~(length(portInfo.SampleTime) == 1 && isinf(portInfo.SampleTime)) && ...
      ~(length(portInfo.SampleTime) == 2 && portInfo.SampleTime(2) < 0))
    
    % If the sample time is inherited, or we are setting for the
    % trigger port, use the compiled time sample time.
    % Otherwise, use the value that the user used
    if strcmpi(get_param(srcBlock,'BlockType'), 'TriggerPort')
      sampleTimeParameter = 'TriggerSignalSampleTime';
      isTriggerPort = true;
    else 
      sampleTimeParameter = 'SampleTime';
      isTriggerPort = false;
    end
    
    if(isTriggerPort || ...
       isequal(get_param(srcBlock, 'HasInheritedSampleTime'), 'on'))
      % The sample time is inherited.  Use compiled value
      set_param(dstBlock, sampleTimeParameter, portInfo.SampleTimeStr);
    else
      set_param(dstBlock, sampleTimeParameter, ...
                    get_param(srcBlock, 'SampleTime'));
    end % if
  end
end



% Function: set_IO_attributes_l ================================================
% Abstract:
%   Set mdlRef Compiled Inport, Outport, and Trigger block attributes.
%
function set_IO_attributes_l(compIOInfo, subsys, mdlRef)
  
  mdlRefH = get_param(mdlRef, 'Handle');
  origMdl = bdroot(subsys);

  % Check if the original model is sample time independent
  solverType = get_param(origMdl, 'SolverType');
  sampTimeInd = 0;
  if strcmp(solverType, 'Fixed-step')
    sampTimeInd = strcmp(get_param(origMdl,'SampleTimeConstraint'),...
                         'STIndependent');
  end
  
  mdlRefPortBlkHs = get_system_port_blocks_l(mdlRefH);
  
  blks = [mdlRefPortBlkHs.inportBlksH; mdlRefPortBlkHs.outportBlksH];
 
  % If the compIOInfo is empty, we can just return.  This means we
  % have no information to set on the port, such as in a masked system.
  if isempty(compIOInfo) 
      return;
  end
      
  for idx = 1:length(blks)
    blk      = blks(idx);
    busName  = compIOInfo(idx).busName;
    portInfo = compIOInfo(idx).portAttributes;
    
    if ~isempty(busName)
      useBusObject = get_param(blk, 'UseBusObject');

      if ~strcmpi(useBusObject,'on')
        set_param(blk, 'UseBusObject','on');
        set_param(blk, 'BusObject', busName);
        % else - if this information is specified on the dialog, honor it
      end
      % Always set the BusOutputAsStruct. Note that this parameter is 
      % disabled for subsystem Inport blocks.
      if portInfo.IsStructBus
        set_param(blk,'BusOutputAsStruct', 'on'); 
      else
        set_param(blk,'BusOutputAsStruct', 'off'); 
      end
      
      % Set Inport/Outport dimensions for arrays of buses
      if slfeature('ArraysOfBuses') && portInfo.IsStructBus
          set_param(blk,'PortDimensions',portInfo.DimensionStr);
      end
    else
      sl('slss2mdl_util', 'set_compiled_data_type', blk, ...
         portInfo.DataType, ...
         portInfo.AliasThruDataType);
      
      set_param(blk,'PortDimensions',portInfo.DimensionStr);
      
      set_param(blk,'SignalType', portInfo.Complexity);
      set_param(blk,'SamplingMode', portInfo.SamplingMode);
      
    end

    set_sample_time_l(sampTimeInd, portInfo, compIOInfo(idx).block, blk);
    
    % Specifiy block labels
    if idx <= length(mdlRefPortBlkHs.inportBlksH)
      % This is an input port
      setup_inport_block_label_l(subsys, idx, compIOInfo(idx).block, blk);
    else
      % this is an output port
      setup_outport_block_label_l(compIOInfo(idx).block, blk);
    end
   
    % Specifiy storage class
    if idx <= length(mdlRefPortBlkHs.inportBlksH);
        % This is an input port
        tmpPortHs = get_param(blk,'PortHandles');
        tmpSrcPortH = tmpPortHs.Outport;
    else
        % This is an output port
        tmpSrcPortH = get_outport_block_graphical_src_l(blk);
    end
    sl('slss2mdl_util','set_outport_rtw_storage_class',tmpSrcPortH, portInfo);
  end    

  % For the trigger port, we only need to set:
  %   sample time
  %   port dimensions
  %   data type
  % The compIOInfo could be empty because the system has a 
  % masked workspace.
  if ~isempty(mdlRefPortBlkHs.triggerBlkH)
    triggerBlk = mdlRefPortBlkHs.triggerBlkH;
    portInfo = compIOInfo(end).portAttributes;
    
    sl('slss2mdl_util', 'set_compiled_data_type', ...
       triggerBlk, ...
       portInfo.DataType, ...
       portInfo.AliasThruDataType);
    
    set_param(triggerBlk,'PortDimensions',portInfo.DimensionStr);

    set_sample_time_l(sampTimeInd, portInfo, compIOInfo(end).block, triggerBlk)
  end

end % set_IO_attributes_l




% Function: check_subsys_and_mdlref_l =========================================
% Abstract:
%    Check subsys and mdlRef inputs, and report error for invalid 
%    subsystem and invalid mdlRef name.
%    
function check_subsys_and_mdlref_l(subsys, mdlRef)
  % subsys must be a subsystem blocks.
  isSubsys = strcmpi(get_param(subsys,'type'), 'block') && ...
      strcmpi(get_param(subsys,'blocktype'), 'Subsystem');
  if ~isSubsys
    msgId = [msgIdPref_l, 'InvalidSubsystemBlock'];
    msg = sl('slss2mdl_util','getFirstArgDiagnosticMessage');
    handle_diagnostic_l('error', msgId, msg);
  end
  
  
  subsysObj = get_param(subsys,'object');
  if subsysObj.hasLinkToADirtyLibrary
      subsysName = get_param(subsys, 'Name');
      msgId = [msgIdPref_l, 'SubsystemHasLinkToADirtyLibrary'];
      msg   = sprintf(['Subsystem ''%s'' is linked to a library with unsaved ', ...
                       'changes. Please save the library before converting ', ...
                       'the subsystem to a model.'], subsysName);
      handle_diagnostic_l('error', msgId, msg);
  end
  % Force library links to be re-instantidated
  % Will block handle remain the same
  subsysObj.updateReference;
  
  % Model containing the subsystem block should not be 
  % compiled or it should not be running
  mdl = bdroot(subsys);
  if ishandle(mdl)
      mdl = get_param(mdl, 'name');
  end
  simStatus = get_param(mdl,'SimulationStatus');
  if ~strcmpi(simStatus, 'stopped')
    msgId = [msgIdPref_l, 'BadSimulationStatus'];
    msg   = sprintf(['Simulation status of model ''%s'' is ''%s''. ', ...
                     'This indicates that the model is being run. ', ...
                     'Please stop the simulation, and rerun ', ...
                     'convertToModelReference.'], ...
                    mdl, simStatus);
    handle_diagnostic_l('error', msgId, msg);
  end
  
  % Report error if Inline parameter is off
  inlineParam = get_param(mdl, 'InlineParams');
  if ~strcmp(inlineParam,'on')
    msgId = [msgIdPref_l, 'InlineParameter'];
    msg   = xlate(['''Inline Parameters'' option in the optimization tab of ', ...
             'configuration parameter dialog is ''off''. ', ...
             '''Inline parameters'' must be ''on'' in order ', ...
             'to convert a subsystem to model reference.']);
    handle_diagnostic_l('diag', msgId, msg); % Tested
  end
  
  % Model containing subsystem block must not have StrictBusMsg parameter set
  % to none or warning.
  strictBusMsg = get_param(mdl, 'StrictBusMsg');
  if strcmpi(strictBusMsg, 'none') || strcmpi(strictBusMsg, 'warning')
    msgId = [msgIdPref_l, 'InvalidStrictBusMsg'];
    msg   = xlate(['The ''Mux blocks used to create bus signals'' option in the ', ...
             'Configuration Parameters dialog, Diagnostics tab, ', ...
             'Connectivity section, Buses group must be set to ''error''. ', ...
             'See the Model Advisor and Simulink documentation for ', ...
             'more information.']);
    handle_diagnostic_l('diag', msgId, msg);
  end

  sigResolution = get_param(mdl,'SignalResolutionControl');
  if ~strcmp(sigResolution, 'UseLocalSettings')
    msgId = [msgIdPref_l, 'InvalidSignalResolution'];
    msg   = xlate(['The ''Signal resolution'' option in the ', ...
             'Configuration Parameters dialog, Diagnostics tab, ', ...
             'Data Validity section must be set to ''Explicit only''. See ', ...
             'the Model Advisor ''Check for implicit signal resolution'' ', ...
             'and Simulink documentation for more information.']);
    handle_diagnostic_l('diag', msgId, msg);
  end

  tunableVars = get_param(mdl,'TunableVars');
  if ~isempty(tunableVars) 
    msgId = [msgIdPref_l, 'TunableVarsTabelNotEmpty'];
    msg   = xlate(['The information in the tunable parameters table is being ', ...
             'ignored when using model referencing. To control parameter ', ...
             'tunability you will need to create Simulink parameter ', ...
             'objects for the relevant parameters and set their ', ...
             'storage classes accordingly. See help for ', ...
             'tunablevars2parameterobjects for more information.']);
    handle_diagnostic_l('diag', msgId, msg);
  end
  
  % Check other properties of subsys
  subsysH = get_param(subsys,'Handle');
  check_subsystem_before_compilation_l(subsysH);
  

  % mdlRef must be a new model name. 
  if ~(ischar(mdlRef) && isvarname(mdlRef) && ...
       sl('slss2mdl_util', 'isModelNameValid', mdlRef))
    msgId = [msgIdPref_l, 'InvalidModelRef'];
    msg   = xlate(['Invalid usage of convertToModelReference. ', ...
             'The second input must be a new model name. ']);
    handle_diagnostic_l('error', msgId, msg);
  end
end % check_subsys_and_mdlref_l


% Function: block_has_mask_l ==================================================
% Abstract:
%     Return true if this model is under mask. Otherwise, return false.
function hasMask = block_has_mask_l(blkH)
% we exclude simple masks.
  
  hasMask = strcmp(get_param(blkH, 'mask'), 'on');
  if hasMask
    hasNoDlgParams = isempty(get_param(blkH, 'MaskNames'));
    maskInit    = deblank(get_param(blkH,'MaskInitialization'));
    
    if (hasNoDlgParams && isempty(maskInit))
      % This is a simple mask
      hasMask = false;
    end
  end
end % block_has_mask_l


% Function: create_new_top_model_l =============================================
% Abstract:
%     Create a new top model and add a Model block referencing mdlRef.
%
function oMdl = create_new_top_model_l(mdlRef, subsys)
  
  oMdl = new_system;
  open_system(oMdl);
  
  cfg = getActiveConfigSet(oMdl);
  set_param(cfg, 'SignalResolutionControl','UseLocalSettings');
  set_param(cfg, 'UpdateModelReferenceTargets','IfOutOfDate');
  
  sl('slss2mdl_util', 'copy_configset',mdlRef, oMdl);  

  set_param(oMdl, 'ZoomFactor', get_param(get_param(subsys, 'Parent'), 'ZoomFactor'));
end % create_new_top_model_l


% Function: create_model_block_l ===============================================
% Abstract:
%    Create a Model block. If replace is true, replace the subsystem with
%    the Model block. If it is false, create a new model, and add the 
%    Model block to the new model.
%
function mdlRefBlkH = create_model_block_l(subsys, mdlRef, replace)
  
  subsysH = get_param(subsys, 'handle');
  
  % Get handle and output signal attributes
  subsysPortH = get_param(subsysH,'PortHandles');
  
  numOutputs = length(subsysPortH.Outport);
  prmNames = cell(1, numOutputs);
  subsysPrmVals = cell(1, numOutputs);
  for idx = 1:numOutputs
    [prmNames{idx}, subsysPrmVals{idx}] = get_output_sig_info_l( ...
        subsysPortH.Outport(idx)); 
  end 
  
  % the old block's name and parent are needed for the new block
  name   = strrep(get_param(subsysH,'Name'),'/','//');
  
  % the decorations must be preserved
  [decorations, positionIdx] = get_decoration_params_l(subsysH, mdlRef);
  
  if replace
      subsysLineHandles = get_param(subsysH,'LineHandles');
      parent = get_param(subsysH,'Parent');
  else
      oMdl = create_new_top_model_l(mdlRef, subsys);
      parent = get_param(oMdl, 'name');
      % Insert the block in the new model. Modify the position of the block
      assert(strcmp(decorations{positionIdx}, 'Position'));
      pos = decorations{positionIdx+1};
      w = pos(3) - pos(1);
      h = pos(4) - pos(2);
      pos = [205 75 (205+w) (75+h)];
      decorations{positionIdx+1} = pos;
  end
  
  mdlRefBlkH = add_block('built-in/ModelReference', ...
                         [parent '/' name],'makenameunique','on');
  set_param(mdlRefBlkH,'modelName',mdlRef);
  
  if replace
      try
          convertSSMgrConnections_l(subsysH, mdlRefBlkH);
      catch myException
          delete_block(mdlRefBlkH);
          rethrow(myException);
      end
      save_system(mdlRef);
      delete_block(subsysH);
  end

  set_param(mdlRefBlkH,'name',name);
  set_param(mdlRefBlkH,decorations{:});
  
  % Set output signal attributes
  mdlRefPortH = get_param(mdlRefBlkH,'PortHandles');
  
  for idx = 1:numOutputs
    set_output_sig_info_l(mdlRefPortH.Outport(idx), ...
                          prmNames{idx}, subsysPrmVals{idx});
  end

  if replace
      % The new block should have automatically connected to the old wires.
      % Verify this.
      mdlRefLineHandles = get_param(mdlRefBlkH,'LineHandles');
      
      % Find the first difference in each case to eliminate mlint
      notEqIn  = find(subsysLineHandles.Inport  - mdlRefLineHandles.Inport, 1); 
      notEqOut = find(subsysLineHandles.Outport - mdlRefLineHandles.Outport,1); 
      
      if ~(isempty(notEqIn) && isempty(notEqOut))
          open_system(parent);
          hilite_system(mdlRefBlkH);
          msgId = [msgIdPref_l, 'UnableToWireBlock'];
          msg = sprintf(['Error occurred when wiring the input and output ports ', ...
                         'of block ''%s'' in system ''%s''. ', ...
                         'Please connect the block.'],name,parent);
          handle_diagnostic_l('error', msgId, msg);
      end
  end
end % create_model_block_l

% Function:  get_output_sig_info_l ============================================
% Abstract:
%   return parameter names and values of 'read-write' parameters.
function [prmNames, prmVals] = get_output_sig_info_l(oPort)
  prmNames  = {};
  prmVals   = {};
  
  objPrm   = get_param(oPort,'ObjectParameters');
  allPrmNames = fieldnames(objPrm);
  
  for idx = 1:length(allPrmNames)
    thisPrm = allPrmNames{idx};
    cmd = ['objPrm.', thisPrm,'.Attributes'];
    atrib = eval(cmd);
    matchIdx = strmatch('read-write', atrib, 'exact');
    
    if ~isempty(matchIdx)
      prmNames{end+1}  = thisPrm;
      prmVals{end+1}   = get_param(oPort, thisPrm);
    end
    
  end
end % get_output_sig_info_l

% Function:  set_output_sig_info_l ============================================
% Abstract:
%   set output port signal info
function set_output_sig_info_l(oPort, prmNames, prmVals)
  % Becase of try-catch, cache the last error, and set the sllasterror
  % to the cached value in the case if the set_param fails. 

  slerr = sllasterror;
  for j = 1:length(prmNames)
    try
      % Even though the parameter is read-write, we may not be to able to
      % write to it. 
      % Example: PropagatedSignals, 
      %     READWRITE_param | WRITE_ON_LOAD_ONLY_param
      set_param(oPort, prmNames{j},  prmVals{j});
    catch myException %#ok
        % Catching an exception in a variable does not change
        % the value of lasterror.  So, we must reset sllasterror,
        % but doesn't need to reset lasterror.
      sllasterror(slerr);
    end
  end
end % set_output_sig_info_l

% Function: get_subsys_params_for_model_block_l ===============================
% Abstract:
%   This is a helper function for get_decoration_params_l.
%   It returns a cell-array of parameter names and empty values that
%   can be copied from Subsystem to Model block.
% 
function prms = get_subsys_params_for_model_block_l(subsys)
    prms = {};
    ssPrm = get_param(subsys,'ObjectParameters');
    ssPrmNames = fieldnames(ssPrm);

    mdlrefPrm = get_param('built-in/ModelReference','ObjectParameters');
    mdlrefPrmNames = fieldnames(mdlrefPrm);

    inSSNotInMdlRef = setdiff(ssPrmNames, mdlrefPrmNames);

    newSSPrm = rmfield(ssPrm, inSSNotInMdlRef);
    newSSPrmName =  fieldnames(newSSPrm);

    filterPrms = {'HiliteAncestors', 'Ports', 'IOType', 'AncestorBlock', ...
                  'ReferenceBlock','LinkStatus', 'Selected', 'RequirementInfo', ...
                  'StatePerturbationForJacobian'};

    for idx = 1:length(newSSPrmName)
        thisPrm = newSSPrmName{idx};
        
        % Ignore Mask parameters
        filter =  (~isempty(strmatch(thisPrm, filterPrms)) || ...
                   ((length(thisPrm) >= length('Mask')) && isequal(thisPrm(1:4), 'Mask')) || ...
                   ((length(thisPrm) >= length('Ext'))  && isequal(thisPrm(1:3), 'Ext' )));
        
        if ~filter
            cmd = ['newSSPrm', '.', thisPrm,'.Attributes'];       
            atrib = eval(cmd); 
            
            cmd = ['newSSPrm', '.', thisPrm,'.Type'];       
            type = eval(cmd); 
            
            matchIdx = strmatch('read-write', atrib, 'exact');
            filter =  isempty(matchIdx) || isequal(type, 'list');
            if ~filter
                prms{end+1} = thisPrm;
                prms{end+1} = [];
                %disp(thisPrm);    
            end
        end
    end
end % get_subsys_params_for_model_block_l

% Function: get_block_color_l =================================================
% Abstract:
%    Returm ForegroundColor or BackgroundColor of block.

function prmValue = get_block_color_l(subsysH, thisPrm)
    assert((strcmp(thisPrm, 'ForegroundColor') || strcmp(thisPrm, 'BackgroundColor')));
  
  mdl = bdroot(subsysH);
  sampColor = get_param(mdl, 'SampleTimeColors');
  isSampColorOn = strcmp(sampColor, 'on');
  
 if isSampColorOn 
      dirtyFlag = get_param(mdl, 'dirty');
      
      set_param(mdl, 'SampleTimeColors', 'off');
      prmValue = get_param(subsysH, thisPrm);
      set_param(mdl, 'SampleTimeColors', 'on');
      
      set_param(mdl, 'dirty', dirtyFlag);
  else
      prmValue = get_param(subsysH, thisPrm);
  end
end % get_block_color_l

% Function: get_decoration_params_l ===========================================
% Abstract:
%    Return a cell array containing the parameter/value pairs for a block's
%    decorations (i.e. FontSize, FontWeight, Orientation, etc.)
%    The caller assumes that the parameter names and values are interleaved.
%    Also return the Position parameter index needed by the caller.
function [decorations, positionIdx] = get_decoration_params_l(subsysH, mdlRef)

  decorations = get_subsys_params_for_model_block_l(subsysH);
  positionIdx = [];

  num = length(decorations)/2;
  for idx = 1:num,
      prmIdx    = 2*idx-1;
      prmValIdx = 2*idx; 
      thisPrm = decorations{prmIdx};
      if (strcmp(thisPrm, 'ForegroundColor') ||  strcmp(thisPrm, 'BackgroundColor'))
          % This code can be deleted when geck 268174 is fixed.
          decorations{prmValIdx} = get_block_color_l(subsysH, thisPrm);
      else
          decorations{prmValIdx} = get_param(subsysH, thisPrm);
      end
      if strcmp(thisPrm, 'Position')
          positionIdx = prmIdx;
      end
  end
  decorations{end+1} = 'ModelName';
  decorations{end+1} = mdlRef;

  assert(~isempty(positionIdx));
end % get_decoration_params_l


% Function: setup_inport_block_label_l ========================================
% Abstract:
%   Setup model reference input port label from subsystem inport block label.
%   GetInputSegmentSignalName only works for input ports.
%
%             ---------------------- 
%            |                                    Root inport
%     ------ | (ssInBlkH) ---------        ===>  (mdlRefInBlkH) ----------
%            |
%            .----------------------
%               subsys                                      mdlRef
%
function setup_inport_block_label_l(subsys, iPortIdx, ssInBlkH, mdlRefInBlkH)
    ssInBlkPorts = get_param(ssInBlkH,'PortHandles');
    srcName      = get_param(ssInBlkPorts.Outport,'Name');
    if isempty(srcName)
        ssPortHs = get_param(subsys, 'PortHandles');
        label = get_param(ssPortHs.Inport(iPortIdx),'GetInputSegmentSignalName');
        % Set label
        if ~isempty(label)
            mdlRefInBlkPortH = get_param(mdlRefInBlkH,'PortHandles');
            set_param(mdlRefInBlkPortH.Outport,'Name', label);
        end
    else
        mdlRefInBlkPortH = get_param(mdlRefInBlkH,'PortHandles');
        mdlRefName = get_param(mdlRefInBlkPortH.Outport,'Name');
        % Signal label must have been copied
        assert(strcmp(mdlRefName, srcName));
    end
end % setup_inport_block_label_l

% Function: get_outport_block_graphical_src_l =================================
% Abstract:
%     Get graphical source of outport block.
%            
%          srcPort --------------> oBlk
%
function srcPort = get_outport_block_graphical_src_l(oBlk)
    portH   = get_param(oBlk,'PortHandles');
    lineH   = get_param(portH.Inport(1),'Line');

    if(ishandle(lineH))
        srcPort = get_param(lineH,'SrcPortHandle');
    else
        srcPort = -1;
    end % if
end % get_outport_block_graphical_src_l


% Function: setup_outport_block_label_l =======================================
% Abstract:
%    Setup model reference output port label from subsystem output port label.
%
%        -----------------------.
%                               |                         Root outport
%        ---------- (ssOutBlkH) |           ----------- (mdlRefOutBlkH)
%                               |
%        -----------------------.
%
%                  subsys                                 mdlRef
%                           
function setup_outport_block_label_l(ssOutBlkH, mdlRefOutBlkH)
    % Get label
    srcPort = get_outport_block_graphical_src_l(ssOutBlkH);
    if(ishandle(srcPort))
        srcName = get_param(srcPort,'Name');
    else
        srcName = '';
    end % if

    if isempty(srcName)
      ssOBlkPortHs = get_param(ssOutBlkH, 'PortHandles');
      label = get_param(ssOBlkPortHs.Inport(1), 'GetInputSegmentSignalName');

      % Set label
      if ~isempty(label)
        mdlRefOBlkSrcPort = get_outport_block_graphical_src_l(mdlRefOutBlkH);
        set_param(mdlRefOBlkSrcPort,'Name', label);
      end
    else
      mdlRefOBlkSrcPort = get_outport_block_graphical_src_l(mdlRefOutBlkH);
      mdlRefName = get_param(mdlRefOBlkSrcPort,'Name');
      % Signal label must have been copied
      assert(strcmp(mdlRefName, srcName));
    end
end % setup_outport_block_label_l


% Function: get_bus_names_in_base_workspace_l =================================
% Abstract:
%    Return list of all bus objects in the base workspace.
function buses = get_bus_names_in_base_workspace_l()
    var = evalin('base','whos');
    buses = {};
    for idx = 1:length(var)
      if (strcmp(var(idx).class,'Simulink.Bus'))
        buses{end+1} = var(idx).name;
      end
    end
end % get_bus_names_in_base_workspace_l

% Function: check_subsystem_before_compilation_l ==============================
% Abstract:
%    Check subsystem properties that do not need the model to be compiled
function check_subsystem_before_compilation_l(subsysH)
  
  % The subsystem must be atomic or function-call
  ssType = sl('slss2mdl_util', 'check_subsystem_type', subsysH);
  [isOk, msg] = sl('slss2mdl_util', 'check_valid_subsystem_type',ssType);
  
  if ~isOk
    msgId = [msgIdPref_l, 'InvalidSubsystemType'];
    msg = [sl('slss2mdl_util','getFirstArgDiagnosticMessage'), msg];
    handle_diagnostic_l('error', msgId, msg);
  end
  

  % Subsystem or its parent should not have a mask
  tmpBlk  = subsysH;
  hasMask = false;
  while ~isempty(tmpBlk)
    hasMask =  block_has_mask_l(tmpBlk);
    if hasMask, break; end
    
    parent  =  get_param(tmpBlk, 'parent');
    type = get_param(parent, 'type');
    
    if strcmp(type, 'block')
      tmpBlk = parent;
    else
      tmpBlk = ''; 
    end
  end
  
  if(hasMask) 
    subsysWithMask = getfullname(tmpBlk);
    msgId = [msgIdPref_l, 'InvalidSubsystemUnderMask'];
    msg   = sprintf(['Cannot convert a masked subsystem or a subsystem under ', ...
                      'mask to a model. The subsystem block ''', ...
                      '%s'' has a mask.'],subsysWithMask);
    handle_diagnostic_l('diag', msgId, msg); 
  end
  
  % Check for stateflow partioning
  canPartition = sl('slss2mdl_util', 'stateflow_allows_partioning', subsysH);
  
  if ~canPartition
    msgId = [msgIdPref_l, 'InvalidSubsystemStateflow'];
    msg = xlate(['The specified subsystem block contains a Stateflow chart with ', ...
           'machine parented data or events, or exported graphical ', ...
           'functions. Cannot convert subsystems with this condition. ']);
    handle_diagnostic_l('diag', msgId, msg); 
  end
end % check_subsystem_before_compilation_l

% Function check_for_actual_src_dst_sample_times_l =============================
% Abstract:
% This function compares subsystem inport(outport) block sample times and
% reports an error if the sample times do not match.
%
% Note: 
%   get_param(block, 'PortBlockSampleTimeInfo') will return a [4x5] 
%   mxArray matrix.
%
%  Each row has the following information:
%      [blockHandle, portIdx (0 based), isInputPort (1/0), sample_time, offset]
%  First row:  info about pBlk. pBlk can be a subsystem Inport/Outport block
%  Second row: info about corresponding subsystem input port or output port
%  Third row:  info about down-stream (Destination) blocks
%  Fourth row: info about up-stream   (Source) blocks
%
function check_for_actual_src_dst_sample_times_l(ssInBlkHs, ssOutBlkHs)
  
  blks = [ssInBlkHs; ssOutBlkHs];
  
  errPostFix  = xlate(['Sample times must be the same. Please either ', ...
                'change one of the two sample times or ', ...
                'insert a Rate Transition block.']);
  warnPostFix = xlate('You may need to insert a Rate Transition block.');
  
  for idx = 1:length(blks)
    blkH = blks(idx);
    phs  = get_param(blkH, 'PortHandles');
    
    if(idx <= length(ssInBlkHs))
      ph = phs.Outport;
      isInport = true;
    else
      ph =  phs.Inport;
      isInport = false;
    end
    % See the above comment for more information
    tsInfo = get_param(ph,'PortBlockSampleTimeInfo');

    % The first row has subsystem Inport/Outport block info
    rowIdx  = 1;
    portTs  = tsInfo(rowIdx, 4:5);
    assert(blkH == tsInfo(rowIdx, 1));
    
    % The third row has down-stream block info
    rowIdx = 3;
    downstreamTs = [];
    if tsInfo(rowIdx, 1) ~= -1 % INVALID_HANDLE	(-1.0)
      downstreamBlk  = tsInfo(rowIdx, 1);
      downstreamPort = tsInfo(rowIdx, 2);
      % It must be the inport of down-stream block
      assert(tsInfo(rowIdx, 3) == 1);
      downstreamTs  = tsInfo(rowIdx, 4:5);
    end
    
    % The fourth row has up-stream block info
    rowIdx = 4;
    upstreamTs = [];
    if tsInfo(rowIdx,1) ~= -1 % INVALID_HANDLE	(-1.0)
      upstreamBlk  = tsInfo(rowIdx, 1);
      upstreamPort = tsInfo(rowIdx, 2);
      % It must be the output port of up-stream block
      assert(tsInfo(rowIdx, 3) == 0);
      upstreamTs   = tsInfo(rowIdx, 4:5);
    end

    if ~isempty(downstreamTs) && ~isequal(portTs, downstreamTs)
      msg = sprintf(...
          ['Block ''%s'' has a sample time of [%s, %s] which ', ...
           'does not match the sample time [%s, %s] of input port %d ', ...
           'of downstream block ''%s''. '], ...
          getfullname(blkH), num2str(portTs(1)), num2str(portTs(2)), ...
          num2str(downstreamTs(1)), num2str(downstreamTs(2)), downstreamPort+1, ...
          getfullname(downstreamBlk));

      if isInport
        msgId = [msgIdPref_l, 'InvalidDownStreamSampleTimeErr'];
        msg = [msg, errPostFix];
        handle_diagnostic_l('diag', msgId, msg);
      else
        msgId = [msgIdPref_l, 'InvalidDownStreamSampleTimeWarn'];
        msg = [msg, warnPostFix];
        handle_diagnostic_l('warning', msgId, msg);
      end
    end
    
    if ~isempty(upstreamTs) && ~isequal(portTs, upstreamTs) 
      msg = sprintf( ...
          ['Block ''%s'' has a sample time of [%s, %s] which ', ...
           'does not match the sample time [%s, %s] of output port %d ', ...
           'of upstream block ''%s''. '], ...
          getfullname(blkH),  num2str(portTs(1)), num2str(portTs(2)), ...
          num2str(upstreamTs(1)), num2str(upstreamTs(2)), upstreamPort+1, ...
          getfullname(upstreamBlk));
   
      if ~isInport
        msgId = [msgIdPref_l, 'InvalidUpStreamSampleTimeErr'];
        msg = [msg, errPostFix];
        handle_diagnostic_l('diag', msgId, msg);
      else
        msgId = [msgIdPref_l, 'InvalidUpStreamSampleTimeWarn'];
        msg = [msg, warnPostFix];
        handle_diagnostic_l('warning',msgId, msg);
      end
    end
  end
end % check_for_actual_src_dst_sample_times_l 

% Function: check_for_local_dwork_crossing_subsys_l ======================
% Abstract:        
%    Report an error if a local dwork is crossing the subsystem boundary.
%    * Bit0: a local dwork for a data store crossing subsystem boundary
%    * Bit1: a local dwork for iterator block dwork crossing subsystem boundary
%
function check_for_local_dwork_crossing_subsys_l(subsysH)   
  
  compiledInfo = get_param(subsysH,'CompiledRTWSystemInfo');
  
  bit0 = bitand(compiledInfo(5), 1);
  bit1 = bitand(compiledInfo(5), 2);
  
  if bit0
    msgId = [msgIdPref_l, 'InvalidSubsystemLocalDataStoreCrossSys'];
    msg   = sprintf(['The Data Store Memory block associated with a ', ...
                     '''Data Store Read'' or ''Data Store Write'' ', ...
                     'block in the subsystem ''%s'' is outside of the ', ...
                     'subsystem. Cannot convert this subsystem to ', ...
                     'model reference.'], getfullname(subsysH));
    handle_diagnostic_l('diag', msgId, msg);
  end
  
  if bit1
    msgId = [msgIdPref_l, 'InvalidSubsystemDWorkCrossSys'];
    msg   = sprintf(['The subsystem ''%s'' is in an iterator system. ', ...
                     'This subsystem directly/indirectly contains an ', ...
                     'Assignment block. The Assignment block is not ', ...
                     'in an iterator system. Please update your model ', ...
                     'to avoid this configuration. Cannot convert this ', ...
                     'subsystem to model reference.'], getfullname(subsysH));
    handle_diagnostic_l('diag', msgId, msg); 
  end
end % check_for_local_dwork_crossing_subsys_l


% Function: check_for_fcn_calls_with_inherit_state_setting =====================
% Abstract:       
%    When converting a subsystem to model reference, report an error if the
%    subsystem contains a fcn-call subsystem and fcn-call's trigger port
%    block's 'State when enabling' parameter is set to inherit.
%
function check_for_fcn_calls_with_inherit_state_setting(subsysH)   
    compiledInfo = get_param(subsysH,'CompiledRTWSystemInfo');
    ss = compiledInfo(7);
    
    if ishandle(ss)
        msgId = [msgIdPref_l, 'InvalidSubsystemFcnCallSSWithInheritState'];
        msg   = sprintf(['The ''State when enabling'' parameter of the ', ...
                         'Trigger port block inside the Function-Call subsystem ', ...
                         '''%s'' is set to inherit. Simulink cannot ensure ', ...
                         'compatibility between the original subsystem ''%s'' ', ...
                         'and the new model. Please set the ', ...
                         '''State when enabling'' parameter to reset or ', ...
                         'held before converting the subsystem block ', ...
                         'to model reference.'], ...
                        getfullname(ss), getfullname(subsysH));
        handle_diagnostic_l('error', msgId, msg);
    end
end % check_for_fcn_calls_with_inherit_state_setting

% Function: check_subsystem_after_compilation_ ===============================
% Abstract:        
%    Check compiled information of the subsystem block
function check_subsystem_after_compilation_l(subsysH, ssInBlkHs, ssOutBlkHs) 
  check_for_fcn_call_outputs_l(subsysH);
  check_for_wide_fcn_call_port_l(subsysH);
  check_for_const_inputs_l(ssInBlkHs);
  check_if_inports_are_merged_l(ssInBlkHs);
  check_for_actual_src_dst_sample_times_l(ssInBlkHs, ssOutBlkHs);
  check_for_local_dwork_crossing_subsys_l(subsysH);
  check_for_fcn_calls_with_inherit_state_setting(subsysH);
  check_for_variable_dimension_inputs(ssInBlkHs, subsysH);
end % check_subsystem_after_compilation_l

% Function: check_for_variable_dimension_inputs ================================
% Abstract:
%   Check if any of the inputs (bus and non-bus) to the subsystem have variable dimensions
function check_for_variable_dimension_inputs(ssInBlkHs, ssBlkH)  
    for idx = 1:length(ssInBlkHs)
        phs = get_param(ssInBlkHs(idx), 'PortHandles');
        portHandle = phs.Outport;

        bus =  get_param(portHandle,'CompiledBusStruct');
        if ~isempty( bus )
            busName =  get_param(portHandle,'CompiledPortAliasedThruDataType');     
            check_input_bus_variable_dimensions_mode(busName,portHandle,idx,ssBlkH);
        else
            dimsMode = get_param(portHandle,'CompiledPortDimensionsMode');
            
            if any(dimsMode)
                msg = DAStudio.message('Simulink:modelReference:variableDimsNotAllowedOnInput',...
                                       idx, getfullname(ssBlkH));
                msgId = [msgIdPref_l, 'variableDimsNotAllowedOnInput'];
                handle_diagnostic_l('error', msgId, msg);
            end
        end
    end
end % check_for_variable_dimension_inputs

% Function: check_input_bus_variable_dimensions_mode ================================
% Abstract:
%   Check if any element of the bus has variable dimensions
function check_input_bus_variable_dimensions_mode(busName,portHandle,idx,ssBlkH)
    busObject = sl('slbus_get_object_from_name', busName, false);
    if ~isempty(busObject) % check if bus is nonvirtual
        for elIdx = 1:length(busObject.Elements)
            busElm = busObject.Elements(elIdx);
            dtypeIsABus = ~isempty(sl('slbus_get_object_from_name', ...
                                      busElm.DataType, false));
            if dtypeIsABus
                check_input_bus_variable_dimensions_mode(busElm.DataType,portHandle,idx,ssBlkH);
            else
                if strcmp(busElm.dimensionsMode,'Variable')
                    msg = DAStudio.message('Simulink:modelReference:variableDimsNotAllowedOnInput',...
                                           idx, getfullname(ssBlkH));
                    msgId = [msgIdPref_l, 'variableDimsNotAllowedOnInput'];
                    handle_diagnostic_l('error', msgId, msg);
                end
            end
        end
    else %it is virtual bus
        dimsMode = get_param(portHandle,'CompiledPortDimensionsMode');
        if any(dimsMode)
            msg = DAStudio.message('Simulink:modelReference:variableDimsNotAllowedOnInput',...
                                   idx, getfullname(ssBlkH));
            msgId = [msgIdPref_l, 'variableDimsNotAllowedOnInput'];
            handle_diagnostic_l('error', msgId, msg);
        end
    end
end

% Function: check_for_wide_fcn_call_port_l ====================================
% Abstract:
%   Check if it is a function call subsystem with wide fcn-call port
function check_for_wide_fcn_call_port_l(subsysH)
    ssType = sl('slss2mdl_util', 'check_subsystem_type', subsysH);
    if strcmp(ssType, 'Function-call')
        portHs = get_param(subsysH, 'PortHandles');
        portWidth = get_param(portHs.Trigger,'CompiledPortWidth');
        if portWidth > 1
            msgId = [msgIdPref_l, 'InvalidSubsystemWideFcnCallPort'];
            msg   = sprintf(['The function-call input port of the specified ', ...
                             'subsystem block expects a wide (non-scalar) ', ...
                             'signal with %d elements. ', ...
                             'Cannot convert subsystems with wide ', ...
                             'function-call input port to model reference.'], ...
                            portWidth);
            handle_diagnostic_l('diag', msgId, msg);
        end
    end
end % check_for_wide_fcn_call_port_l
  

% Function: check_for_fcn_call_outputs_l ======================================
% Abstract:
%   Check if any of the subsystem output is a function call signal
function check_for_fcn_call_outputs_l(subsysH)
  
  hasFcnCallOutput = false;
  
  portDataTypes = get_param(subsysH,'CompiledPortDataTypes');
  outDataTypes = portDataTypes.Outport;
  
  for idx=1:length(outDataTypes)
    if strcmp(outDataTypes(idx),'fcn_call')
      hasFcnCallOutput = true;
      break;
    end
  end
  
  if hasFcnCallOutput
    msgId = [msgIdPref_l, 'InvalidSubsystemFcnCallOutput'];
    msg   = sprintf(['Output port %d of the specified subsystem block is a ', ...
                     'function-call signal. Cannot convert subsystems ', ...
                     'with function call outputs to model reference.'], ...
                    idx);
    handle_diagnostic_l('error', msgId, msg);
  end
end % check_for_fcn_call_outputs_l


% Function: check_for_const_inputs_l ==========================================
% Abstarct:
%  Report an error if one of the input port sample time is const.
function check_for_const_inputs_l(inBlkHs)
  hasConstInput = false;
  for inIdx=1:length(inBlkHs)
    compTs = get_param(inBlkHs(inIdx),'CompiledSampleTime');
    if isinf(compTs(1))
      hasConstInput = true;
      break
    end
  end
  
  if hasConstInput
    msgId = [msgIdPref_l, 'InvalidSubsystemConstInput'];
    msg   = sprintf(['Input port %d of the specified subsystem block has ', ...
                     'constant sample time. Cannot convert subsystems ', ...
                     'with constant inputs to model reference.'], ...
                    inIdx);
    handle_diagnostic_l('diag', msgId, msg);
  end
end % check_for_const_inputs_l


% Function: build_model_reference_target_l =====================================
% Abstract:
%   Build a model reference Sim or RTW target. Handle single-instanced, 
%   multi-instanced setting.
%   
function build_model_reference_target_l(mdlRef, targetType)
    disp(sprintf('\n'));
    dispWithPrefix_l(DAStudio.message('Simulink:modelReference:buildingModelReferenceTarget'));

    % ModelReferenceSimTarget or ModelReferenceRTWTarget
    bldCmd = ['slbuild(''', mdlRef, ''',''ModelReference',targetType,'Target'')'];

    hadErr = false;
    try
        evalc(bldCmd);
    catch myException
        hadErr = true;
        err = myException;

        % Was the error a multi-instance error? If so change to only allowing
        % one instance and try again
        if ~isempty(sllasterror)
            errs = sllasterror;
            multiInstanceError = false;
            for errIdx=1:length(errs)
                if (strfind(errs(errIdx).MessageID,'Simulink:modelReference:multiInstance') == 1)
                    multiInstanceError = true;
                    break;
                end
                if (strfind(errs(errIdx).MessageID,'Simulink:modelReference:MultiInstance') == 1)
                    multiInstanceError = true;
                    break;
                end
            end

            if (multiInstanceError)
                % clear the previous error
                err = '';
                disp(DAStudio.message('Simulink:modelReference:multiInstanceTargetBuildFailed'));

                set_param(mdlRef, 'ModelReferenceNumInstancesAllowed', 'Single');
                save_system(mdlRef);

                hadErr = false;
                try
                    evalc(bldCmd);
                catch myException
                    hadErr = true;
                    err    = myException;
                end % try/catch
            end
        end
    end

    if hadErr
        dispWithPrefix_l([DAStudio.message('Simulink:modelReference:unableToBuildTarget'), sprintf('\n')]);
        disp([DAStudio.message('Simulink:modelReference:errorMessages'), sprintf('\n')]);
        for errIdx = 1:length(err)
            disp(err(errIdx).message);
        end

        msgId = [msgIdPref_l, 'FailedToBuildTarget'];
        msg   = xlate(['Failed to build model reference target. See Matlab ', ...
            'command window for more information.']);
        handle_diagnostic_l('error', msgId, msg);
    end
end % build_model_reference_target_l

% Function: check_if_inports_are_merged_l ======================================
% Abstract:
%     Merge block inputs cannot be directly connected to root Inport blocks.
%     Report an error if the subsystem inport block is driving a Merge block,
%     and the Merge block is directly (or in-directly) inside the 
%     subsystem block.
%
function check_if_inports_are_merged_l(ssInBlkHs)
  
  for idx = 1:length(ssInBlkHs)
    obj = get_param(ssInBlkHs(idx), 'UDDObject');
    dsts = sl('slss2mdl_util', 'get_actual_dst', obj);
    numRows = size(dsts, 1);
    
    for jIdx = 1: numRows
      dstPortH   = dsts(jIdx, 1);
      dstBlkH    = get_param(dstPortH, 'ParentHandle');
      dstBlkType = get_param(dstBlkH, 'BlockType');
      
      if strcmp(dstBlkType, 'Merge')
        inBlkParent = get_param(ssInBlkHs(idx), 'parent');
        dstParent = get_param(dstBlkH, 'parent');
        if strncmp(dstParent, inBlkParent, length(inBlkParent))
          % in same system
          msgId = [msgIdPref_l, 'InvalidMergeConnection'];
          msg   = sprintf(['Input port ''%s'' is driving a Merge block. ', ...
                           'Since external signals from root level ', ...
                           'inports in the new model cannot be merged ', ...
                           'with internal block output signals, ', ... 
                           'this subsystem cannot be converted to a model.'], ...
                          getfullname(ssInBlkHs(idx)));
          handle_diagnostic_l('diag', msgId, msg); 
        end
      end
    end
  end
end % check_if_inports_are_merged_l


% Function: msgIdPerf_l =======================================================
% Abstract:
%   Return error or warning message prefix.
function msgIdPref = msgIdPref_l
   msgIdPref = 'Simulink:convertToModelReference:';
end % msgIdPref_l


% Function: loc_get_default_args_l ============================================
% Abstract:
%     Return a structure containing default values associated with 
%     input arguments of convertToModelReference
function args = loc_get_default_args_l()
  args.ReplaceSubsystem = false;
  args.BusSaveFormat    = '';
  args.BuildTarget      = '';
  args.Force            = false;
  args.ErrorOnly        = false;
end % loc_get_default_args_l


% Function:  ============================================
% Abstract:
function isInHier = IsBlkInSubsysHier_l(blkH, subsysH)
    isInHier   = false;
    subsysName = [getfullname(subsysH) '/'];
    blkName    = getfullname(blkH);
    idx        = strfind(blkName, subsysName);
    if (idx == 1) 
      isInHier = true; 
    end
end % IsBlkInSubsysHier_l

% Function:  ============================================
% Abstract:
function convertSSMgrConnections_l(subsysH, mdlRefBlkH)
    mdl = bdroot(subsysH);
    
    SSMgrViewers = find_system(mdl, ...
                               'SearchDepth',1,...
                               'AllBlocks','on',...  
                               'type','block', ...
                               'iotype','viewer');

    SSMgrSiggens = find_system(mdl, ...
                               'SearchDepth',1,...
                               'AllBlocks','on',...  
                               'type','block', ...
                               'iotype','siggen');
    
    SSMgrBlks  = [SSMgrViewers(:); SSMgrSiggens(:)];
    nSSMgrBlks = length(SSMgrBlks);
    
    % Loop over all SSMgr blocks in the root graph.
    for i = 1:nSSMgrBlks
        SSMgrBlk   = SSMgrBlks(i);
        isViewer   = strcmp(get_param(SSMgrBlk,'iotype'), 'viewer');
        IOSigs     = get_param(SSMgrBlk,'iosignals');
        nIOSigSets = length(IOSigs);
        
        % Loop over each set (i.e. port/axis) in the ioRec.
        for j = 1:nIOSigSets
            nSignals = length(IOSigs{j});
            
            % Loop over every handle in each ioRec set.
            for k = 1:nSignals
                Signal = IOSigs{j}(k);
                
                % Check for empty IORec.
                if (Signal.Handle == -1) 
                  continue; 
                end
                
                isPort = isempty(Signal.RelativePath);
                
                % Handle to a port
                if (isPort)
                    portIdx = get_param(Signal.Handle,'portnumber');
                    parent  = get_param(Signal.Handle,'parent');
                    parentH = get_param(parent,'handle');
                    
                    % Is this handle a port on the subsystem being converted?
                    if (parentH == subsysH)
                        mdlRefPortHs = get_param(mdlRefBlkH,'PortHandles');
                        
                        if (isViewer)
                            mdlRefPortH = mdlRefPortHs.Outport(portIdx);
                        else
                            mdlRefPortH = mdlRefPortHs.Inport(portIdx);
                        end
                        
                        % Set the handle to point to the modelref block.
                        IOSigs{j}(k).Handle = mdlRefPortH;
                        
                    % Is this handle inside the hierarchy of the subsystem
                    % being converted?
                    elseif (IsBlkInSubsysHier_l(parentH,subsysH))
                        % We cannot connect signal generators across model
                        % reference boundaries.  Throw an error because the
                        % referenced model will have a different structure from
                        % the original subsystem.
                        if (~isViewer)
                            msgId = [msgIdPref_l, 'InvalidSigGenConnection'];
                            msg = xlate(['The specified subsystem block contains input ports', ...
                                   ' connected to Signal & Scope Manager signal generators.', ...
                                   '  Cannot convert subsystems with this condition. ']);
                            handle_diagnostic_l('error', msgId, msg);
                        end
                    
                        % We have a valid viewer connection to a port inside the
                        % hierarchy of the subsystem being converted.  The viewer
                        % connection must be rewired to the corresponding port in
                        % the referenced model.
                        subsysFullName  = getfullname(subsysH);
                        destFullName    = getfullname(parent);
                        mdlRefName      = get_param(mdlRefBlkH,'modelName');
                        newDestFullName = [mdlRefName destFullName(length(subsysFullName)+1:end)];
                        relativePath    = [newDestFullName ':o' num2str(portIdx)];
                        IOSigs{j}(k).Handle       = mdlRefBlkH;
                        IOSigs{j}(k).RelativePath = slprivate('encpath',relativePath,'','','none');
                        
                        % Testpoint the signal inside the new model reference
                        newDestPortHs = get_param(newDestFullName,'PortHandles');
                        newDestPortH  = newDestPortHs.Outport(portIdx);
                        set_param(newDestPortH,'testpoint','on');
                    else
                        continue;
                    end
                % Handle to a block (modelref or stateflow).
                else
                    % Is this handle inside the hierarchy of the subsystem
                    % being converted?
                    if (IsBlkInSubsysHier_l(parentH,subsysH))
                        subsysFullName  = getfullname(subsysH);
                        destFullName    = getfullname(Signal.Handle);
                        mdlRefName      = get_param(mdlRefBlkH,'modelName');
                        newDestFullName = [mdlRefName destFullName(length(subsysFullName)+1:end)];
                        
                        % If we hit a modelref block, then our task is easy:
                        % This modelref will become a nested modelref and
                        % we simply encode the path to reflect this new
                        % hierarchy.  For stateflow blocks, it's more
                        % complicated.  The relative path for a stateflow
                        % block is different when that stateflow block is
                        % inside a modelref, so we can't simply encode the
                        % new path.  Instead, we do a little manipulation
                        % of the current relativePath to get it into a form
                        % where we can convert it to the appropriate form
                        % for stateflow in modelref.

                        relativePath  = Signal.RelativePath;
                        pathSeparator = 'modelref';
                        
                        stateflow = 0;
                        if ((strcmp(get_param(Signal.Handle,'Type'),'block')) && ...
                            (strcmp(get_param(Signal.Handle,'BlockType'),'SubSystem')) && ...
                            (strcmp(get_param(Signal.Handle,'MaskType'),'Stateflow')))
                            
                            stateflow = 1;
                            relativePath  = relativePath(length('StateflowChart')+1:end);
                            pathSeparator = 'none';
                        end
                        newRelPath = slprivate('encpath',newDestFullName,'',relativePath,pathSeparator);
                        
                        % Testpoint the stateflow signal inside the new modelref
                        if (stateflow)
                            sigPath = newRelPath(1:strfind(newRelPath,':o')-1);
                            r = sigPath;
                            while (~isempty(r))
                                [t r] = strtok(r,'/');
                            end
                            sigName = t;
                            sigPath = sigPath(1:findstr(sigPath,t)-2);
                            h = find(sfroot,'Name',sigName,'Path',sigPath);
                            if (~isempty(h))
                                h.Testpoint = 1;
                            end
                        end
                    
                        IOSigs{j}(k).Handle       = mdlRefBlkH;
                        IOSigs{j}(k).RelativePath = newRelPath;
                    else
                        continue;
                    end
                end
            end
        end
        set_param(SSMgrBlk,'iosignals',IOSigs);
    end
end % convertSSMgrConnections_l


function dispWithPrefix_l(s)
    disp(['### ', s]);
end % dispWithPrefix_l
