function targetChanged = sync_target(thisTarget,parentTarget,mainMachine)
%SYNC_TARGET calculates synchronization values for a given target
%  RESULT = SYNC_TARGET_GATEWAY(thisTarget,parentTarget)

%	Vijay Raghavan
%	Copyright 1995-2009 The MathWorks, Inc.
%  $Revision: 1.24.4.26 $  $Date: 2009/12/28 04:52:37 $

targetName = sf('get',thisTarget,'target.name');
thisMachine = sf('get',thisTarget,'target.machine');

if(nargin<2)
    parentTarget = thisTarget;
end

if(nargin<3)
    mainMachine = thisMachine;
end

if(isempty(mainMachine))
    mainMachine = thisMachine;
end

%% before we do anything, we need to update machine.sfLinks
if(~sf('get',thisMachine,'.isLibrary'))
    junk = slsf('mdlFixBrokenLinks',thisMachine);
end

sf('SyncMachine',thisMachine,thisTarget);
compute_session_independent_debugger_numbers(thisMachine);

targetChecksum = ck_target(thisTarget,parentTarget,mainMachine);

machineName = sf('get',thisMachine,'machine.name');

if (slfeature('LegacyCodeIntegration') == 1)
  lci_h = get_param(machineName,'LegacyCodeIntegration');
  if ~isempty(lci_h)
    if strcmp(targetName, 'sfun')
      targetChecksum = md5(targetChecksum, lci_h.simChecksum);
    end
    if strcmp(targetName, 'rtw')
      targetChecksum = md5(targetChecksum, lci_h.rtwChecksum);
    end
  end
end

linkMachineChecksum = [];
isPc = ~isunix;
isLibrary = sf('get',thisMachine,'machine.isLibrary');
if(~isLibrary)
    [linkMachineList,linkLibFullPaths] = get_link_machine_list(machineName,sf('get',thisTarget,'target.name'));
    for i = 1:length(linkLibFullPaths)
        if isPc
            linkMachineChecksum = md5(linkMachineChecksum,lower(linkLibFullPaths{i}));
        else
            linkMachineChecksum = md5(linkMachineChecksum,linkLibFullPaths{i});
        end
    end
end

chartList = get_instantiated_charts_in_machine(thisMachine);
chartFileNumbers = sf('get', chartList, 'chart.chartFileNumber');
[sortedNums, sortedIndices] = sort(chartFileNumbers);
chartList = chartList(sortedIndices);

numCharts = length(chartList);
specializations = cell(1, numCharts);
for i = 1:numCharts
    specializations{i} = sf('Cg', 'get_module_specializations', chartList(i));
    if (length(specializations{i}) == 1)
        specializations{i} = []; %TLTODO: necessary only if we try to be backward compatible with chart file names
    end
end

customCodeSettings = sfc('private','get_custom_code_settings',thisTarget,parentTarget);

makefileChecksum = md5(sf('get',chartList,'chart.chartFileNumber')'...
    ,specializations...
    ,sf('get',chartList,'chart.exportChartFunctions')'...
    ,customCodeSettings.userSources...
    ,customCodeSettings.userLibraries...
    ,linkMachineChecksum...
    ,targetChecksum);

% Fixed G246760: makefileChecksum as used to compute the final
% target-checksum should not involve the compiler and matlabroot.
% The reason is as follows: When we have a prebuilt DLL, which is 
% uptodate with the model, we should rebuild it just because we have a 
% different MATLABROOT => breaks our demos which are supposed to simulate
% out of the box without code-regeneration. However, once we decide to 
% regenerate the code because of genuine model-changes, we should 
% use a checksum consisting of all the elements that affect the generated
% makefile => matlabroot, the name of the compiler etc.
% not doing it causes strange errors when model directories are copied from
% one machine to another.
compilerInfo = compilerman('get_compiler_info');
actualMakefileChecksum = md5(makefileChecksum,matlabroot,compilerInfo.compilerName,compilerInfo.mexOptsFile);
sf('set',thisMachine,'machine.makefileChecksum',actualMakefileChecksum);

sf('set',thisTarget,'target.checksumSelf',targetChecksum);

machineChecksum = sf('get',thisMachine,'machine.checksum');
%%% machine parameter data initial values are added to machine checksum only for RTW target
if strcmp(targetName, 'rtw')
    ivs = get_machine_parameter_initial_value(thisMachine);
    if ~isempty(ivs)
        machineChecksum = md5(machineChecksum, ivs);
        sf('set', thisMachine, 'machine.checksum', machineChecksum);
    end
