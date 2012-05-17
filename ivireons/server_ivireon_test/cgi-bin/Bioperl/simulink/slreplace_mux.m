function [muxes, uniqueMuxes, uniqueBds] = slreplace_mux(model, reportOnly)
%SLREPLACE_MUX  Replace Mux blocks used to create buses by Bus Creator blocks
%
%   SLREPLACE_MUX(MODEL, REPORTONLY) replaces all Mux blocks that create buses,
%   including Mux blocks in libraries, with Bus Creator blocks. 
%   This command saves the model, if changed, and saves and closes 
%   any library that it modifies (See Simulink documentation for more 
%   information).
%
%   A signal created by a Mux block is a bus if the signal meets either
%   or both of the following conditions:
%   (1) A Bus Selector block individually selects one or more of the signal's
%       elements (as opposed to the entire signal).
%   (2) The signal's components have different data types, numeric types
%       (complex or real), dimensionality, or sampling modes.
%
%     [muxes, uniqueMuxes, uniqueBds] = slreplace_mux(model, reportOnly)
%
%    Inputs:
%      model:      model name or handle
%      reportOnly: [true/false] (default is true)
%                  Detect Mux blocks used as Bus Creators but do not 
%                  modify any libraries or models. The number of Mux
%                  blocks used as Bus Creators will be displayed.
%                  The list of Mux blocks used as Bus Creators and the
%                  list of block diagrams containing them will be
%                  returned as optional outputs.
%
%    Outputs:
%      muxes:       All Mux blocks used as Bus Creators
%      uniqueMuxes: Identified Mux blocks in the model and libraries.
%                   This list contains the unique list of Mux blocks. That is,
%                   if the identified Mux block is in a referenced library 
%                   block, the Mux block will be reported relative to the 
%                   library containing the block rather than the model.
%      uniqueBds:   Block diagrams (model or libraries) containing Mux blocks
%                   that are used as bus creators
%
%   If reportOnly is true, it reports number of Mux blocks that are used as
%   Bus Creator blocks. 
%
%   If reportOnly is false, it replaces all Mux blocks that are used as 
%   Bus Creators in this model, including the library blocks, with Bus 
%   Creator blocks. The model and libraries will be saved automatically. 
%   If any library is modified, the model and libraries will be closed.
%
%   Because it is difficult to undo the changes when reportOnly is false, 
%   you should make a backup copy of your model and libraries before 
%   using this command.
%

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $

muxes       = {};
uniqueMuxes = {};
uniqueBds   = {};

% do not disp backtraces when reporting warning
wStates = [warning; warning('query','backtrace')];
warning off backtrace;
warning on; %#ok

s = onCleanup(@()warning(wStates)); 

% Check number of input arguments
if ~(nargin == 1 || nargin == 2)
    error([msgIdPref_l,'Usage'], 'Usage: slreplace_mux(''model'', reportOnly)');
end

% Set the default value for reportOnly to true
if nargin == 1
    reportOnly = true;
end

% Get the model name
model = check_input_model_l(model);

% Identify mux blocks in the model and libraries
[muxes, uniqueMuxes] = get_mux_used_as_bus_creators_l(model);
if(isempty(uniqueMuxes))
    disp('### No Mux block is used as Bus Creator');
    return;
end

% Get the name of block diagrams that should be modified
bds         = strtok(uniqueMuxes,'/');
uniqueBds   = unique(bds);
uniqueLibs  = setdiff(unique(bds), model);

% Report a warning if the Mux block's 'Number of inputs' parameter
% is not the same as the block's number of input ports
check_mux_blks_input_params_l(uniqueMuxes);

if ~reportOnly
    % Unlock the libraries
    for idx = 1:length(uniqueLibs)
        set_param(uniqueLibs{idx},'lock','off');
    end
    
    % Replace mux blocks
    for idx = 1:length(uniqueMuxes)
        replace_mux_with_bus_creator_l(uniqueMuxes{idx});
    end
    disp('### Mux blocks were replaced by Bus Creators');
    
    % Save the model and libraries. Close them if any library was modified.
    save_and_close_if_has_lib_l(model, uniqueBds, uniqueLibs);
    
    disp('### Successfully replaced Mux blocks used as Bus Creators.');
    
    msg = ['### To eliminate any modeling error in future, ', ...
           'please enable strict bus modeling by setting ', ...
           'the ''Mux blocks used to create bus signals'' diagnostic ',...
           'in Configuration parameter dialog, Diagnostic/Connectivity ', ...
           'tab to ''error''.'];
    disp(msg);
