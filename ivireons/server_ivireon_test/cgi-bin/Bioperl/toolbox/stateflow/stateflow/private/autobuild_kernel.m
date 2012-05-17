function status = autobuild_kernel(machineId,targetName,buildType,rebuildAllFlag,showNags,chartId,chartHandle)
% DONT CALL THIS DIRECTLY. CALL AUTOBUILD_DRIVER INSTEAD
% STATUS = AUTOBUILD_KERNEL( MACHINENAMEORID,
%                     TARGETNAME,
%                     BUILDTYPE={'parse','code','make','build'},
%                     REBUILDALLFLAG={'yes','no'}, %% relevant only if BUILDTYPE is 'code' or 'build'
%                     SHOWNAGS={'yes','no'})
%                     CHARTID (relevant only if buildtype is "parse" and you want to parse single chart)
%                             (OR if buildtype is "build" and target is "slhdlc" to gen hdl for specified chart(s))
%                     CHARTHANDLE (relevant only for "slhdlc" target, the actual chart instance block handle.)

%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.32.2.1 $  $Date: 2010/06/17 14:14:02 $




    status = 0;

    [machineId,machineName] = unpack_machine_id(machineId);

    if (nargin<3),   buildType          = 'build'; end;
    if (nargin<4),   rebuildAllFlag = 0;       end;
    if (nargin<5),   showNags       = 1;   end;
    if (nargin<6),   chartId        = [];   end;
    if (nargin<7),   chartHandle    = [];   end;

    if(ischar(rebuildAllFlag))
        rebuildAllFlag = strcmp(rebuildAllFlag,'yes');
    end
    if(ischar(showNags))
        showNags = strcmp(showNags,'yes');
    end
    if(strcmp(targetName,'rtw'))
        if ~sf('Feature', 'RTW Incremental CodeGen')
            rebuildAllFlag = 1;
        end
    end

    % when chartId is specified, we are generating code for a single chart.
    % and not the entire model (e.g. HDL target using makehdl)
    % In this case, dont even bother with any pretense of
    % doing incremental codegen. This bypasses some subtle bugs that arise
    % from our (mis)management for infomat files.
    if(~isempty(chartId))
        rebuildAllFlag = 1;
    end


    slsfnagctlr('Clear', machineName, 'Stateflow Builder');
    sfdebug('sf','build_start',machineId);
    lasterr('');
    try
        status = autobuild_local(machineId,targetName,rebuildAllFlag,buildType,chartId,chartHandle);
    catch
        sfdebug('sf','build_end',machineId);
        if ~showNags
            rethrow(lasterror);
        end
    end

    if(showNags),
        slsfnagctlr('ViewNaglog');
        symbol_wiz('View', machineId);
    end

