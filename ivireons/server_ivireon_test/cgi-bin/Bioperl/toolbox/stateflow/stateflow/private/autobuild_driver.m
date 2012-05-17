function status = autobuild_driver(buildType,machineId,targetName,showNags,dontUpdateDiagram,chartHandle)

% Copyright 2003-2010 The MathWorks, Inc.

if (nargin < 6)
    % *** For HDL target with buildType "buildchart" only!
    % Pass in chartHandle(scalar or vector) to only generate HDL code for this chart(s).
    chartHandle = [];
end

if(nargin<5)
    % this is needed for quickly generating code for a model
    % without doing update diagram. Very useful for testing
    % custom target codegen for fuly specified models that
    % may not update for other reasons. For example, Honeywell model
    % work only on PC and we can use this to lock down codegen on UNIX.
    dontUpdateDiagram = 0;
end
if(nargin<4)
    showNags = 0;
end
if(ischar(dontUpdateDiagram))
    dontUpdateDiagram = strcmp(dontUpdateDiagram,'yes');
end
if(ischar(showNags))
    showNags = strcmp(showNags,'yes');
end
status = 0;
[machineId,machineName] = unpack_machine_id(machineId);
if sf('get', machineId, '.deleted'), return; end;

if strcmp(targetName, 'hdl')
    % Valid targetNames include: 'slhdlc', 'rtw', 'sfun', 'plc', 'testgen'
    construct_error(machineId, 'Build',...
                    'The ''hdl'' target is not supported by Stateflow (autobuild_driver).', 1 );
    status = 1;
    slsfnagctlr('Create',machineName,sllasterror);
    return;
end