end

%endfunction slreplace_mux


% Function  check_mux_blks_input_params_l======================================
%   Reset the warning to its original state.
function check_mux_blks_input_params_l(muxes)
  firstOne = true;
  for idx = 1:length(muxes)
    muxBlk   = muxes{idx};
    inputPrm = get_param(muxBlk,'Inputs');
    
    pHandles = get_param(muxBlk, 'porthandles');
    numPort  = sprintf('%d', length(pHandles.Inport));
    
    if ~strcmpi(inputPrm, numPort)
      if firstOne
        msgId = [msgIdPref_l, 'DifferentInputParams'];
        msg = sprintf(['\n### The ''Number of inputs'' parameter of the ', ...
                       'following Mux blocks is different from their ', ...
                       'number of input ports. ', ...
                       'The number of input ports will be used ', ...
                       'for the ''Number of inputs'' parameter ', ...
                       'of the corresponding Bus Creator blocks:\n']);
        warning(msgId, msg);
        firstOne = false;
      end
      msg   = sprintf(['\nMux block: ''%s''\n', ...
                  '  ''Number of Inputs'' parameter: ''%s''\n', ...
                  '  Number of input ports       : ''%s''\n'], ...
                   muxBlk, inputPrm, numPort);
      disp(msg);
    end
    
  end
%endfunction check_mux_blks_input_params_l

% Function check_input_model_l=================================================
%  (1) input must be either a model name or handle to an open model
%  (2) SimulationStatus of model must be stopped, i.e., model is not running
%  (3) Model should not be dirty
function ioMdl = check_input_model_l(ioMdl)
  
  if ~ischar(ioMdl),
    % must be a handle to an open model
    if ~ishandle(ioMdl),
      error([msgIdPref_l,'Usage'], ...
            'Usage: slreplace_mux(''model'', reportOnly)');
    end
    ioMdl = get_param(ioMdl,'Name');
  end
  
  % Load the model if it is not loaded
  load_system(ioMdl);
  
  % Model should not be compiled or it should not be running
  simStatus = get_param(ioMdl,'SimulationStatus');
  if ~strcmpi(simStatus, 'stopped')
    msgId = [msgIdPref_l, 'BadSimulationStatus'];
    msg   = sprintf(['Simulation status of this model is ''%s''. ', ...
                     'This indicates that the model is being run. ', ...
                     'Please stop it, and rerun slreplace_mux command.'], ...
                    simStatus);
    error(msgId, msg);
  end
  
  % Model should not be dirty
  dirtyStr = get_param(ioMdl, 'Dirty');
  if strcmpi(dirtyStr,'on')
    msgId = [msgIdPref_l, 'UnsavedChanges'];
    msg   = sprintf(['The model has unsaved changes. Please save the ', ...
                     'model and rerun slreplace_mux command.']);
    error(msgId, msg);
  end
%endfunction  


%function save_and_close_if_has_lib_l =========================================
% Save the models and libraries. If any library is modified, close 
% the models and libraries.
%   uniqueBds:   unique list of block diagrams
%   hasLib: the list contains at least a library
function save_and_close_if_has_lib_l(model, uniqueBds, uniqueLibs)

  libModified = ~isempty(uniqueLibs);
  mdlModified = length(uniqueBds) > length(uniqueLibs);
  
  % Either mdlModified or libModified has been modified
  if libModified
    disp(['### Some of the libraries have been modified. ', ...
          'Saving and closing the model and libraries.']);
    
    savedAll = true;
    okToErr = false;
    % Report a warning for each bd if we cannot save it. 
    % Note that we are looping through all modified bds which includes
    % the model
    for idx = 1:length(uniqueBds)
      isOk = save_system_l(uniqueBds{idx}, okToErr);
      if isOk
        close_system(uniqueBds{idx});
      else
        savedAll = false;
      end
    end
    
    % Since the libraries have been modified, we must close the model too
    % Note: if mdlModified = true, it will be saved and closed in the above 
    % for loop
    if ~mdlModified
      close_system(model, 0);
    end
    
    % Report an error, if we were not able to save one of the block diagrams
    if ~savedAll
      msgId = [msgIdPref_l, 'UnableToSave'];
      msg = ['Was not able to save and close some of the block diagrams. ', ...
             'Please save and close the model and libraries.'];
      error(msgId, msg);
    end
  else 
    % mdlModified must be true. Otherwise, there was no mux block to replace!
    % Save the model. Since okToErr is true, no need to check the return 
    % status of save_system_l.
    okToErr = true;
    save_system_l(model, okToErr);
  end
  
