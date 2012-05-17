function customCodeSettings = get_custom_code_settings(targetId,parentTargetId)

% sfun & rtw target: get from ConfigSet. RTW target main model, return NULL
% other target:      get from Stateflow
%
% Assumption: parent model and child model have the same targetName

  relevantTargetId = targetId;
  targetName       = sf('get', targetId, 'target.name');
  machineId        = sf('get', targetId, 'target.machine');
  machineName      = sf('get', machineId, 'machine.name');
  isLib            = sf('get', machineId,'machine.isLibrary');
  isRTW            = strcmp(targetName, 'rtw');

  customCodeSettings.customSourceCode  = '';
  customCodeSettings.machineId = machineId;

  % targets other than sfun and rtw: custom target or hdl target
  if ~isRTW && ~strcmp(targetName, 'sfun')
    if isLib && ~sf('get',targetId,'.useLocalCustomCodeSettings')
      relevantTargetId = parentTargetId;
    end
    customCodeSettings.relevantTargetId  = relevantTargetId;
    customCodeSettings.customCode        = sf('get',relevantTargetId,'target.customCode');
    customCodeSettings.customSourceCode  = '';
    customCodeSettings.userIncludeDirs   = sf('get',relevantTargetId,'target.userIncludeDirs');
    customCodeSettings.userSources       = sf('get',relevantTargetId,'target.userSources');
    customCodeSettings.userLibraries     = sf('get',relevantTargetId,'target.userLibraries');
    customCodeSettings.reservedNames     = sf('get',relevantTargetId,'target.reservedNames');
    customCodeSettings.customInitializer = sf('get',relevantTargetId,'target.customInitializer');
    customCodeSettings.customTerminator  = sf('get',relevantTargetId,'target.customTerminator');
    return;
  end

  cs = getActiveConfigSet(machineName);

  if isLib
    if isRTW
      useLocalField = 'RTWUseLocalCustomCode';
    else
      useLocalField = 'SimUseLocalCustomCode';
    end

    useLocal = strcmp(get_param(cs, useLocalField), 'on');

    if ~useLocal
      relevantTargetId = parentTargetId;
      machineId = sf('get', parentTargetId, 'target.machine');
      cs = getActiveConfigSet(sf('get', machineId, 'machine.name'));
      customCodeSettings.machineId = machineId;
    end
  end

  customCodeSettings.relevantTargetId  = relevantTargetId;

  if isRTW
    if isLib && useLocal
      customCodeSettings.customCode        = get_param(cs, 'CustomHeaderCode');
      customCodeSettings.customSourceCode  = get_param(cs, 'CustomSourceCode');
      customCodeSettings.userIncludeDirs   = get_param(cs, 'CustomInclude');
      customCodeSettings.userSources       = get_param(cs, 'CustomSource');
      customCodeSettings.userLibraries     = get_param(cs, 'CustomLibrary');
      customCodeSettings.reservedNames     = get_param(cs, 'ReservedNames');
      customCodeSettings.customInitializer = get_param(cs, 'CustomInitializer');
      customCodeSettings.customTerminator  = get_param(cs, 'CustomTerminator');
    else
      customCodeSettings.customCode        = '';
      customCodeSettings.customSourceCode  = '';
      customCodeSettings.userIncludeDirs   = '';
      customCodeSettings.userSources       = '';
      customCodeSettings.userLibraries     = '';
      customCodeSettings.reservedNames     = '';
      customCodeSettings.customInitializer = '';
      customCodeSettings.customTerminator  = '';
    end
  else
    % sfun target
    if (slfeature('LegacyCodeIntegration') == 1)
      [customCodeSettings dummy] = legacycode.util.lci_getSettings(machineName, false);
      customCodeSettings.relevantTargetId  = relevantTargetId;
      customCodeSettings.machineId = machineId;      
    else
      customCodeSettings.customCode        = get_param(cs, 'SimCustomHeaderCode');
      customCodeSettings.customSourceCode  = get_param(cs, 'SimCustomSourceCode');
      customCodeSettings.userIncludeDirs   = get_param(cs, 'SimUserIncludeDirs');
      customCodeSettings.userSources       = get_param(cs, 'SimUserSources');
      customCodeSettings.userLibraries     = get_param(cs, 'SimUserLibraries');
      customCodeSettings.reservedNames     = get_param(cs, 'SimReservedNames');
      customCodeSettings.customInitializer = get_param(cs, 'SimCustomInitializer');
      customCodeSettings.customTerminator  = get_param(cs, 'SimCustomTerminator');
    end
  end