SLPerfTools.Tracer.logStateflowData('sf_compile', machineName, targetName, machineName, 'machine', ['autobuild_' buildType], true);
switch(lower(buildType))
    case 'pre_link_resolve'
        set_model_status_bar(machineName,'Update Stateflow, Embedded MATLAB Parameters');
        sf_compile_stats('snap', machineName, targetName, 'pre_link_resolve_start');
        machine_bind_sflinks(machineId,1);
        sync_on_precompile_and_presave(machineId, true);
        
        linkMachines = get_link_machine_list(machineId, 'sfun');
        for i = 1:length(linkMachines)
            linkMachine = sf('find',sf('MachinesOf'),'machine.name',linkMachines{i});
            sync_on_precompile_and_presave(linkMachine, true);
            sf('set',linkMachine,'machine.mainMachine',machineId);
        end
        
        Stateflow.SLINSF.SubchartMan.preLinkResolvePass2(machineId);
        
        eml_man('update_ui_state',machineId,'build');
        sf_compile_stats('snap', machineName, targetName, 'pre_link_resolve_end');
        set_model_status_bar(machineName);
    case 'setup'
        set_model_status_bar(machineName,'Initialize Stateflow, Embedded MATLAB Compilation');
        sf_compile_stats('snap', machineName, targetName, 'autobuild_setup_start');
        %G348316. Certain types of setup is better to do as late as possible
        % and definitely after post link resolve.
        sf('Cg','reset_all_chart_compiled_info_in_machine',machineId);

        sf('Cg', 'construct_type_container_context', machineId);
        linkMachines = get_link_machine_list(machineId, 'sfun');
        for i = 1:length(linkMachines)
            linkMachine = sf('find',sf('MachinesOf'),'machine.name',linkMachines{i});
            sf('Cg','reset_all_chart_compiled_info_in_machine',linkMachine);
            sf('Cg', 'construct_type_container_context', linkMachine);
            sf('set',linkMachine,'machine.mainMachine',machineId); % paranoid set just in case we missed it above in pre_link_resolve
        end
        setup_machine_data_properties(machineId, 'CompileDataProperties');
        sf_compile_stats('snap', machineName, targetName, 'autobuild_setup_end');
        set_model_status_bar(machineName);
    case 'simbuild'
        %G453147: Config subsystems makes links come and go during 
        % evalparams phase. We need to recompute the set of used links
        % as this is the best possible time to do this. Otherwise, 
        set_model_status_bar(machineName,'Stateflow, Embedded MATLAB Simulation Target Update');
        refresh_instantiated_links(machineId);
        setup_machine_diagnostic_settings(machineId);
        sf_compile_stats('snap', machineName, targetName, 'simbuild_start');
        modelH = sf('get', machineId, '.simulinkModel');
        switch get_param(modelH, 'simulationstatus')
            case 'initializing'
            case 'stopped'
            case 'updating'
            otherwise, return;
        end
        lasterr('');

        % Since the Stateflow S-function does not support non-contiguous
        % memory for its inputs, we need to make sure that the outputs from
        % any internal SL functions are not non-contiguous.
        check_for_non_contig_outputs_from_slfcns(machineId);
        
        % we should do this really late as the machine parented data are
        % needed only for non-sfun targets and they may not be set up
        % during 'setup' phase above.
        setup_machine_data_properties(machineId, 'FillParameterInitialValuesSafely');
        % for simbuild, we ignore the shownags that's passed in and
        % always use no as we an error to be thrown.
        status = autobuild_kernel(machineId,'sfun','build','no','no');
        set_model_status_bar(machineName);

        if ~status
            set_model_status_bar(machineName,'Stateflow, Embedded MATLAB RTW Target Update');
            hMakeRTWSettingsObject = get_param(modelH, 'MakeRTWSettingsObject');
            if ~isempty(hMakeRTWSettingsObject) && ~isempty(hMakeRTWSettingsObject.BuildOpts)
                if(~strcmp(hMakeRTWSettingsObject.BuildOpts.codeFormat,'Accelerator_S-Function'))
                    status = autobuild_kernel(machineId,'rtw','build','no','no');
                end
            elseif ~rtwenvironmentmode(sf('get',machineId,'machine.name'))
                % we do this because we found that there are calls to rtwgen
                % from outside the make_rtw harness in test-harnesses (e.g. kai's code reuse)
                % instead of bailing, we use pete's earlier suggestion to see
                % if we need to generate TLC
                status = autobuild_kernel(machineId,'rtw','build','no','no');
            end
            set_model_status_bar(machineName);
        end
        clear_simstruct_in_machine(machineId);
        sf_compile_stats('snap', machineName, targetName, 'simbuild_end');
    case 'clean'
        clean_target(machineId,targetName);
    case 'clean_objects'
        clean_target(machineId,targetName,1);
    case {'build','rebuildall','buildchart'}
        status = 0;
        slsfnagctlr('Clear');
        if strcmpi(buildType, 'rebuildall')
            autobuild_driver('clean',machineId,targetName);
        end

        if(~strcmp(targetName,'slhdlc'))
            try
                if(model_is_a_library(machineName))
                    autobuild_driver('pre_link_resolve',machineId,'sfun');
                    autobuild_driver('setup',machineId,'sfun');
                    status = local_build(buildType, machineId, targetName, showNags);
                elseif(~dontUpdateDiagram)
                    set_param(machineName,'SimulationCommand','update');
                    if(showNags)
                        nag             = slsfnagctlr('NagTemplate');
                        nag.type        = 'Log';
                        nag.msg.details =  sprintf('Model Compilation for %s successful.', machineName);
                        nag.msg.type    = 'Build';
                        nag.msg.summary = 'build log';
                        nag.component   = 'Stateflow';
                        nag.sourceHId   = machineId;
                        nag.ids         = machineId;
                        nag.blkHandles  = [];
                        slsfnagctlr('Naglog', 'push', nag);
                    end
                else
                    autobuild_driver('pre_link_resolve',machineId,'sfun');
                    setup_machine_data_properties(machineId, 'CompileDataPropertiesRecursivelyInMachine');
                end
            catch
                status = 1;
                slsfnagctlr('Create',machineName,sllasterror);
            end
        end

        if (status)
            report_error(showNags);
        else
            switch targetName
                case 'sfun'
                    if(showNags)
                        slsfnagctlr('View');
                        symbol_wiz('View', machineId);
                    end
                case 'rtw'
                    rtwbuild(machineName);
                otherwise
                    status = local_build(buildType, machineId, targetName, showNags, chartHandle);
            end
        end
    case 'make'
        status = autobuild_kernel(machineId,targetName,'make','no',showNags);
end
SLPerfTools.Tracer.logStateflowData('sf_compile', machineName, targetName, machineName, 'machine', ['autobuild_' buildType], false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  refresh_instantiated_links(machineId)

allSfLinks = sf('get',machineId,'machine.sfLinks');
allCharts = zeros(size(allSfLinks));
for i=1:length(allSfLinks)
    allCharts(i) = block2chart(allSfLinks(i));
end
allCharts = unique(allCharts);
allMachines = unique(sf('get',allCharts,'.machine'));
sf('flag','chart.isInstantiated','show/write');
for i=1:length(allMachines)
   charts = sf('get',allMachines(i),'machine.charts');
   sf('set',charts,'.isInstantiated',0);
end
sf('set',allCharts,'.isInstantiated',1);
sf('flag','chart.isInstantiated','show');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function status = local_build(buildType, machineId, targetName, showNags, chartHandle)
% Call autobuild_kernel with different settings based on build type

switch(lower(buildType))
    case 'rebuildall'
        status = autobuild_kernel(machineId,targetName,'build','yes',showNags);
    case 'build'
        status = autobuild_kernel(machineId,targetName,'build','no',showNags);
    case 'buildchart'
        chartId = block2chart(chartHandle);
        status = autobuild_kernel(machineId,targetName,'build','no',showNags,chartId,chartHandle);
    otherwise
        error('Stateflow:UnexpectedError','autobuild_driver: Unknown build type "%s".', buildType);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function report_error(showNags)

if(showNags)
    slsfnagctlr('View');
else
    nags = slsfnagctlr('GetNags');
    if isempty(nags)
        rethrow(lasterror);
    else
        nag = nags(end);
        error('Stateflow:BuildError','%s',nag.msg.details);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setup_machine_data_properties(machineId, compileFcn)
if sf('feature','EML UseMatlabPath')
    sync_eml_resolved_functions(machineId,machineId,'sfun');
end
evil_fbt_listener('simsetup',machineId);
sf(compileFcn, machineId);
linkMachines = get_link_machine_list(machineId, 'sfun');
for i = 1:length(linkMachines)
    linkMachine = sf('find',sf('MachinesOf'),'machine.name',linkMachines{i});
    if sf('feature','EML UseMatlabPath')
        sync_eml_resolved_functions(linkMachine,machineId,'sfun');
    end
    evil_fbt_listener('simsetup',machineId);
    sf(compileFcn, linkMachine);
end