%endfunction save_and_close_if_has_lib_l

% Function save_system_l ======================================================
% Abstract:
%   Save the block diagram. Report an error or warning if save_system failed.
%
function isOk = save_system_l(model, okToError)
isOk = true;
try
  save_system(model);
catch me
  isOk  = false;

  msgId = [msgIdPref_l,'UnableToSave'];
  msg   =  ['Was not able to save block diagram ''', model, ''' due to ', ...
            'this error:', me.message];
  if okToError
    error(msgId, msg);
  else
    warning(msgId, msg);
  end
end
%endfunction


% Function get_mux_used_as_bus_creators_l =====================================
% Abstract:
%   Compile the model, and return 
%   (1) full path of mux blocks that are used as Bus Creators
%   (2) full path of unique mux blocks in the model and libraries that are 
%       used as Bus Creators
function [muxes, uniqueMuxBlks] = get_mux_used_as_bus_creators_l(model)
  muxes = {};
  uniqueMuxBlks = {};

  muxInfo = get_mux_info_l(model);
  if isempty(muxInfo),  
    return;  
  end
  
  muxBlks      = [muxInfo.muxBlock]';
  refBlks      = get_param(muxBlks,'ReferenceBlock');
  muxFullPaths = getfullname(muxBlks);
  
  % Convert to cell for consistancy
  if ischar(muxFullPaths)
    muxFullPaths = {muxFullPaths};
  end
  
  % Since the library block may have been used multiple times, 
  % create a unique list of Mux blocks. 
  if isempty(refBlks)
    % no mux in library
    uniqueMuxBlks = muxFullPaths;
  else
    if ischar(refBlks)
      refBlks = {refBlks};
    end
    % Index of mux blocks that are in a model
    muxInMdlIdx = strmatch('',refBlks,'exact');
    refBlks(muxInMdlIdx) = [];
    uniqueMuxBlks = [muxFullPaths(muxInMdlIdx); unique(refBlks)];
  end
  
  muxes = muxFullPaths;
  
  dispMsg = sprintf(...
      ['### Number of Mux block instances used as Bus Creators: %d \n', ...
       '### Number of unique Mux blocks used as Bus Creators: %d'], ...
      length(muxBlks), length(uniqueMuxBlks));
  disp(dispMsg);
  
%endfunction

% Function get_mux_info_l =====================================================
% Abstract:
%   Return a structure containing Mux blocks used as bus creator blocks.
%
function muxInfo = get_mux_info_l(model)
  muxInfo = [];
  
  %% First, turn the Hierarchical Signal Logging feature off so that we do not
  %% attempt to load SLCompBus structures for Bus Selectors. If any of these blocks
  %% are testpointed and are driven by a mux, the compile will fail
  hierBusLog = busUtils('EnableHierarchyInSigLog', 0);

  try
    disp(['### Updating block diagram ''', model, '''']); 
    feval(model, [],[],[],'compile');
    
    muxInfo = get_param(model,'MuxUsedAsBusCreator');
    
    feval(model, [],[],[],'term');
    
  catch me
    %% Restore the Hierarchical Signal Logging feature
    busUtils('EnableHierarchyInSigLog', hierBusLog);
    
    actualLastErr = me.message;
    msgId = [msgIdPref_l, 'CompilationError'];
    msg   = ['Was not able to compile the model and gather ', ...
             'information about Mux blocks due to this error: ', actualLastErr];
    error(msgId, msg);
  end

  %% Restore the Hierarchical Signal Logging feature
  busUtils('EnableHierarchyInSigLog', hierBusLog);

%endfunction
  
% Function: replace_mux_with_bus_creator_l =====================================
% Abstract:
%    Replace Mux block by a Bus Creator block
%
function replace_mux_with_bus_creator_l(mux)

  % Get mux handle and output signal attributes
  muxH = get_param(mux, 'handle');
  muxPortH = get_param(muxH,'PortHandles');
  [prmNames, muxPrmVals] = get_output_sig_info_l(muxPortH.Outport);
  
  % the old block's name and parent are needed for the new block
  name   = strrep(get_param(muxH,'Name'),'/','//');
  
  % Change the block name if it is called Mux or mux
  name = strrep(name, 'Mux', 'BusCreator');
  name = strrep(name, 'mux', 'busCreator');
  
  parent = get_param(muxH,'Parent');

  % the decorations must be preserved
  decorations = get_decoration_params_l(muxH);

  muxLineHandles = get_param(muxH,'LineHandles');
  delete_block(muxH);
  busH = add_block('built-in/BusCreator', [parent '/' name],decorations{:});
  
  % Set output signal attributes
  busPortH = get_param(busH,'PortHandles');
  set_output_sig_info_l(busPortH.Outport, prmNames, muxPrmVals);
  
  % The new block should have automatically connected to the old wires.
  % Verify this.
  busLineHandles = get_param(busH,'LineHandles');

  notEqIn  = find(muxLineHandles.Inport  - busLineHandles.Inport); 
  notEqOut = find(muxLineHandles.Outport - busLineHandles.Outport); 
  
  if ~(isempty(notEqIn) && isempty(notEqOut))
    open_system(parent);
    hilite_system(busH);
    msgId = [msgIdPref_l, 'UnableToWireBusCreator'];
    msg = ['Error occurred when wiring the input and output ports ', ...
           'of block ''', name, ''' in system ''', parent, '''. ', ...
           'Please connect the block, save this block diagram, close ', ...
           'the models and libraries using ''bdclose all'' ', ...
           'and rerun the slreplace_mux command.'];
    error(msgId, msg);
  end
%endfunction replace_mux_with_bus_creator_l


% Function: msgIdPerf_l =======================================================
% Abstract:
function msgIdPref = msgIdPref_l
   msgIdPref = 'Simulink:slreplace_mux:';
%endfunction  msgIdPref_l


% Function: get_decoration_params_l ===========================================
% Abstract:
%    Return a cell array containing the parameter/value pairs for a block's
%    decorations (i.e. FontSize, FontWeight, Orientation, etc.)
%    (Copied from slupdate)
function decorations = get_decoration_params_l(block)
decorations = {
  'Position',        [];
  'Orientation',     [];
  'ForegroundColor', [];
  'BackgroundColor', [];
  'DropShadow',      [];
  'NamePlacement',   [];
  'FontName',        [];
  'FontSize',        [];
  'FontWeight',      [];
  'FontAngle',       [];
  'ShowName',        [];
  'Inputs',          [] % Mux specific parameter
};

num = size(decorations,1);
for i=1:num - 1,
  decorations{i,2}=get_param(block,decorations{i,1});
end

% Get the number of input ports from block not the block parameter.
% This is because, the Inputs parameter can be scalar, vector, or a cell-array.
pHandles = get_param(block, 'porthandles');
numPorts = length(pHandles.Inport);
decorations{num,2}= sprintf('%d', numPorts);

decorations=reshape(decorations',1,length(decorations(:)));

% end get_decoration_params_l


% Function:  get_output_sig_info_l ============================================
% Abstract:
%   return parameter names and values of 'read-write' parameters that 
%   are really writable! See commnets below
function [prmNames, prmVals] = get_output_sig_info_l(oPort)
  prmNames  = {}; %#ok
  prmVals   = {}; %#ok
  
  objPrm   = get_param(oPort,'ObjectParameters');
  allPrmNames = fieldnames(objPrm);
  
  for idx = 1:length(allPrmNames)
    thisPrm = allPrmNames{idx};
    cmd = ['objPrm.', thisPrm,'.Attributes'];
    atrib = eval(cmd);
    matchIdx = strmatch('read-write', atrib, 'exact');
    if ~isempty(matchIdx)
      try
        % Even though the parameter is read-write, we may not be to 
        % write to it. 
        % Example: PropagatedSignals, 
        %     READWRITE_param | WRITE_ON_LOAD_ONLY_param
        %
        % If we can set this parameter, cache the name and its values
        val =  get_param(oPort, thisPrm);
        set_param(oPort, thisPrm, val);
        
        prmNames{end+1}  = thisPrm;
        prmVals{end+1}   = val;
      catch
      end
    end
  end
%endfunction get_output_sig_info_l

% Function:  set_output_sig_info_l ============================================
% Abstract:
%   set output port signal info
function set_output_sig_info_l(oPort, prmNames, prmVals)
  for j = 1:length(prmNames)
    set_param(oPort, prmNames{j},  prmVals{j});
  end
%endfunction set_output_sig_info_l


