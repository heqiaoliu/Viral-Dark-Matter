% Function: saSFTargets ======================================================
% Abstract:
%      Converts Stateflow/eML sfun/rtw targets
%      name prior to R14Sp1
%
%   Copyright 2008-2009 The MathWorks, Inc.
%
% Ignore licensing issues, especially Stateflow demo license

function newrules = saSFTargets(obj)

newrules  = {};
verobj    = obj.ver;
modelName = obj.modelName;
modelObj  = get_param(modelName, 'Object');
machine   = find(modelObj, '-isa', 'Stateflow.Machine');

if isempty(machine) % No-op if there is no Stateflow/eML
  return;
end

% Translate Stateflow version number
% NOTE: It is extremely important to use the sfprivate version of the
% translate function because it is tested and locked down at
% 
%       test/toolbox/stateflow/misc/t_sfversion.m
% 
% See g536462 for the kinds of horrible things that can happen if the
% SL->SF version translation is not maintained and kept up to date.
newrules{1} = ['<Stateflow<machine<sfVersion:repval ' sfprivate('translate_sl2sfversion', verobj.version) '>>>'];

if isR2008aOrEarlier(verobj)
  cs = getActiveConfigSet(modelName);

  % Return directly when there is no Stateflow charts or eML blocks or ConfigSet
  if isempty(cs)
    return;
  end

  machineId = sf('find','all','machine.name',modelName);
  isLib     = sf('get', machineId, 'machine.isLibrary');
  targets   = sf('TargetsOf', machineId);
  sfun      = sf('find', targets, 'target.name', 'sfun');
  rtw       = sf('find', targets, 'target.name', 'rtw');

  % Move Simulation target (non-library model and library model) into Stateflow sfun target
  if isempty(sfun)
    sfun = Stateflow.Target(machine);
    sfun.Name = 'sfun';
    sfun = sfun.Id;
  end

  if isLib
    useLocal = convert_on_off(get_param(cs,'SimUseLocalCustomCode'));
  else
    useLocal = 0;
    sf('set', sfun, 'target.codeFlags',                get_code_flags(cs, false));
    sf('set', sfun, 'target.reservedNames',            get_param(cs,'SimReservedNames'));
  end

  sf('set', sfun, 'target.customCode',                 get_param(cs,'SimCustomHeaderCode'));
  sf('set', sfun, 'target.userIncludeDirs',            get_param(cs,'SimUserIncludeDirs'));
  sf('set', sfun, 'target.userLibraries',              get_param(cs,'SimUserLibraries'));
  sf('set', sfun, 'target.customInitializer',          get_param(cs,'SimCustomInitializer'));
  sf('set', sfun, 'target.customTerminator',           get_param(cs,'SimCustomTerminator'));
  sf('set', sfun, 'target.userSources',                get_param(cs,'SimUserSources'));
  sf('set', sfun, 'target.useLocalCustomCodeSettings', useLocal);
  sf('set', sfun, 'target.applyToAllLibs',             1);

  if ~isLib && ~isBeforeR14(verobj)
    return;
  end

  % Move RTW custom code (library model) into Stateflow rtw target

  % Create a rtw target if there is none
  if isempty(rtw)
    rtw = Stateflow.Target(machine);
    rtw.Name = 'rtw';
    rtw = rtw.Id;
  end

  if isLib
    useLocal = convert_on_off(get_param(cs,'RTWUseLocalCustomCode'));
  else

    % Now isBeforeR14(verobj) is true
    useLocal = 0;
    sf('set', rtw, 'target.codeFlags',                get_code_flags(cs, true));
    sf('set', rtw, 'target.reservedNames',            get_param(cs,'SimReservedNames'));
  end

  sf('set', rtw, 'target.customCode',                 get_param(cs,'CustomHeaderCode'));
  sf('set', rtw, 'target.userIncludeDirs',            get_param(cs,'CustomInclude'));
  sf('set', rtw, 'target.userLibraries',              get_param(cs,'CustomLibrary'));
  sf('set', rtw, 'target.customInitializer',          get_param(cs,'CustomInitializer'));
  sf('set', rtw, 'target.customTerminator',           get_param(cs,'CustomTerminator'));
  sf('set', rtw, 'target.userSources',                get_param(cs,'CustomSource'));
  sf('set', rtw, 'target.useLocalCustomCodeSettings', useLocal);
  sf('set', rtw, 'target.applyToAllLibs',             1);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function convert_on_off
%
function re = convert_on_off(in)
  if strcmp(in, 'on')
    re = 1;
  else
    re = 0;
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function get_code_flags
% This function should be the same as the one in
% toolbox/stateflow/stateflow/private/get_target_props.m
%
function output = get_code_flags(cs, isRTW)
  if isRTW

    output = ' comments=';
    if (strcmp(get_param(cs,'GenerateComments'),'on'))
      output = [output '1 statebitsets='];
    else
      output = [output '0 statebitsets='];
    end

    if (strcmp(get_param(cs,'StateBitsets'),'on'))
      output = [output '1 databitsets='];
    else
      output = [output '0 databitsets='];
    end

    if (strcmp(get_param(cs,'DataBitsets'),'on'))
      output = [output '1'];
    else
      output = [output '0'];
    end

  else

    output = ' debug=';
    if (strcmp(get_param(cs,'SFSimEnableDebug'),'on'))
      output = [output '1 overflow='];
    else
      output = [output '0 overflow='];
    end

    if (strcmp(get_param(cs,'SFSimOverflowDetection'),'on'))
      output = [output '1 echo='];
    else
      output = [output '0 echo='];
    end

    if (strcmp(get_param(cs,'SFSimEcho'),'on'))
      output = [output '1'];
    else
      output = [output '0'];
    end

  end

% End of saSFTargets
