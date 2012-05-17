function tunablevars2parameterobjects(model, objClass)
% TUNABLEVARS2PARAMETEROBJECTS  Create Simulink parameter objects in the base
%   workspace for the variables listed in a model's tunable parameters dialog.
%
%   This function moves the model's TunableVars information into the resulting
%   Simulink parameter objects.  As a result:
%   - As part of the conversion process, the model's TunableVars information
%     is deleted.
%   - The resulting Simulink parameter objects should be saved into a MAT-file
%     for future use.
%
% Syntax:
%   tunablevars2parameterobjects(modelName, class)
%
% Inputs:
% - modelName:        Name (or handle) of the Simulink model.
% - class (optional): Specific parameter class to use for creating objects
%                     (uses Simulink.Parameter if not specified).
%
% NOTE:
% - If a TunableVar is already defined as a numeric variable in the base
%   workspace, the variable will be replaced by a parameter object and the
%   original variable will be copied to the object's Value property.
% - If a TunableVar is already defined as a Simulink parameter object, the
%   object will not be modified but the information for this TunableVar will
%   still be deleted.
% - If a TunableVar is defined as any other class of variable, the variable
%   will not be modified and the information for this TunableVar will not
%   be deleted.

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.6 $  $Date: 2008/04/14 19:56:50 $
  
  if nargin < 1
    DAStudio.error('Simulink:dialog:NoModelSpecified');
  elseif nargin == 1
    objClass = 'Simulink.Parameter';
  elseif nargin == 2
    % Check validity of class specified
    try
      tmpObj = eval(objClass);
      if ~isa(tmpObj, 'Simulink.Parameter')
        l_ErrorForInvalidClass(objClass);
      end
    catch
      l_ErrorForInvalidClass(objClass);
    end
  end

  model = get_param(model, 'Name');
  
  % Get information from the tunable parameters dialog
  mdlVars = get_param(model, 'TunableVars');
  mdlSCs  = get_param(model, 'TunableVarsStorageClass');
  mdlTQs  = get_param(model, 'TunableVarsTypeQualifier');
  
  % EARLY EXIT IF NO TUNABLE PARAMETER INFORMATION SPECIFIED
  if isempty(mdlVars)
    dispTxt = DAStudio.message('Simulink:dialog:TunableVarNotSpecifiedInModel', model);
    disp(dispTxt);
    return;
  end
  
  % Pre-process information (this also checks validity of TunableVars info).
  try
    nameInfo = eval(['{''', strrep(mdlVars, ',', ''';'''), '''}']);
    scInfo   = eval(['{''', strrep(mdlSCs,  ',', ''';'''), '''}']);
    tqInfo   = eval(['{''', strrep(mdlTQs,  ',', ''';'''), '''}']);
    
    if (~isequal(size(nameInfo), size(scInfo)) || ...
        ~isequal(size(nameInfo), size(tqInfo)))
      DAStudio.error('Simulink:dialog:NumTunableVarsTypeQualsDoesNotMatch');
    end
    
    mdlInfo = struct(...
        'Name',          nameInfo, ...
        'StorageClass',  scInfo, ...
        'TypeQualifier', tqInfo);
  catch err
    DAStudio.error('Simulink:dialog:TunableVarsInfoInvalid', ...
                              model, err.message);
  end

  % Create parameter objects
  idx = 1;
  while (idx <= length(mdlInfo))
    tmpObj = eval(objClass);
    
    % Get value from parameter in base workspace (if it exists)
    thisName = mdlInfo(idx).Name;
    if evalin('base', ['exist(''', thisName, ''', ''var'');']);
      tmpArray = evalin('base', thisName);
      
      % Check if variable in base workspace is already a Simulink.Parameter object
      if isa(tmpArray, 'Simulink.Parameter')
        % Remove this parameter from resulting TunableVars
        % DON'T INCREMENT THE INDEX
        mdlInfo(idx) = [];

        DAStudio.warning('Simulink:dialog:DiscardInfoFromModelForTunableVar', ...
                         model, thisName);
        continue;
      end

      % Set Value property
      try
        tmpObj.Value = tmpArray;
      catch
        % Increment counter so the info for this parameter is left in mdlInfo
        % LEAVE THIS ENTRY IN MDLINFO STRUCTURE
        idx = idx+1;
        
        DAStudio.warning('Simulink:dialog:SkipConvOfTunableVarForModelVarInBase', ...
                           thisName, model);
        continue;
      end
    end

    try
      % Set StorageClass
      thisSC = mdlInfo(idx).StorageClass;
      if strcmp(thisSC, 'Auto')
        thisSC = 'SimulinkGlobal';
      end
      tmpObj.RTWInfo.StorageClass = thisSC;
    catch err
      % Increment counter so the info for this parameter is left in mdlInfo
      % LEAVE THIS ENTRY IN MDLINFO STRUCTURE
      idx = idx+1;

      DAStudio.warning('Simulink:dialog:SkipConvOfTunableVarForModelInvalidSC', ...
                       thisName, model, thisSC, err.message);
      continue;
    end

    try
      % Set Type Qualifier
      thisTQ = strtrim(mdlInfo(idx).TypeQualifier);
      if ~isempty(thisTQ)
        tmpObj.RTWInfo.TypeQualifier = thisTQ;
      end
    catch err
      % Increment counter so the info for this parameter is left in mdlInfo
      % LEAVE THIS ENTRY IN MDLINFO STRUCTURE
      idx = idx+1;

      DAStudio.warning('Simulink:dialog:SkipConvOfTunableVarForModelInvalidTypeQual', ...      
                         thisName, model, thisTQ, err.message);
      continue;
    end

    try
      % Assign parameter object into base workspace
      assignin('base', thisName, tmpObj);
    catch err
      % Increment counter so the info for this parameter is left in mdlInfo
      % LEAVE THIS ENTRY IN MDLINFO STRUCTURE
      idx = idx+1;

      DAStudio.warning('Simulink:dialog:SkipConvOfTunableVarForModelUnableToAssignVarInBase', ...
                       thisName, model, err.message);
      continue;
    end

    
    % Remove this parameter from resulting TunableVars
    % DON'T INCREMENT THE INDEX
    mdlInfo(idx) = [];
  end
  
  % Clear TunableVars / TunableVarsStorageClass / TunableVarsTypeQualifier
  % (or recreate them from skipped parameters that are still in mdlInfo)
  mdlVars = '';
  mdlSCs  = '';
  mdlTQs  = '';
  if ~isempty(mdlInfo)
    for idx = 1:length(mdlInfo)
      mdlVars = [mdlVars, ',', mdlInfo(idx).Name];
      mdlSCs  = [mdlSCs,  ',', mdlInfo(idx).StorageClass];
      mdlTQs  = [mdlTQs,  ',', mdlInfo(idx).TypeQualifier];
    end
    mdlVars(1) = '';
    mdlSCs(1)  = '';
    mdlTQs(1)  = '';
  end
  
  % Update TunableVars information in the model.
  set_param(model, 'TunableVars',              mdlVars, ...
                   'TunableVarsStorageClass',  mdlSCs, ...
                   'TunableVarsTypeQualifier', mdlTQs);
  
%endfunction

%==============================================================================
% SUBFUNCTIONS:
%==============================================================================
function l_ErrorForInvalidClass(objClass)
  
  DAStudio.error('Simulink:dialog:InvalidParamClassNotSubClassOfSimParam', ...
                          objClass, 'Simulink.Parameter');
%endfunction

% EOF
  