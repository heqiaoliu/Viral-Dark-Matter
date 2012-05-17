function result = sf_rtw(commandName, varargin)
% SF_RTW Extract Stateflow information required for RTW build for
% Stateflow versions 1.1 and above
%
%   SF_RTW is called from inside TLC to extract the necessary
%   Stateflow information which is required for the RTW build.
%   In particular, RTW needs to know the unique names that Stateflow
%   uses for its input data, output data, input events, output
%   events, chart workspace data, and machine workspace data.  The
%   underlying motivation is that RTW must create a list of hash
%   defines for Stateflow since RTW creates these data under a
%   different name.

%   Copyright 1994-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.19 $

switch(commandName)
    case 'get_value'
        varName = varargin{1};
        result = evalin('base',varName);
        if(strcmp(class(result),'Simulink.Parameter'))
            result = result.Value;
        end
        result = double(result);
    case 'process_tag'
        tag = varargin{1};
        tagLength = length('Stateflow S-Function');
        if(length(tag)>tagLength)
            tag = tag(1:tagLength);
        end
        if(strcmp(tag,'Stateflow S-Function'))
            result = 'Yes';
        else
            result = 'No';
        end
    case 'get_block_info'
        result = get_block_info(varargin{1},varargin{2});
    case 'get_machine_info'
        result = get_machine_info(varargin{1});
    case 'get_machine_headers'
        result = get_machine_headers(varargin{1});
    case 'get_custom_code_info'
        result = [];
        machineName = varargin{1};
        machineId = sf('find',sf('MachinesOf'),'machine.name',machineName);
        if(isempty(machineId))
            return;
        end

        targets = sf('TargetsOf',machineId);
        rtwTarget = sf('find',targets,'target.name','rtw');

        customCodeSettings = [];

        linkMachines = get_link_chart_file_numbers(machineName);
        for i=1:length(linkMachines)
            linkMachineId = sf('find','all','machine.name',linkMachines{i});
            linkRtwTarget  = acquire_target(linkMachineId,'rtw');
            customCodeSettingsForLink = sfc('private','get_custom_code_settings',linkRtwTarget,rtwTarget);
            customCodeSettings = append_custom_code_settings(customCodeSettings,customCodeSettingsForLink);
        end
        result = customCodeSettings;
    case 'get_sf_makeinfo'
        machineName = varargin{1};
        machineId = sf('find',sf('MachinesOf'),'machine.name',machineName);
        result = {};
        if ~isempty(machineId) && machineId ~= 0
            targets = sf('TargetsOf',machineId);
            rtwTarget = sf('find',targets,'target.name','rtw');
            result = sfc('makeinfo',rtwTarget,rtwTarget);
        end
    case 'usesDSPLibrary'
        % WARNING: This function has a side-effect of generating a header file in
        % the shared-utilities directory or the model directory (if the
        % shared-utilities directory is not available) if the result is true.
        % Therefore this function should only be called from the generated TLC.
        % NOTE: this is deprecated.
        result = false;

    case 'update_sf_include_libraries'
        % deprecated
        sfcnPathArray = varargin{2};
        result = sfcnPathArray;
    case 'buildStateflowTarget'
        result = 0;
end

return;

function c = append_custom_code_settings(c,cLink)

if(isempty(c))
    c = cLink;
else
    c.customCode = append_non_empty_strs(c.customCode,...
        cLink.customCode);
    c.userIncludeDirs = append_non_empty_strs(c.userIncludeDirs,...
        cLink.userIncludeDirs);
    c.userSources = append_non_empty_strs(c.userSources,...
        cLink.userSources);
    c.userLibraries = append_non_empty_strs(c.userLibraries,...
        cLink.userLibraries);
    c.reservedNames = append_non_empty_strs(c.reservedNames,...
        cLink.reservedNames);
end

function str = append_non_empty_strs(str,newStr)
if(isempty(str))
    str = newStr;
elseif(isempty(newStr))
    return;
else
    str = [str,10,newStr];
end

% Function: get_block_info =====================================================
% Abstract:
%	Only called if we have stateflow blocks in the model. Probe into
%       stateflow and return the rtw block info
%
function sfNames = get_block_info(tag,mainMachineName)

info = regexp(tag, '^Stateflow S-Function\s+(?<mn>\w+)\s+(?<fn>\d+)\s+(?<spec>\w+)$', 'names', 'once');
machineName = info.mn;
chartFileNumber = str2double(info.fn);
specialization = info.spec;

