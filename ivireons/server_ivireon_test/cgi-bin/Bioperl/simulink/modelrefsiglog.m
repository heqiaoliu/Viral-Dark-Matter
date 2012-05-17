function varargout = modelrefsiglog(varargin)
% MODELREFSIGLOG creates and manages the Model Reference Signal Logging Dialog

%   Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.22 $
%   Ricardo Monteiro

  persistent USERDATA;    
  try
   mlock
   
   %%%%%%%%%%%%%%%%%%%%%%%%%
   %% Determine arguments %%
   %%%%%%%%%%%%%%%%%%%%%%%%%
   Action = varargin{1};
   args   = varargin(2:end);
   
   %%%%%%%%%%%%%%%%%%%%
   %% Process Action %%
   %%%%%%%%%%%%%%%%%%%%
   switch (Action)
    case 'Create'
     % Test for existence of java swing
     if ~usejava('swing')
       DAStudio.error('Simulink:modelReference:signalLoggingRequiresJavaSupport');
     end


      ModelRefBlockHandle = args{1};
      if(~ishandle(ModelRefBlockHandle))
        DAStudio.error('Simulink:modelReference:signalLoggingInvalidBlockHandle');
      end

      isSfBlk = isStateflowBlock(ModelRefBlockHandle);
      isMrBlk = isModelrefBlock(ModelRefBlockHandle);
      
      if isSfBlk
        menuItemName = 'Log Chart Signals';
      else
        assert(isMrBlk, 'Block must be Model block or Stateflow block');
        menuItemName = 'Log Referenced Signals';
      end
          
      % Throw an error if we're in a library that is locked
      bdType = get_param(bdroot(ModelRefBlockHandle), 'BlockDiagramType');
      locked = get_param(bdroot(ModelRefBlockHandle), 'Lock');
      if (strcmp(bdType, 'library') == 1) && (strcmp(locked, 'on')),
          errordlg(['The ''' menuItemName ''' GUI is being invoked from a locked system. '...
                    'Please unlock the library to view/modify signals.'],...
                   'Error', 'modal');
          return;
      end
          
      % Throw an error if we're in a linked subsystem
      if isInsideLinkedSubsystem(ModelRefBlockHandle)
          errordlg(['The ''' menuItemName ''' GUI is being invoked from inside a linked system. '...
                    'Please disable the link to view/modify signals.'],...
                   'Error', 'modal');
          return;
      end

      if isSfBlk
        ModelHandle  = bdroot(ModelRefBlockHandle);
      else
        % Update block for variants
        i_UpdateBlockForVariants(ModelRefBlockHandle);
        ModelRefName =  get_param(ModelRefBlockHandle,'ModelName');    
        %% For now we will load the submodel %%
        %% yren,vijay: the following call is just a wrapper
        %% around load system that will make sure Stateflow 
        %% charts in the submodel are not opened unnecessarily
        %% Note that this has no ill-effects if the model
        %% has no Stateflow charts in it.
        %% Please talk to yao or vijay before changing it.
        sf('Private','sf_force_open_machine',ModelRefName);
        ModelHandle  = get_param(ModelRefName,'Handle');
      end
   
      % Check if dialog already created
      dialog_exists = 0;
      idx = FindModelRefSigLog(USERDATA, ModelRefBlockHandle);
      if ~isempty(idx)
        PanelHandle   = USERDATA(idx).PanelHandle;
        dialog_exists = 1;
      end

      % Create dialog for Signal Selector block and store it
      if (dialog_exists == 0)
        PanelHandle                  = ModelRefSigLogCreate(ModelHandle, ...
                                                          ModelRefBlockHandle);
        USERDATA(end+1).ModelHandle  = ModelHandle;
        USERDATA(end).PanelHandle    = PanelHandle;
        USERDATA(end).ModelRefBlockHandle = ModelRefBlockHandle;
      end
      
      % Now make it visible
      frame = PanelHandle.getFrame;
      % Use thread-safe javaMethodEDT instead of awtinvoke
      javaMethodEDT('show',frame);
      if(nargin > 2 )
        blkHandleToShow = args{2};
        signalToShow    = args{3};
        if(ishandle(blkHandleToShow) && ischar(signalToShow))
          if(strcmp(get_param(blkHandleToShow,'BlockType') , 'ModelReferenceBlock'))
            PanelHandle.selectTreeItemFromBlockHandle(blkHandleToShow, signalToShow);
          end
        end
      end
    case 'Close'
     ModelRefBlockHandle    = args{1};              
     idx = FindModelRefSigLog(USERDATA, ModelRefBlockHandle);
     if ~isempty(idx)
         PanelHandle = USERDATA(idx).PanelHandle;
         frame       = PanelHandle.getFrame;
         % Use thread-safe javaMethodEDT instead of awtinvoke
         javaMethodEDT('dispose',frame);
         USERDATA(idx) = [];
     end
    case 'Populate'    
     ModelRefBlockHandle = args{3};                                                
     idx = FindModelRefSigLog(USERDATA, ModelRefBlockHandle);     
     if ~isempty(idx) 
       [varargout{1}, varargout{2}, varargout{3}, varargout{4} ,...
        varargout{5}, varargout{6},varargout{7}, varargout{8}  ,...
        varargout{9}, varargout{10}, varargout{11}, varargout{12}, ...
        varargout{13}, varargout{14}] = ...
           DeterminePopulationData(USERDATA(idx), args);
     end
    
    case 'Apply'
     doApply(args);   
    case 'ApplyAll'
     doApplyAll(args, USERDATA);       
    case 'ApplyAllAndClose'
     doApplyAll(args, USERDATA);     
     if args{6}
        set_param(args{2}, 'DefaultDataLogging', args{7});
     end
     modelrefsiglog('Close', args{2});
    case 'GetCurrentSignals'
     varargout{1} = GetCurrentSignals(args, USERDATA);     
    case 'GetPanelHandle'
      varargout{1} =  GetPanelHandle(args, USERDATA); 
    case 'UpdateSignal'
     UpdateSignal(args, USERDATA);     
    case 'Help'
     doHelp(args)
   end
 catch me
   warning(me.identifier, me.message);
 end
 
%%%%%%%%%%%%%%%%%%%% 
% Helper Functions %
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function idx = FindModelRefSigLog(UD, H)
% 
idx = [];
if ~isempty(UD)
  idx = find([UD.ModelRefBlockHandle] == H);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function panel = ModelRefSigLogCreate(modelHandle, mdlRefBlkHandle)

modelName          = get_param(modelHandle,'Name');

if isModelrefBlock(mdlRefBlkHandle)
  DialogTitle = sprintf('Model Reference Signal Logging: %s (%s)', getfullname(mdlRefBlkHandle), modelName);
  defaultDataLogging = get_param(mdlRefBlkHandle,'DefaultDataLogging');
  isVariantBlock     = strcmp(get_param(mdlRefBlkHandle, 'Variant'), 'on');
  if ~isVariantBlock
    try %since find_mdlrefs can error out with no objects specified
      [~, blks] = find_mdlrefs(get_param(mdlRefBlkHandle, 'ModelName'));
      isVariantBlock = any(strcmp(get_param(blks, 'Variant'), 'on'));
    catch %#ok
      % Be safe and treat this as variant block
      isVariantBlock = true;
    end
  end
  hideModelHierPane  = false;
else
  % Stateflow block
  DialogTitle = sprintf('Stateflow Signal Logging: %s', getfullname(mdlRefBlkHandle));
  defaultDataLogging = 'always_off';
  isVariantBlock     = false;
  hideModelHierPane  = true;
end

% Use thread-safe javaMethodEDT instead of awtinvoke
panel = javaMethodEDT('CreateModelReferenceSignal', ...
                      'com.mathworks.toolbox.simulink.mdlrefsignallog.ModelReferenceSignalLog', ...
                      modelName, ...
                      modelHandle, ...
                      mdlRefBlkHandle,...
                      isVariantBlock, ...
                      DialogTitle,...
                      defaultDataLogging,...
                      hideModelHierPane);
                      
drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [names, logSignal, UseCustomName, LogName, LimitDataPoints, ...
          MaxPoints, Decimate, Decimation, LogFramesIndv, BlockPath, ...
          PortIndex, DefaultDataLogging, isSigNameEmpty, ...
          sigNamesToShow] = DeterminePopulationData(UD, args)

names              = {''};
logSignal          = [];
UseCustomName      = [];
LogName            = {''};
LimitDataPoints    = [];
MaxPoints          = [];
Decimate           = [];
Decimation         = [];
LogFramesIndv      = [];
BlockPath          = {''};
PortIndex          = [];
sigNamesToShow     = {''};
isSigNameEmpty     = [];

SelectedObj         = args{2};
specifiedByModelRef = args{4}{1};
diveIntoRefMdls     = args{4}{2};
modelBlockRefHandle = UD.ModelRefBlockHandle;

if isModelrefBlock(modelBlockRefHandle)
  DefaultDataLogging = get_param(modelBlockRefHandle,'DefaultDataLogging');
  if(diveIntoRefMdls)
    % Refresh Signals from the Model file
    set_param(modelBlockRefHandle,'UpdateSigLoggingInfo','on');
  end
else
  % Stateflow block
  DefaultDataLogging = 'always_off';
end

if(specifiedByModelRef)
  SigPropNode = get_param(modelBlockRefHandle,'AvailSigsDefaultProps');
else
  SigPropNode = get_param(modelBlockRefHandle,'AvailSigsInstanceProps');
end

if(isempty(SigPropNode))
  return;
end


objectType = get_param(SelectedObj,'Type');

switch objectType   
  case 'block_diagram'
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Root object was selected, show TP in root level %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    availSigs =  SigPropNode.Signals;
    numOfSigs = length(availSigs);
    for n = 1:numOfSigs
        names{n}           = availSigs(n).SigName;
        logSignal(n)       = availSigs(n).LogSignal;
        UseCustomName(n)   = availSigs(n).UseCustomName;
        LogName{n}         = availSigs(n).LogName;
        LimitDataPoints(n) = availSigs(n).LimitDataPoints;
        MaxPoints(n)       = availSigs(n).MaxPoints;
        Decimate(n)        = availSigs(n).Decimate;
        Decimation(n)      = availSigs(n).Decimation;
        LogFramesIndv(n)   = 0;
        BlockPath{n}       = availSigs(n).BlockPath;
        PortIndex(n)       = availSigs(n).PortIndex;
        sigNamesToShow{n}  = '';
        isSigNameEmpty(n)  = 0;
    end
   
   case 'block'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Subsystem or ModelRefBlock was selected %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    thisBlockPath = getfullname(SelectedObj);

    if( feature('MultilevelModelReferenceSignalLogging'))
      PanelHandle = UD.PanelHandle;
      encPath = PanelHandle.getEncodedPathFromSelectedNode;
      encPath = char(encPath);

      [found , SigPropNode] = multi_level_signal_node_lookup(SigPropNode,...
                                                        encPath);
    
    else
      [found , SigPropNode] = single_level_signal_node_lookup(SigPropNode,...
                                                     thisBlockPath, 0);
    end
    
    if(found)
      numOfSigs = length(SigPropNode.Signals);
      for k = 1:numOfSigs         
        names{k}           = SigPropNode.Signals(k).SigName;
        logSignal(k)       = SigPropNode.Signals(k).LogSignal;
        UseCustomName(k)   = SigPropNode.Signals(k).UseCustomName;
        LogName{k}         = SigPropNode.Signals(k).LogName;
        LimitDataPoints(k) = SigPropNode.Signals(k).LimitDataPoints;
        MaxPoints(k)       = SigPropNode.Signals(k).MaxPoints;
        Decimate(k)        = SigPropNode.Signals(k).Decimate;
        Decimation(k)      = SigPropNode.Signals(k).Decimation;
        LogFramesIndv(k)   = 0;
        BlockPath{k}       = SigPropNode.Signals(k).BlockPath;   
        PortIndex(k)       = SigPropNode.Signals(k).PortIndex;
        sigNamesToShow{k}  = '';
        isSigNameEmpty(k)  = 0;
      end
    end
end
% sort all the signanmes
if isempty(MaxPoints), return, end
[sigNamesToShow, isSigNameEmpty] = getSigNamesToShow(SigPropNode, names);

[names idx]     = sort(names);
logSignal       = double(logSignal(idx));
UseCustomName   = UseCustomName(idx);
LogName         = LogName(idx);
LimitDataPoints = LimitDataPoints(idx);
MaxPoints       = MaxPoints(idx);
Decimate        = Decimate(idx);
Decimation      = Decimation(idx);
LogFramesIndv   = LogFramesIndv(idx);
BlockPath       = BlockPath(idx);
PortIndex       = PortIndex(idx);
isSigNameEmpty  = isSigNameEmpty(idx);
sigNamesToShow  = sigNamesToShow(idx);

return;   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sigNamesToShow, isSigNameEmpty] = getSigNamesToShow(SigPropNode,...
                                                  names)

for k=1:length(SigPropNode.Signals)
  if(isempty(SigPropNode.Signals(k).SigName))
    indx = findstr(SigPropNode.Signals(k).BlockPath,'/');
    r = SigPropNode.Signals(k).BlockPath(indx(end)+1 : end);
    sigNamesToShow{k} = [r ' : ' num2str(SigPropNode.Signals(k).PortIndex)];
    isSigNameEmpty(k) = 1;
  else
    sigNamesToShow{k} = names{k};
    isSigNameEmpty(k) = 0;
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doHelp(args)
BlockHandle = args{1};
if isModelrefBlock(BlockHandle)
  helpview([docroot '/mapfiles/simulink.map'], 'modelreference_sig_log_ui')
else
  helpview([docroot '/mapfiles/stateflow.map'], 'stateflow_signal_logging')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doApply(args)

ModelRefBlockHandle = args{2};      
SigIndex = 0;
SigPropNode = get_param(ModelRefBlockHandle,'AvailSigsInstanceProps');
for i = 1:length(SigPropNode.Signals)
  if(strcmp(SigPropNode.Signals(i).BlockPath,args{13}))
    SigIndex = i;
  end
end
if(SigIndex > 0)
  SigPropNode.Signals(SigIndex).LogSignal = args{5};
  SigPropNode.Signals(SigIndex).UseCustomName = args{6};
  SigPropNode.Signals(SigIndex).LogName = args{7};
  SigPropNode.Signals(SigIndex).LimitDataPoints =  args{8};
  SigPropNode.Signals(SigIndex).MaxPoints = str2num( args{9} );
  SigPropNode.Signals(SigIndex).Decimate   =  args{10};
  SigPropNode.Signals(SigIndex).Decimation =  str2num( args{11});
  set_param(ModelRefBlockHandle,'AvailSigsInstanceProps', SigPropNode);
else
  DAStudio.warning('Simulink:modelReference:signalLoggingUnableToUpdateData');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doApplyAll(args, USERDATA)

 if( feature('MultilevelModelReferenceSignalLogging') && ...
     ~isStateflowBlock(args{2}))
   % We are dealing with ModelRef blocks
   doMultiLevelApplyAll(args, USERDATA)
   return;
 else
   doSingleLevelApplyAll(args,USERDATA)
 end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  doSingleLevelApplyAll(args, USERDATA)

ModelRefBlockHandle = args{2};      
sigProps            = args{3};     
changedSignals      = args{4};

SigPropNode = get_param(ModelRefBlockHandle,'AvailSigsInstanceProps');
   
for m=1:length(changedSignals)
  sigIdx = changedSignals{m};
  
  
  [found , referenceSigPropNode, ...
   SigPropNode] = single_level_signal_node_lookup(SigPropNode,...
                                         sigProps{sigIdx}{2}, 1);
  if(found )
    for k =1:length(referenceSigPropNode.Signals)
      if(strcmp(sigProps{sigIdx}{2}, referenceSigPropNode.Signals(k).BlockPath))
        % Log Signal
        referenceSigPropNode.Signals(k).LogSignal  = sigProps{sigIdx}{4};  
        % Log Name          
        if(isValidLogName(sigProps{sigIdx}{5}, referenceSigPropNode.Signals(k).SigName))
          errordlg('Logging name must be specified',...
                     'Signal Logging Interface');
          return;
        end
        referenceSigPropNode.Signals(k).UseCustomName   = sigProps{sigIdx}{5};
        referenceSigPropNode.Signals(k).LogName         = sigProps{sigIdx}{6};
        referenceSigPropNode.Signals(k).LimitDataPoints = sigProps{sigIdx}{7};
        referenceSigPropNode.Signals(k).MaxPoints       = sigProps{sigIdx}{8};
        referenceSigPropNode.Signals(k).Decimate        = sigProps{sigIdx}{9};
        referenceSigPropNode.Signals(k).Decimation      = sigProps{sigIdx}{10};
        break
      end
    end
  end    
end

set_param(ModelRefBlockHandle,'AvailSigsInstanceProps', SigPropNode);

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = isValidLogName(LogName, SignaName)
% Return 1 If the signal name is empty and the logging name 
% was not specified
val = 0;
if(isempty(LogName) && isempty(SignaName))
 val = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  PanelHandle = GetPanelHandle(args, USERDATA)
PanelHandle = [];

ModelRefBlockHandle = args{1}; 
idx = FindModelRefSigLog(USERDATA, ModelRefBlockHandle);

if ~isempty(idx) 
  PanelHandle = USERDATA(idx).PanelHandle;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sigProps = GetCurrentSignals(args, USERDATA)

sigProps = [];

ModelRefBlockHandle = args{1}; 
idx = FindModelRefSigLog(USERDATA, ModelRefBlockHandle);     
if ~isempty(idx) 
   PanelHandle = USERDATA(idx).PanelHandle;
   drawnow;
   sigPropsObject = PanelHandle.getCurrentSignals;
   drawnow;
   
   for i=1:length(sigPropsObject)
     sigProps.SigName{i}         = sigPropsObject(i,1);
     sigProps.BlockPath{i}       = sigPropsObject(i,2);
     sigProps.PortIndex{i}       = sigPropsObject(i,3); 
     sigProps.LogSignal{i}       = sigPropsObject(i,4); 
     sigProps.UseCustomName{i}   = sigPropsObject(i,5);
     sigProps.LogName{i}         = sigPropsObject(i,6); 
     sigProps.LimitDataPoints{i} = sigPropsObject(i,7);
     sigProps.MaxPoints{i}       = sigPropsObject(i,8); 
     sigProps.Decimate{i}        = sigPropsObject(i,9);
     sigProps.Decimation{i}      = sigPropsObject(i,10); 
     sigProps.LogFramesIndv{i}   = sigPropsObject(i,11); 
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateSignal(args, USERDATA)


ModelRefBlockHandle = args{1}; 
sigProps =  args{2};
sigIndex =  args{3};
idx = FindModelRefSigLog(USERDATA, ModelRefBlockHandle);     
if ~isempty(idx) 
 PanelHandle = USERDATA(idx).PanelHandle;
 PanelHandle.updateSignal(sigProps.SigName{sigIndex},...
                          sigProps.BlockPath{sigIndex},...
                          sigProps.LogSignal{sigIndex},...
                          sigProps.UseCustomName{sigIndex},...
                          sigProps.LogName{sigIndex},...
                          sigProps.LimitDataPoints{sigIndex},...
                          sigProps.MaxPoints{sigIndex},...
                          sigProps.Decimate{sigIndex},...
                          sigProps.Decimation{sigIndex},...
                          sigProps.LogFramesIndv{sigIndex});

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [found , nsigNode, sigNode] = single_level_signal_node_lookup(sigNode,...
                                                                      blockPath,...
                                                                      exactPath)
% Search for a signal node given the block path
found = 0;
flatSigPropNode = sigNode.find;
nsigNode = [];

for k=1:length(flatSigPropNode)
  if(exactPath)
    for m = 1: length(flatSigPropNode(k).Signals)
      if( strcmp( flatSigPropNode(k).signals(m).BlockPath , blockPath) )
        found = 1;
        nsigNode = flatSigPropNode(k);
        return
      end 
    end
  else
    if( strcmp(flatSigPropNode(k).Path, blockPath))
      found = 1;
      nsigNode = flatSigPropNode(k);
      return
    end 
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [found, SigPropNode] =  multi_level_signal_node_lookup(sigPropTree,... 
                                                            encPath)

found = 0;
SigPropNode = [];

flatSigPropNodeVector = sigPropTree.find;

for i=1:length(flatSigPropNodeVector)
  encPath = strrep(encPath, sprintf('\n'), ' ');  
  if strcmp(flatSigPropNodeVector(i).Path, encPath)
      found = 1;
      SigPropNode = flatSigPropNodeVector(i);
      break;
  end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  doMultiLevelApplyAll(args, USERDATA)
ModelRefBlockHandle = args{2};      
sigProps            = args{3};     
changedSignals      = args{4};
encPath             = char(args{5});
SigPropList = get_param(ModelRefBlockHandle,'AvailSigsInstanceProps');

idx = FindModelRefSigLog(USERDATA, ModelRefBlockHandle);     
if isempty(idx) 
  return;
end

len = length(encPath);
relEncPath = [encPath '/'];
flatSigPropNodeVector = SigPropList.find;

for m=1:length(changedSignals)
  sigIdx = changedSignals{m};
  % Loop over the flat signal list
  for n=1:length(flatSigPropNodeVector)
    % Loop over the Signal nodes
    for i=1:length(flatSigPropNodeVector(n).Signals)
      
      if(strncmp(flatSigPropNodeVector(n).Signals(i).BlockPath, relEncPath, len + 1))
        % Foud the Signal Node         
        
        % Do not match the signal name as it may be empty. Instead match
        % both the block path and port index
        
        % Check if the stored block path is the same as the Signal Node block path
        %  sigProps{sigIdx}{2} is the stored block path in Java   
        if( (strcmp(sigProps{sigIdx}{2}, flatSigPropNodeVector(n).Signals(i).BlockPath)) && ....
            (sigProps{sigIdx}{3} == flatSigPropNodeVector(n).Signals(i).PortIndex) )
          % Found the signal in the Signal Node that needs to be updated     

          flatSigPropNodeVector(n).Signals(i).LogSignal       = sigProps{sigIdx}{4};
          flatSigPropNodeVector(n).Signals(i).UseCustomName   = sigProps{sigIdx}{5};
          flatSigPropNodeVector(n).Signals(i).LogName         = sigProps{sigIdx}{6};
          flatSigPropNodeVector(n).Signals(i).LimitDataPoints = sigProps{sigIdx}{7};
          flatSigPropNodeVector(n).Signals(i).MaxPoints       = sigProps{sigIdx}{8};
          flatSigPropNodeVector(n).Signals(i).Decimate        = sigProps{sigIdx}{9};
          flatSigPropNodeVector(n).Signals(i).Decimation      = sigProps{sigIdx}{10};
          break;        
        end
      end
    end
  end
end
  
set_param(ModelRefBlockHandle,'AvailSigsInstanceProps', SigPropList);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isSfBlk = isStateflowBlock(blkHandle)

isSfBlk = strcmp( determineBlockType(blkHandle), 'Stateflow' );
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isMrBlk = isModelrefBlock(blkHandle)

isMrBlk = strcmp( determineBlockType(blkHandle), 'ModelReference' );
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function blkType = determineBlockType(blkHandle)

blkType  = get_param(blkHandle,'BlockType');
maskType = get_param(blkHandle,'MaskType');

if(strcmp(blkType,'SubSystem') && strcmp(maskType,'Stateflow'))
  blkType = maskType;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function linked = isInsideLinkedSubsystem(block)
% Returns true if the block is part of a linked subsystem.

  linked = false;  % default assumes NOT part of linked subsystem
  
  parent = get_param(block, 'Parent');
  if strcmpi(get_param(parent, 'Type'), 'block')
    if strcmpi(get_param(parent, 'BlockType'), 'SubSystem')
      if ~isempty(get_param(parent, 'ReferenceBlock'))
        linked = true;
      end
    end
  end
  return  % isInsideLinkedSubsystem
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  i_UpdateBlockForVariants(H)

try
  if strcmp(get_param(H, 'Variant'), 'on')
    % Determine variants for the model ref blocks - this may error out
    slInternal('determineActiveVariant', H);
  end
catch me %#ok - mlint
  % ignore exceptions
end

%eof modelrefsiglog.m