%------------------------------------------------------------------------------------------------------
function status = autobuild_local(machineId,targetName,rebuildAllFlag,buildType,chartId,chartHandle)
%
%
%

    status = 0;
    ted_the_editors(machineId);
    machineName = sf('get',machineId,'.name');
    targetId  = acquire_target(machineId,targetName);
    applyToAllLibs = 1; %sf('get',targetId,'target.applyToAllLibs');
    modelIsLibrary = sf('get',machineId,'machine.isLibrary');
    assert(~modelIsLibrary,'autobuild_kernel should not be called for a library');
    [linkMachines,linkLibFullPaths,sfLinkInfoFullPaths] = get_link_machine_list(machineName,targetName);
    %%%early return if the machine does not need code gen. i.e. no charts or links
    if(isempty(linkMachines) && isempty(sf('get',machineId,'machine.charts'))),

        if (slfeature('LegacyCodeIntegration') == 1)
            [customCode dummy] = legacycode.util.lci_getSettings(machineName, 0);
            if isempty(customCode.customCode) || all(isspace(customCode.customCode))
              return;
            else
              newModelH = get_param(machineName, 'handle');
              machineId = acquire_or_create_machine_for_model(newModelH);
              [linkMachines,linkLibFullPaths,sfLinkInfoFullPaths] = get_link_machine_list(machineName,targetName);
            end
        else
            return;
        end
    end


    % If we are here, the model has atleast one SF chart or linkchart
    % Do some error checking
    do_code_license_checking_if_needed(machineName,machineId,targetName);
    errorStr =  check_for_long_model_name(machineName);
    if(~isempty(errorStr))
        construct_error(machineId, 'Build', errorStr, 1);
    end
    if(strcmp(targetName,'rtw'))
        % G280766
        error_check_constant_local_data_name_collisions(machineId,linkMachines);
    end

    % Handle the non-standard calls to autobuild specially so as to
    % not clutter the handling for sfun/rtw targets below
    switch(buildType)
      case {'parse','make'}
        status = targetman(buildType,targetId,0,rebuildAllFlag,targetId,chartId,machineId);
        return;
      case 'build'
        if(~isempty(chartId) && strcmp(targetName, 'slhdlc'))
            machineOfChart = sf('get',chartId,'chart.machine');
            targetOfChart = acquire_target(machineOfChart,targetName);
            status = targetman(buildType,targetOfChart,0,rebuildAllFlag,targetOfChart,chartId,machineOfChart,[],chartHandle);
            return;
        end
    end

    %%%% 20feb2002:vijay: we must compute the exported_fcn_info before we call
    %%%% sync target.
    update_exported_fcn_info(machineId,targetName,linkMachines);
    perform_model_reference_error_checks(machineName);

    if strcmp(targetName, 'sfun')
        do_post_prop_error_checks(machineId, linkMachines);
    end

    % Now we have reached the heart of the incremental codegen
    % First we check if the main machine or any of the library machine
    % checksums are different from what is in the DLL and/or the infomatfiles
    % irrespective of the rebuild-all flag, we need to run sync_target so all
    % checksums are in order
    sync_target(targetId, targetId,machineId);
    checksumChanged = has_checksum_changed(machineName,machineName,targetName);
    for i=1:length(linkMachines)
        linkMachineTarget = acquire_target(linkMachines{i},targetName);
        if(applyToAllLibs)
            parentTargetId = targetId;
        else
            parentTargetId = linkMachineTarget;
        end
        sync_target(linkMachineTarget,parentTargetId,machineId);
        checksumChanged = checksumChanged + has_checksum_changed(machineName,linkMachines{i},targetName);
    end
    if rebuildAllFlag
        %%% to be on the safe side
        checksumChanged = 1;
    end

    if(checksumChanged==0)
        if (slfeature('LegacyCodeIntegration') == 1) && ~isempty(sf('get',targetId,'target.makeInfo'))
            %% and do not ignore change in custom code
            status = targetman('make',targetId,0,rebuildAllFlag,targetId,chartId,machineId);
        end
        return;
    end

    % If we are here, we are committed to generating code for atleast one model
    % Do some error checking on the current directory
    error_check_current_dir(machineId);

    for i=1:length(linkMachines)
        mustRebuildLibrary = rebuildAllFlag || ...
                             ~exist(linkLibFullPaths{i},'file') || ...
                             ~exist(sfLinkInfoFullPaths{i},'file'); % Needed for adding library "auxInfo.linkFlags" to main machine make file.
        if(mustRebuildLibrary || has_checksum_changed(machineName,linkMachines{i},targetName))
            sf_display('Autobuild',sprintf('Rebuilding library model %s.\n',linkMachines{i}));
            linkMachineTarget = acquire_target(linkMachines{i},targetName);
            if(applyToAllLibs)
                parentTargetId = targetId;
            else
                parentTargetId = linkMachineTarget;
            end
            try
                status = targetman(buildType,linkMachineTarget,0,mustRebuildLibrary,parentTargetId,chartId,machineId);
            catch ME
                construct_error(machineId, 'Build', 'Library failed to build. Cannot continue build process.', 1);
            end
        end
    end

    status = targetman(buildType,targetId,0,rebuildAllFlag,targetId,chartId,machineId);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = in_xlate_mode(machineName)
    out = false;
    try
        value = get_param(machineName,'RTWExternMdlXlate');
        out = (value ~= 0);
    catch ME %#ok<NASGU>
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function error_check_current_dir(machineId)

    matlabBin = lower(fullfile(matlabroot,'bin'));
    currentDir = lower(pwd);


    if (length(matlabBin)<=length(currentDir) && strcmp(matlabBin,currentDir(1:length(matlabBin)))),
        str = sprintf('The current directory is %s, which is reserved for MATLAB files.',currentDir);
        str = [str,10,10,...
               'Please change your current directory to a writable directory preferably outside of MATLAB installation area.'];
        construct_error(machineId,'Build',str,1,[]);
    end

   
    matlabBin = lower(fullfile(matlabroot,'test'));
    % G571796. We now prevent code generation in test directories. If developer feature
    % is on, it means this is a developer sandbox and the developer needs this
    % convenience and we do not error out.
    if (~sf('feature','developer') && length(matlabBin)<=length(currentDir) && strcmp(matlabBin,currentDir(1:length(matlabBin)))),
        str = sprintf('The current directory is %s, which is reserved for MATLAB files.',currentDir);
        str = [str,10,10,...
               'Please change your current directory to a writable directory preferably outside of MATLAB installation area.'];
        construct_error(machineId,'Build',str,1,[]);
    end


    if (strncmp('\\',currentDir,2))
        errorMsg = 'DOS commands may not be executed when the current directory is a UNC pathname ';
        errorMsg = [errorMsg,10,10,...
                    'Please change the current directory to a local directory or use a network drive mapped to the current directory.'];
        construct_error( [], 'Build', errorMsg, 1, []);
    end

    if (~isempty(strfind(currentDir,'#')))
        errorMsg = 'When the current directory contains a ''#'' character, it causes the generated makefiles to not work.';
        errorMsg = [errorMsg,10,10,...
                    'Please change the current directory to a different directory path that does not have a ''#'' character in its name.'];
        construct_error( [], 'Build', errorMsg, 1, []);
    end

    if(isunix && ~isempty(regexp(currentDir,'\s', 'once' )))
        errorMsg = 'When the current directory contains a space character, it causes the generated makefiles to not work.';
        errorMsg = [errorMsg,10,10,...
                    'Please change the current directory to a different directory path that does not have a space character in its name.'];
        construct_error( [], 'Build', errorMsg, 1, []);

    end

function do_code_license_checking_if_needed(machineName,machineId,targetName)
    if strcmp(targetName,'rtw') && ...
            ~sfc('private','model_reference_sim_target',machineName) &&...
            ~strcmp('raccel.tlc',get_param(machineName,'SystemTargetFile')) &&...
            ~in_xlate_mode(machineName) &&...
            ~sf('License','coder',machineId)
        error('Stateflow:LicenseError','%s',['To build RTW with Stateflow blocks requires a valid ', ...
                            'Stateflow Coder license.']);
    end


function checksumChanged = has_checksum_changed(mainMachineName,machineName,targetName)

    targetId = acquire_target(machineName,targetName);
    newChecksum = sf('get',targetId,'.checksumNew');
    if(strcmp(targetName,'sfun'))
        infoStruct = infomatman('load','dll',machineName,mainMachineName,targetName);
    else
        infoStruct = infomatman('load','binary',machineName,mainMachineName,targetName);
    end
    oldChecksum = infoStruct.sfunChecksum;
    checksumChanged = ~isequal(oldChecksum,newChecksum);