if (isempty(chartFileNumber) || isempty(specialization))
    error('Stateflow:UnexpectedError',['Please run sfconv20 in this directory to convert all old ', ...
        'library models.']);
end

infoStruct = infomatman('load','binary',machineName,mainMachineName,'rtw');

instanceIdx = [];
chartNumber = find(infoStruct.chartFileNumbers==chartFileNumber);
if ~isempty(chartNumber)
    instanceIdx = find(strcmp({infoStruct.chartInfo(chartNumber).instanceInfo.specialization}, specialization));
end

if (isempty(chartNumber) || isempty(instanceIdx))
    machineId = sf_force_open_machine(machineName);
    goto_target(machineId,'rtw');
    error('Stateflow:UnexpectedError','The Stateflow-RTW target of %s needs to be rebuilt. Please choose rebuild all option',machineName);
end

sfNames = 'StateflowVersion';
sfNames = strrows(sfNames, sprintf('%f',sf('Version',1)));

sfNames = strrows(sfNames, 'ChartInLibrary');
sfNames = strrows(sfNames, infoStruct.isLibrary);

sfNames = strrows(sfNames, 'InlineChart');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).instanceInfo(instanceIdx).Inline);

sfNames = strrows(sfNames, 'ChartTLCFile');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).instanceInfo(instanceIdx).TLCFile);

sfNames = strrows(sfNames, 'ChartInitializeFcn');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).instanceInfo(instanceIdx).InitializeFcn);

sfNames = strrows(sfNames, 'ChartOutputsFcn');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).instanceInfo(instanceIdx).OutputsFcn);

sfNames = strrows(sfNames, 'InputDataCount');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).InputDataCount);

sfNames = strrows(sfNames, 'InputEventCount');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).InputEventCount);

sfNames = strrows(sfNames, 'NoInputs');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).NoInputs);

return;

% Function: get_machine_info ===================================================
% Abstract:
%	Only called if we have stateflow blocks in the model. Probe into
%       stateflow and return the rtw names.
%
function sfNames = get_machine_info(machineName)

infoStruct = infomatman('load','binary',machineName,machineName,'rtw');

if(isempty(infoStruct.machineTLCFile))
    machineId = sf_force_open_machine(machineName);
    goto_target(machineId,'rtw');
    error('Stateflow:UnexpectedError','The Stateflow-RTW target of %s needs to be rebuilt. Please choose rebuild all option',machineName);
end

sfNames = infoStruct.machineTLCFile;
sfNames = strrows(sfNames, infoStruct.machineInlinable);
sfNames = strrows(sfNames, machineName);
srcDirectory = get_sf_proj(pwd,machineName,machineName,'rtw','src');
sfNames = strrows(sfNames, srcDirectory);

linkMachines = get_link_machine_list(machineName,'rtw');

for i=1:length(linkMachines)
    infoStruct = infomatman('load','binary',linkMachines{i},machineName,'rtw');
    sfNames = strrows(sfNames, infoStruct.machineTLCFile);
    sfNames = strrows(sfNames, infoStruct.machineInlinable);
    sfNames = strrows(sfNames, linkMachines{i});
    srcDirectory = get_sf_proj(pwd,machineName,linkMachines{i},'rtw','src');
    sfNames = strrows(sfNames, srcDirectory);
end
%end get_machine_info

% Function: get_machine_headers ===========================================
function hdrNames = get_machine_headers(machineName)
auxInfo = get_aux_buildinfo(machineName);
if ~isempty(auxInfo.includeFiles)
    includeFiles = auxInfo.includeFiles;
    includeFiles{end+1} = ''; % Ensure TLC sees a vector of strings
    hdrNames = strrows(includeFiles{:});
else
    hdrNames = [];
end

% Function: get_aux_buildinfo =============================================
function auxInfo = get_aux_buildinfo(machineName)
auxInfo = auxInfoConstruct();
infoStruct = infomatman('load','binary',machineName,machineName,'rtw');
if isfield(infoStruct, 'chartInfo') && isfield(infoStruct.chartInfo, 'auxBuildInfo')
    auxInfos = [infoStruct.chartInfo(:).auxBuildInfo];
    for i=1:numel(auxInfos)
        auxInfo = auxInfoUpdate(auxInfo, auxInfos(i));
    end
end
auxInfo = auxInfoUnique(auxInfo);
