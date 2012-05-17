function stf4target(nameStr, hObj)
% STF4TARGET  converting rtwoptions in system target file to properties in 
%             an object; Note that this is called during object creation.
%             You should not set value to properties that have init access.
%             Things that are setup during this routine:
%             1) Instance specific property
%             2) Default value and the enable status of those properties
%             3) Register those properties in the prop list
%             4) Setup derivation structure
%             5) Setup UI items
%             6) Property preset listener
%             7) Tlc options and make options markup string

% Copyright 2002-2009 The MathWorks, Inc.
% $Revision: 1.1.6.34 $
  
  if ~isa(hObj, 'Simulink.STFCustomTargetCC')
      DAStudio.error('RTW:configSet:unsupportedClassType');
      % return;
  end

  if isempty(nameStr)
      DAStudio.error('RTW:utility:emptyValue','nameStr');
      % return;
  end
  
  % If rtw not installed or available
  if ~(exist('rtwprivate','file')==2 || exist('rtwprivate','file')==6)
      DAStudio.error('RTW:configSet:rtwComponentUnavailable');
      % return;
  end

      
  [rtwoptions, gensettings] = rtwprivate('getSTFInfo', [],...
                                         'SystemTargetFile',nameStr);
    
  stfapp = strrep(gensettings.SystemTargetFile, matlabroot, '');
  stfapp = strrep(stfapp, '.tlc', '_');
  stfapp = strrep(stfapp, '/', '_');
  stfapp = strrep(stfapp, ':', '_');
  stfapp = strrep(stfapp, '\', '_');
  stfapp = strrep(stfapp, '.', '');
  
  dlgData = [];
  props   = [];
  tag = 'Tag_ConfigSet_RTW_STFTarget_';
  
  % whether system target file is updated to support dynamic dialog call back
  version = '';
  if isfield(gensettings, 'Version') 
      if ischar(gensettings.Version) && str2double(gensettings.Version) >= 1
          supportCB = true;
          version = gensettings.Version;
      else
          supportCB = false;
          DAStudio.warning('RTW:utility:incorrectSTFVersion',...
                           gensettings.SystemTargetFile);
      end
  else
      supportCB = false;
  end
  
  % initial setup for dynamic dialog
  if ~isempty(rtwoptions)
      index         = 0;
      categoryIndex = 0;
      dlgData.tabs.Name = 'tabs';
      dlgData.tabs.Type = 'tab';
      dlgData.tabs.Tag = [tag 'tab'];
      dlgData.supportCB = supportCB;
  end
  
  % If this target is derived from another target; we want to 
  % 1) Attach the parent target as a component of the current target;
  % 2) Transfer default values of the common target options from parent target
  %    to this target;
  if isfield(gensettings, 'DerivedFrom') && ~isempty(gensettings.DerivedFrom)
      parentSTF = gensettings.DerivedFrom;    
      hParentSTF = [];
      try
          hParentSTF = stf2target(gensettings.DerivedFrom);
      catch exc %#ok<NASGU>
                % ignore the error
      end
      
      if isempty(hParentSTF)
          DAStudio.error('RTW:configSet:instantiateTargetFailure',...
                         parentSTF,gensettings.SystemTargetFile);
      end
      
      loc_AddParentTarget(hObj, hParentSTF);
  end
  
  % store activate callback in object
  if isfield(gensettings, 'ActivateCallback') && ~isempty(gensettings.ActivateCallback)
      set(hObj, 'ActivateCallback', gensettings.ActivateCallback);
  end

  % store deselect callback in object
  if isfield(gensettings, 'DeselectCallback') && ~isempty(gensettings.DeselectCallback)
      set(hObj, 'DeselectCallback', gensettings.DeselectCallback);
  end
  
  % store post apply callback in object
  if isfield(gensettings, 'PostApplyCallback') && ~isempty(gensettings.PostApplyCallback)
      set(hObj, 'PostApplyCallback', gensettings.PostApplyCallback);
  end
  
  % An empty widget in case a group has no content
  emptyWidget.Name = 'Empty';
  emptyWidget.Type = 'text';
  emptyWidget.Visible = false;
  
  % Add properties for each rtwoption and create make option string on the fly
  makeoption = '';
  tlcoption = '';
  enumReg = [];
  setFunctions = [];
  getFunctions = [];
  hasCallback = false;
  widgetID_index = 0;
  
  % First, go through all the options to see if we need to automatically
  % attach an ERT target
  uiOnly(1:length(rtwoptions)) = false;
  optionIgnored(1:length(rtwoptions)) = false;
  for i = 1:length(rtwoptions)
      thisOption        = rtwoptions(i);
      thisOptionName    = thisOption.tlcvariable;
      thisOptionMakeVar = thisOption.makevariable;
      if isempty(thisOptionName) && ~isempty(thisOptionMakeVar)
          thisOptionName = thisOptionMakeVar;
      end
      
      if ~isempty(thisOptionName)
          switch thisOptionName
            case {'RollThreshold',...
                  'InlineInvariantSignals',...
                  'BufferReuse',...
                  'EnforceIntegerDowncase',...
                  'FoldNonRolledExpr',...
                  'LocalBlockOutputs',...
                  'RTWExpressionDepthLimit',...
                  'MaxRTWIdLen',...
                  'IncHierarchyInIds',...
                  'GenerateComments',...
                  'ForceParamTrailComments',...
                  'ShowEliminatedStatement',...
                  'IgnoreCustomStorageClasses',...
                  'IncDataTypeInIds', ...
                  'PrefixModelToSubsysFcnNames',...
                  'InlinedPrmAccess',...
                  'GenerateReport',...
                  'RTWVerbose'}
              % Ignore options that we have moved to other components
              optionIgnored(i) = true;
              
            case {'LogVarNameModifier',...
                  'MatFileLogging',...
                  'GenFloatMathFcnCalls',...
                  'TargetFunctionLibrary'}
              % those properties are promoted to base target, we only
              % present the ui not register property
              uiOnly(i) = true;
              
            case {'ZeroInternalMemoryAtStartup',...
                  'ZeroExternalMemoryAtStartup',...
                  'InsertBlockDesc',...
                  'InitFltsAndDblsToZero'}
              % Ignore ert options that we have moved to other components
              
              if strcmp(get(hObj, 'IsERTTarget'), 'off')
                  set(hObj, 'IsERTTarget', 'on');
                  
                  if isempty(hObj.getComponent('Target'))
                      hParentTarget = Simulink.ERTTargetCC;
                      
                      loc_AddParentTarget(hObj, hParentTarget);
                      set(hObj, 'ForcedBaseTarget', 'on');
                  else
                      hParentTarget = hObj.getComponent('Target');
                      if strcmp(get(hParentTarget, 'IsERTTarget'), 'off')
                          DAStudio.warning('RTW:buildProcess:ERTOnlyOption',...
                                           thisOptionName);
                      end
                  end
              end
              optionIgnored(i) = true;
              
            case {'IncludeMdlTerminateFcn',...
                  'ERTCustomFileBanners',...
                  'CombineOutputUpdateFcns',...
                  'SuppressErrorStatus',...
                  'GenerateSampleERTMain',...
                  'MultiInstanceERTCode',...
                  'PurelyIntegerCode',...
                  'GenerateErtSFunction'}
              % ERT options will be defined by the base target and thus are UI only.
              uiOnly(i) = true;
              if strcmp(get(hObj, 'IsERTTarget'), 'off')
                  set(hObj, 'IsERTTarget', 'on');
                  
                  if isempty(hObj.getComponent('Target'))
                      hParentTarget = Simulink.ERTTargetCC;
                      
                      loc_AddParentTarget(hObj, hParentTarget);
                      set(hObj, 'ForcedBaseTarget', 'on');
                      
                  else
                      hParentTarget = hObj.getComponent('Target');
                      if strcmp(get(hParentTarget, 'IsERTTarget'), 'off')
                          DAStudio.warning('RTW:buildProcess:ERTOnlyOption',...
                                           thisOptionName);
                      end
                  end
              end
              
            otherwise
          end % switch thisOptionName
      end
  end
  
  isERTTarget = strcmp(get(hObj, 'IsERTTarget'), 'on');
  hasForcedBase = strcmp(get(hObj, 'ForcedBaseTarget'), 'on');
  modelReferenceParameterCheck = [];
  
  for i = 1:length(rtwoptions)
      thisOption        = rtwoptions(i);
      thisOptionName    = thisOption.tlcvariable;
      thisOptionType    = thisOption.type;
      thisOptionDefault = thisOption.default;
      thisOptionMakeVar = thisOption.makevariable;
      thisOptionPrompt  = thisOption.prompt;
      thisOptionEnable  = thisOption.enable;
      if(isfield(thisOption, 'modelReferenceParameterCheck'))
          thisOptionModelReferenceParameterCheck = thisOption.modelReferenceParameterCheck;
      else
          thisOptionModelReferenceParameterCheck = '';
      end

      
      if ischar(thisOption.tooltip)
          thisOptionTooltip = thisOption.tooltip;
      else
          thisOptionTooltip = '';
      end
      if (supportCB &&...
          isfield(thisOption, 'callback') &&...
          ~isempty(thisOption.callback))
          thisOptionCallback = thisOption.callback;
      else
          thisOptionCallback = '';
      end    
      if (isfield(thisOption, 'callback') && ~isempty(thisOption.callback)) || ...
              (isfield(thisOption, 'opencallback') && ~isempty(thisOption.opencallback)) || ...
              (isfield(thisOption, 'closecallback') && ~isempty(thisOption.closecallback))
          hasCallback = true;
      end
      
      if isempty(thisOptionName) 
          if ~isempty(thisOptionMakeVar)
              thisOptionName = thisOptionMakeVar;
          else
              thisOptionName = '';
          end
      end
      
      thisUIOnly = uiOnly(i);
      
      % skip this option if it is ignored (move to other component)
      if optionIgnored(i)
          continue;
      end
      
      % Now that we know if we have a forced base ERT target or not, we can remove
      % options that are already declared by the base target
      if ~isempty(thisOptionName) && isERTTarget && hasForcedBase
          switch thisOptionName
            case {'GenerateASAP2',...
                  'ExtMode',...
                  'ExtModeTesting',...
                  'InlinedParameterPlacement',...
                  'TargetOS',...
                  'MultiInstanceErrorCode',...
                  'TargetFunctionLibrary',...
                  'ERTSrcFileBannerTemplate',...
                  'ERTHdrFileBannerTemplate',...
                  'ERTCustomFileTemplate'}
              thisUIOnly = true;
          end      
      end
      
      % initialize value
      uiType           = '';
      uiName           = '';
      uiObjectProperty = '';
      uiEntries        = [];
      uiValues         = [];
      propType         = [];
      
      if ~isempty(thisOptionType)
          % Select property type based on thisOptionType
          switch thisOptionType
            case 'Checkbox'
              propType         = 'slbool';
              uiType           = 'checkbox';
              uiName           = thisOptionPrompt;
              uiObjectProperty = thisOptionName;
              
            case 'Popup'        
              if thisUIOnly && hasProp(hObj, thisOptionName)
                  % UIOnly ==> this option is defined in internally
                  % We need to get its internal definition 
                  hOwner = getPropOwner(hObj, thisOptionName);
                  hProp = findprop(hOwner, thisOptionName);
                  hType = findtype(hProp.DataType);
                  if isprop(hType, 'Strings')
                      enumStrings = hType.Strings;
                  else
                      enumStrings = thisOption.popupstrings;
                      enumStrings = eval(['{''', strrep(enumStrings, '|', '''; '''), '''}']);
                  end
                  if isprop(hType, 'Values')
                      enumValues = hType.Values;
                  else
                      enumValues = 0:length(enumStrings)-1;
                  end
              else
                  propType = ['RTWOptions_EnumType_', stfapp, loc_GetVersionID(version), thisOptionName];
                  if isempty(findtype(propType))
                      enumStrings = thisOption.popupstrings;
                      enumStrings = eval(['{''', strrep(enumStrings, '|', '''; '''), '''}']);
                      if isfield(thisOption, 'value') && ~isempty(thisOption.value)
                          startVal = thisOption.value;
                          endVal   = thisOption.value+length(enumStrings)-1;
                          enumValues = startVal(1) : endVal(1);
                      else
                          enumValues = 0:length(enumStrings)-1;
                      end
                      schema.EnumType(propType, enumStrings, enumValues);
                  else
                      type = findtype(propType);
                      enumStrings = type.Strings;
                      enumValues  = type.Values;
                      %      else
                      %        warning(sprintf('A type named ''%s'' already exists.', propType));
                  end
                  if isempty(enumReg)
                      enumReg.Name = propType;
                      enumReg.Strings = enumStrings;
                      enumReg.Values = enumValues;
                  else
                      enumReg(end+1).Name = propType; %#ok<AGROW>
                      enumReg(end).Strings = enumStrings; %#ok<AGROW>
                      enumReg(end).Values = enumValues; %#ok<AGROW>
                  end
              end
              uiType           = 'combobox';
              uiName           = thisOptionPrompt;
              uiObjectProperty = thisOptionName;
              uiEntries        = enumStrings';
              uiValues         = enumValues;
            case 'Edit'
              isInt = ~isempty(regexp(thisOptionDefault, '^[+-]?\d*$','once'));
              if isInt
                  propType = 'int32';
                  thisOptionDefault = str2double(thisOptionDefault);
              else
                  propType = 'string';
              end
              uiType = 'edit';
              uiName = thisOptionPrompt;
              uiObjectProperty = thisOptionName;
              
            case 'NonUI'
              if (strcmp(thisOptionDefault, '0') || strcmp(thisOptionDefault, '1'))
                  propType = 'slbool';
                  thisOptionDefault = str2double(thisOptionDefault);
              elseif isempty(thisOptionDefault)
                  propType = 'string';
                  thisOptionDefault = '';
              else
                  num = str2double(thisOptionDefault);
                  str = num2str(num);
                  if strcmp(thisOptionDefault, str)
                      propType = 'int32';
                      thisOptionDefault = num;
                  else
                      propType = 'string';
                  end
              end
              
            case 'Category'
              categoryIndex = categoryIndex + 1;
              index = 0;
              dlgData.tabs.Tabs{categoryIndex}.Name = thisOptionPrompt;
              dlgData.tabs.Tabs{categoryIndex}.Items{1}.Name = '';
              dlgData.tabs.Tabs{categoryIndex}.Items{1}.Type = 'group';
              dlgData.tabs.Tabs{categoryIndex}.Items{1}.Items = {emptyWidget};
              continue;
              
            case 'Pushbutton'
              if supportCB
                  uiType = 'pushbutton';
                  uiName = thisOptionPrompt;
              else
                  continue;
              end
            otherwise
              DAStudio.warning('RTW:utility:UnsupportedRTWOptionType', thisOptionType);
              continue;
          end
          
          % make sure that what we declare UI only has been registered/used by
          % base target
          if ~isempty(propType) && thisUIOnly && ~isempty(thisOptionName) && ...
                  ~hObj.hasProp(thisOptionName)
              assertMsg = ['Internal error: ',thisOptionName,' has been removed from ', ...
                           ' base target definition.'];
              assert(false,assertMsg);
          end
          
          % Create property      
          if ~isempty(propType) && ~thisUIOnly && ~isempty(thisOptionName)
              if hObj.hasProp(thisOptionName)
                  if hObj.getPropOwner(thisOptionName) == hObj
                      DAStudio.warning('RTW:buildProcess:duplicateOption',...
                                       thisOptionName, gensettings.SystemTargetFile);
                      continue;
                  else
                      if supportCB
                          DAStudio.warning('RTW:buildProcess:baseOptionConflict',...
                                           thisOptionName, ...
                                           gensettings.SystemTargetFile);
                      else
                          DAStudio.warning('RTW:buildProcess:reservedNameOptionConflict',...
                                           thisOptionName, ...
                                           gensettings.SystemTargetFile);
                      end
                      continue;
                  end
              end
              hThisProp = schema.prop(hObj, thisOptionName, propType);
              hObj.registerPropList('UseParent', 'Only', thisOptionName);
              % cache property handles in a props handle vector
              if isempty(props)
                  props = hThisProp;
              else
                  props = [props hThisProp]; %#ok<AGROW>
              end
              
              % setup tlc option string
              if ~isempty(thisOptionName)
                  if ~isempty(tlcoption)
                      tlcoption = [tlcoption ' ']; %#ok<AGROW>
                  end
                  tlcoption = [tlcoption '-a' thisOptionName '=']; %#ok<AGROW>
                  switch propType
                    case {'slbool', 'int32'}
                      valrep = ['/' thisOptionName '/'];
                    case 'string'
                      valrep = ['"/' thisOptionName '/"'];
                    otherwise
                      % enum type
                      if (isfield(thisOption, 'value') && ~isempty(thisOption.value))
                          valrep = ['/' thisOptionName '/'];
                      else
                          valrep = ['"/' thisOptionName '/"'];
                      end
                  end
                  tlcoption = [tlcoption valrep]; %#ok<AGROW>
              end
              
              % setup the make option string
              if ~isempty(thisOptionMakeVar)
                  if ~isempty(makeoption)
                      makeoption = [makeoption ' ']; %#ok<AGROW>
                  end
                  makeoption = [makeoption thisOptionMakeVar '=']; %#ok<AGROW>
                  switch propType
                    case {'slbool', 'int32'}
                      valrep = ['/' thisOptionName '/'];
                    case 'string'
                      valrep = ['"/' thisOptionName '/"'];
                    otherwise
                      % this is enum type
                      if (isfield(thisOption, 'value') && ~isempty(thisOption.value))
                          valrep = ['/' thisOptionName '/'];
                      else
                          valrep = ['"/' thisOptionName '/"'];
                      end
                  end
                  makeoption = [makeoption valrep]; %#ok<AGROW>
              end
              
              % setup get and set function if any
              if (isfield(thisOption, 'setfunction') && ~isempty(thisOption.setfunction))
                  if isempty(setFunctions)
                      setFunctions.prop = thisOptionName;
                      setFunctions.fcn  = thisOption.setfunction;
                  else
                      setFunctions(end+1).prop = thisOptionName; %#ok<AGROW>
                      setFunctions(end).fcn    = thisOption.setfunction; %#ok<AGROW>
                  end
              end
              if (isfield(thisOption, 'getfunction') && ~isempty(thisOption.getfunction))
                  if isempty(getFunctions)
                      getFunctions.prop = thisOptionName;
                      getFunctions.fcn  = thisOption.getfunction;
                  else
                      getFunctions(end+1).prop = thisOptionName; %#ok<AGROW>
                      getFunctions(end).fcn    = thisOption.getfunction; %#ok<AGROW>
                  end
              end
          end
          
          % Set up ui item
          if ~isempty(uiType)
              widget = [];
              widget.Name = uiName;
              widget.Type = uiType;
              if ~isempty(uiObjectProperty)
                  widget.ObjectProperty = uiObjectProperty;
                  widgetID = widget.ObjectProperty;
              else
                  widgetID_index = widgetID_index + 1;
                  widgetID = sprintf('%s%d', uiType, widgetID_index);
              end
              if thisUIOnly && ~isempty(hObj.Components)
                  % redirect the source of this ui to its parent since there will be
                  % where get_param and set_param get value from
                  propOwner = hObj.Components(1).getPropOwner(uiObjectProperty);
                  if ~isempty(propOwner)
                      widget.Source = propOwner;
                  else
                      widget.Source = hObj.Components(1);
                  end
              end
              if ~isempty(uiEntries)
                  widget.Entries        = uiEntries;
              end
              if ~isempty(uiValues)
                  widget.Values         = uiValues;
              end
              widget.ToolTip        = thisOptionTooltip;
              widget.Mode = 1;
              if ~isempty(thisOptionCallback)
                  widget.MatlabMethod = 'slprivate';
                  widget.DialogRefresh = 1;
                  if strcmp(uiType, 'pushbutton')
                      widget.MatlabArgs = {'stfTargetDlgCallback', '%source', ...
                                          '%dialog', '', '', thisOptionCallback, uiName, uiType};
                  else
                      widget.MatlabArgs   = {'stfTargetDlgCallback', '%source', ...
                                          '%dialog', widgetID, ...
                                          '%value', thisOptionCallback, uiName, uiType};
                  end
              end
              index = index + 1;
              widget.RowSpan = [index index];        
              widget.Tag = [tag widgetID];
              dlgData.tabs.Tabs{categoryIndex}.Items{1}.Items{index} = widget;
              dlgData.tabs.Tabs{categoryIndex}.Source = hObj;
          end
          
          % set up default value
          if isempty(thisOptionDefault)
              % No default specified
          elseif hObj.hasProp(thisOptionName)
              currentVal = get_param(hObj, thisOptionName);
              if (isnumeric(currentVal) && ischar(thisOptionDefault))
                  set_param(hObj, thisOptionName, str2num(thisOptionDefault)); %#ok<ST2NM>
              else
                  set_param(hObj, thisOptionName, thisOptionDefault);
              end
          end
          
          % set up enable status
          if (~isempty(thisOptionEnable) &&...
              strcmp(thisOptionEnable, 'off') && ...
              hObj.hasProp(thisOptionName))
              setPropEnabled(hObj, thisOptionName, 0);
          end
          
          % set up model reference parameter check
          if ~isempty(thisOptionModelReferenceParameterCheck)
              modelReferenceParameterCheck(end + 1).parameter = thisOptionName; %#ok<AGROW>
              modelReferenceParameterCheck(end).check = thisOptionModelReferenceParameterCheck; %#ok<AGROW>
          end 
      end % if ~isempty(thisOptionType)
  end % for i = 1:length(rtwoptions)
  
  if ~isempty(dlgData)
      dlgData.tabs.nTabs = length(dlgData.tabs.Tabs);
      dlgData.hasCallback = hasCallback;
      if hasCallback && ~supportCB
          DAStudio.warning('RTW:utility:obsoleteSTFCallback',...
                           gensettings.SystemTargetFile);
      end
  end

  set(hObj, 'EnumDefinition', enumReg);
  set(hObj, 'MakeOptionString', makeoption);
  set(hObj, 'TLCOptionString', tlcoption);
  set(hObj, 'DialogData', dlgData);
  set(hObj, 'SetFunction', setFunctions);
  set(hObj, 'GetFunction', getFunctions);
  set(hObj, 'ModelReferenceParameterCheck', modelReferenceParameterCheck);
  
  % setup preset listener
  rtwprivate('stfTargetSetListener', hObj, props);
  
function loc_AddParentTarget(hTarget, hParentTarget)
  
  % Keep the old values for the following options:
  % SystemTargetFile
  oldSTFName = get(hTarget, 'SystemTargetFile');
  hTarget.assignFrom(hParentTarget, true);
  set(hTarget, 'SystemTargetFile', oldSTFName);
  attachComponent(hTarget, hParentTarget);
    
  % Set the target to be ERT derived if parent target is
  if isequal(get_param(hParentTarget, 'IsERTTarget'), 'on')
    set(hTarget, 'IsERTTarget', 'on');
  end
    
  % ModelReferenceCompliant is off by default
  set_param(hTarget, 'ModelReferenceCompliant', 'off');
  set_param(hTarget, 'CompOptLevelCompliant', 'off');
  set_param(hTarget, 'ParMdlRefBuildCompliant', 'off');
  set_param(hTarget, 'ERTFirstTimeCompliant', 'off');
  set_param(hTarget, 'ModelStepFunctionPrototypeControlCompliant', 'off');
  set_param(hTarget, 'CPPClassGenCompliant', 'off');
  set_param(hTarget, 'AutosarCompliant', 'off');

function version = loc_GetVersionID(version)
    version = strrep(version, '.', '_');
% EOF