end

machineChartChecksum = sf('get',thisMachine,'machine.chartChecksum');
exportedFcnChecksum = sf('get',mainMachine,'machine.exportedFcnChecksum');
sf('set',thisMachine,'machine.exportedFcnChecksum',exportedFcnChecksum);
sfVersionString = sf('Version','Number');

%%% this is where we combine all sorts of checksums to form an aggregated
%%% target checksum.
%%% if you are lost say zzyzx thrice. look for it in autobuild.m before
%%% changing this magical line.
newChecksum = md5(exportedFcnChecksum,makefileChecksum,targetChecksum,machineChecksum,machineChartChecksum,sfVersionString);


sf('set',thisTarget,'.checksumNew',newChecksum);
savedChecksum = sf('get',thisTarget,'.checksumOld');

targetChanged = any(newChecksum ~= savedChecksum);

if sf('feature','EML UseMatlabPath')
    sync_eml_resolved_functions(thisMachine,mainMachine,thisTarget);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ivs = get_machine_parameter_initial_value(machine)

ivs = {};
mds = sf('DataOf', machine);
mps = sf('find', mds, 'data.scope', 'PARAMETER_DATA');
if ~isempty(mps)
    % Get sorted (by SSID) machine parameters
    [~, idx] = sort(sf('get', mps, 'data.ssIdNumber'));
    mps = mps(idx);
    ivs = cell(1, length(mps));
    for i = 1:length(mps)
        info = sf('DataParsedInfo', mps(i));
        ivs{i} = info.initialval;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  targetChecksum = ck_target(target,parentTarget,mainMachine)
targetName = sf('get',target,'target.name');
mainMachineName = sf('get',mainMachine,'machine.name');
if(strcmp(targetName,'rtw'))
    targetProps = sfc('private','rtw_target_props',mainMachineName);
    %% By this point, the TFL tables must have benn loaded.
    locTflCtrl = get_param(mainMachineName, 'TargetFcnLibHandle');
    tflCheckSumStruct = locTflCtrl.getIncrBuildNum();
    targetChecksum = md5(...
        targetName...
        ,targetProps...
        ,sfc('coder_options')...
        ,tflCheckSumStruct);
else    
    [algorithmWordsizes,targetWordsizes,algorithmHwInfo,targetHwInfo,rtwSettingsInfo] = sfc('private','get_word_sizes',mainMachineName,targetName);

    try
      gencpp = rtwprivate('rtw_is_cpp_build', mainMachineName);
    catch ME
      gencpp = 0;
    end
    targetChecksum = md5(...
        targetName...
        ,get_target_props(parentTarget,'.codeFlags')...
        ,sf('get',parentTarget,'target.reservedNames')...
        ,algorithmWordsizes...
        ,targetWordsizes...
        ,algorithmHwInfo...
        ,targetHwInfo...
        ,rtwSettingsInfo...
        ,gencpp...
        ,sfc('coder_options'));
    
    if strcmp(targetName, 'sfun')
        % If ext mode is on, sfun target uses unified dwork.
        extModeSetting = sfc('private','get_machine_extmode_setting',mainMachineName);
        targetChecksum = md5(targetChecksum, extModeSetting);
    end
end

customCodeSettings = sfc('private','get_custom_code_settings',target,parentTarget);
targetChecksum = md5(targetChecksum...
                     ,customCodeSettings.customCode...
                     ,customCodeSettings.customSourceCode...
                     ,customCodeSettings.userIncludeDirs...
                     ,customCodeSettings.reservedNames...
                     ,customCodeSettings.customInitializer...
                     ,customCodeSettings.customTerminator...
                     ,feature('CGForceUnsignedConsts'));
%%
%% CGForceUnsignedConsts - optionally turn on/off forcing the U suffix to be 
%%                         generated for unsigned constants that fit into 
%%                         its signed equivalent.
%%


function debug_checksums(doit,str,objectId)
if(doit)
    if(length(objectId)==1)
        % silly hack to handle an object directly.
        checksum = sf('get',objectId,'.checksum');
    else
        checksum = objectId;
        objectId = 0;
    end
    fp = fopen('debug.txt','a');
    fprintf(fp,'%u %u %u %u == (#%d)%s\n',checksum(1),checksum(2),checksum(3),checksum(4),objectId,str);
    fclose(fp);
end
