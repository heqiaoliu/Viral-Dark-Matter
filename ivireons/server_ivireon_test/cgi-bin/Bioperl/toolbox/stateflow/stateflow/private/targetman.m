function status = targetman(method, targetId, syncTarget, forceRebuildAll, parentTargetId,chartId,mainMachineId,auxiliaryInfo,hChart)
% STATEFLOW TARGET MANAGER
%   STATUS = TARGETMAN( METHOD, TARGETID, SYNCTARGET, FORCEREBUILDALL)

%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.89.4.40.2.1 $  $Date: 2010/06/17 14:14:03 $

[machineId,targetName,dialogFigure] = sf('get',targetId,'.machine','.name','.dialog');
machineName = sf('get',machineId,'.name');
sf('set',machineId,'machine.activeTarget',targetId);
sf('set',machineId,'machine.mainMachine',mainMachineId);
isSfunTarget = strcmp(targetName,'sfun');

SLPerfTools.Tracer.logStateflowData('sf_compile', machineName, targetName, machineName, 'machine', ['targetman_' method], true);

if nargin<3, syncTarget      = 0;        end;
if nargin<4, forceRebuildAll = 0;        end;
if nargin<5, parentTargetId  = targetId; end;
if nargin<6, chartId  = []; end; % sometimes you want to parse a single chart
if nargin<7, mainMachineId = [];end;
if nargin<8, auxiliaryInfo = []; end
if nargin<9, hChart = []; end

set_busy(dialogFigure);
status = 0; % Always return 0 for legacy

try
    if(strcmp(targetName,'sfun'))
        check_not_simulating( targetId, machineId,machineName, targetName);
    end;
    
    machineType = get_machine_type(machineId);
    
    switch method,
        case 'clean_objects'
         	msg = sprintf('%s clean target directory for model "%s"...',machineType,machineName);
         	sf_display('Coder',msg,2);
            method_nag_wrapper('Clean', 'clean_objects_method', targetId, parentTargetId, mainMachineId, syncTarget, forceRebuildAll);
         	msg = sprintf('Done\n');
         	sf_display('Coder',msg,2);
        case 'clean'
         	msg = sprintf('%s clean target directory for model "%s"...',machineType,machineName);
         	sf_display('Coder',msg,2);
            method_nag_wrapper('Clean', 'clean_method', targetId, parentTargetId, mainMachineId, syncTarget, forceRebuildAll);
         	msg = sprintf('Done\n');
         	sf_display('Coder',msg,2);
        case 'parse',
            parseLevel = 1; % no size/type checking
            method_nag_wrapper('Parse', 'parse_method', targetId, parentTargetId,mainMachineId, chartId,parseLevel);
        case 'code'
            % before codegen we must make sure the sfun
            % block has the correct set of params str.
            parseLevel = 2; % size/type checking done
            method_nag_wrapper('Parse', 'parse_method', targetId, parentTargetId, mainMachineId, [], parseLevel);
            method_nag_wrapper('Coder', 'code_method', targetId, parentTargetId, mainMachineId, chartId, syncTarget, forceRebuildAll);
        case 'construct_chart_ir_for_rtw'
            parseLevel = 2; % size/type checking done
            method_nag_wrapper('Parse', 'parse_method', targetId, parentTargetId,mainMachineId,chartId,parseLevel);
            
            status = construct_chart_ir_for_rtw( targetId, parentTargetId,mainMachineId,chartId,auxiliaryInfo,hChart);
        case 'make',
            method_nag_wrapper('Make',  'make_method', targetId, parentTargetId,mainMachineId);
        case 'build' 
         	msg = sprintf('%s parsing for model "%s"...',machineType,machineName);
         	sf_display('Coder',msg,2);
            set_model_status_bar(mainMachineId,msg);
            % before codegen we must make sure the sfun
            % block has the correct set of params str.
            parseLevel = 2; % size/type checking done
            method_nag_wrapper('Parse', 'parse_method', targetId, parentTargetId,mainMachineId,[],parseLevel);
         	msg = sprintf('Done\n');
         	sf_display('Coder',msg,2);
         	
            msg = sprintf('%s code generation for model "%s"...',machineType,machineName);
         	sf_display('Coder',msg,2);
            set_model_status_bar(mainMachineId,msg);
            method_nag_wrapper('Coder', 'code_method',  targetId, parentTargetId, mainMachineId, chartId, syncTarget, forceRebuildAll, hChart);
         	msg = sprintf('Done\n');
         	sf_display('Coder',msg,2);
         	
            if(isSfunTarget) 
                msg = sprintf('%s compilation for model "%s"...',machineType,machineName);
             	sf_display('Coder',msg,2);
                set_model_status_bar(mainMachineId,msg);
            end
            method_nag_wrapper('Make',  'make_method',  targetId, parentTargetId,mainMachineId);
            if(isSfunTarget) 
                msg = sprintf('Done\n');
                sf_display('Coder',msg,2);
            end
        case 'delete_target_sfunction_func'
            delete_target_sfunction_func(targetId);
        otherwise,
            construct_error(targetId,'Internal','Bad targetman method');
    end
    
catch
    if (isempty(lasterr))
        error('Stateflow:BuildError',slsfnagctlr('NagToken'));
    else  
        if suppress_lasterror()
            lasterror('reset');
        end
        rethrow(lasterror);
    end;
end;

set_idle(dialogFigure);
SLPerfTools.Tracer.logStateflowData('sf_compile', machineName, targetName, machineName, 'machine', ['targetman_' method], false);

%----------------------------------------------------------------------------------
function silent = suppress_lasterror()
le = lasterror;
silent = strcmp(le.identifier, 'Stateflow:mexCompiler');

%----------------------------------------------------------------------------------
function method_nag_wrapper(methodType, fcn, targetId, parentTargetId, mainMachineId, varargin)
%
%
%
[machineId,targetName] = sf('get',targetId,'.machine','.name');
machineName = sf('get', machineId, '.name');
SLPerfTools.Tracer.logStateflowData('sf_compile', machineName, targetName, machineName, 'machine', ['method_nag_wrapper' methodType], true);

methodTimeStart = clock;
log_file_manager('begin_log');

lasterr('');

try  
    if(strcmp(methodType,'Make'))   
        % Note: binaryDateNum is returned as a relevant value only by
        % make_method. Needed to dump into infomat file
        [status,fileNameInfo,binaryDateNum] = feval(fcn, targetId, parentTargetId,mainMachineId, varargin{:});
    else
        [status,fileNameInfo] = feval(fcn, targetId, parentTargetId,mainMachineId, varargin{:});
    end
catch 
    status = 1;
    fileNameInfo = [];
end;

logTxt = log_file_manager('get_log');
machineId = sf('get',targetId,'target.machine');

if ~isempty(logTxt),
    nag             = slsfnagctlr('NagTemplate');
    if status == 1
        nag.type = 'Error'; 
    else
        nag.type = 'Log'; 
    end;
    nag.msg.details = logTxt;
    nag.msg.type    = methodType;
    nag.msg.summary = '';
    nag.component   = methodType;
    nag.sourceName   = sf('get',machineId,'machine.name');
    nag.sourceFullName   = sf('get',machineId,'machine.name');
    nag.ids         = machineId;
    nag.blkHandles  = [];
    
    % Set the reference directory for the nag to be pushed.
    % this will be used by the slsfnagctlr to resolve relative
    % file links.
    switch (methodType)
        case {'Coder','Make'}
            if isempty(fileNameInfo)
                fileNameInfo = sfc('filenameinfo',targetId,parentTargetId,mainMachineId);
            end
            nag.refDir = fileNameInfo.targetDirName;
        case 'Parse'
            nag.refDir = '';
        otherwise,
            nag.refDir = '';
    end
    slsfnagctlr('Naglog', 'push', nag);
    
end;
log_file_manager('end_log');
%%% IMPORTANT PROFILING CODE:
%%% We measure the time taken for parse/code/make
%%% stages and cache it away on the target.

methodTime = etime(clock,methodTimeStart);
targetName = sf('get',targetId,'target.name');
switch(methodType)
    case 'Parse'
        sf('set',targetId,'target.time.parse',methodTime);
    case 'Coder'
        sf('set',targetId,'target.time.code',methodTime);
        if (strcmp(targetName,'rtw') && status == 0)
            % complete success deserves an update of the target checksum for rtwTarget
            % for all other targets we do this in make_method_mathod
            % Code generation successful. Copy meta data from sfun target
            copy_eml_meta_rebuild_info(machineId,mainMachineId,targetName);
            infomatman('save','binary',machineId,mainMachineId,targetId,now);
        end
        
    case 'Make'
        sf('set',targetId,'target.time.make',methodTime);
        %G36573. do not bother with infomatman updates for sfhdlc target
        if (~strcmp(targetName,'rtw') && ~strcmp(targetName,'slhdlc') && status == 0)
            % complete success deserves an update of the target checksum
            % for rtwTarget, we do this in code_mathod
            % Code generation successful. Copy meta data from sfun target
            copy_eml_meta_rebuild_info(machineId,mainMachineId,targetName);
            infomatman('save','binary',machineId,mainMachineId,targetId,binaryDateNum);
        end
     
end
if status == 1, 
    if(~isempty(logTxt))
        disp(logTxt);
    end
    rethrow(lasterror); 
end;
SLPerfTools.Tracer.logStateflowData('sf_compile', machineName, targetName, machineName, 'machine', ['method_nag_wrapper' methodType], false);


function copy_eml_meta_rebuild_info(machineId,mainMachineId,targetName)
if ~strcmp(targetName, 'sfun')
    rebuildMetaData = sf('get',mainMachineId,'.eml.rebuildMetaData');
    if ~isempty(rebuildMetaData)
         sync_eml_resolved_functions(machineId,mainMachineId,'sfun');
         rebuildMetaData = sf('get',mainMachineId,'.eml.rebuildMetaData');
         targetName0 = get_eml_metadata_target_name(targetName);
         machineName = sf('get',machineId,'machine.name');
         machineName0 = get_eml_metadata_machine_name(machineName);
         if isfield(rebuildMetaData, 'sfun') && isfield(rebuildMetaData.sfun, machineName0)
             rebuildMetaData.(targetName0).(machineName0) = rebuildMetaData.sfun.(machineName0);
             sf('set',machineId,'.eml.rebuildMetaData',rebuildMetaData);
         end
    end
end

%----------------------------------------------------------------------------------
function [status,fileNameInfo] = parse_method( targetId, parentTargetId,mainMachineId, chartId,parseLevel)
%
%
%
status = 0;
fileNameInfo = [];
machineId = sf('get',targetId,'target.machine');
ted_the_editors(machineId);

target_methods('preparse',targetId,parentTargetId);
throwError = parse_kernel(machineId,chartId,targetId,parentTargetId,mainMachineId,parseLevel);
target_methods('postparse',targetId,parentTargetId);
if(throwError)
    statusString = 'failed';
else
    statusString = 'successful';
end
if(isempty(chartId))
    sf_display('Parse',sprintf('Parsing %s for machine: "%s"(#%d)\n', statusString,sf('get',machineId,'.name'),machineId));
else
    sf_display('Parse',sprintf('Parsing %s for chart: "%s"(#%d)\n', statusString,sf('get',chartId,'.name'),chartId));
end

if(throwError)
    if(~isempty(lasterror))
        rethrow(lasterror);
    else
        error('Stateflow:BuildError',slsfnagctlr('NagToken'));
    end
end

%--------------------------------------------------------------------------
function [status fileNameInfo] = clean_objects_method( targetId, parentTargetId, mainMachineId, syncTarget ,forceRebuildAll) 
try
    fileNameInfo = sfc('clean_objects',targetId,parentTargetId,mainMachineId);
    status = delete_target_sfunction_func(targetId);
catch ME
    status = 1;
end

if status==1,
    sf_display('Coder',sprintf('Target directory clean failed %c\n\n',7));
end;


%--------------------------------------------------------------------------
function [status fileNameInfo] = clean_method( targetId, parentTargetId, mainMachineId, syncTarget ,forceRebuildAll) 

try
    fileNameInfo = sfc('clean',targetId,parentTargetId,mainMachineId);
    status = delete_target_sfunction_func(targetId);
catch ME
    status = 1;
end

if status==1,
    sf_display('Coder',sprintf('Target directory clean failed %c\n\n',7));
end;

%-----------------------------------------------------------------------------------
function [status,fileNameInfo] = code_method( targetId, parentTargetId, mainMachineId, chartId, syncTarget, forceRebuildAll, chartHandle)
%
%
%
if syncTarget==1
    sync_target(targetId,parentTargetId,mainMachineId);
end

machineId = sf('get',targetId,'.machine');

if(forceRebuildAll)
    codeMethod = 'codeNonIncremental';
else
    codeMethod = 'codeIncremental';
end

lasterr('');
try
    coder_error_count_man('reset');
    target_methods('precode',targetId,parentTargetId);
    fileNameInfo = sfc(codeMethod,targetId,parentTargetId,mainMachineId,chartId,[],chartHandle);
    target_methods('postcode',targetId,parentTargetId);
    status = coder_error_count_man('get')~=0;
catch
    status = 1;
    fileNameInfo = [];
end

if status==1
    if ~suppress_lasterror()
        sf_display('Coder',sprintf('Code generation failed %s%c\n\n',clean_error_msg(lasterr),7));
    end
else
    sf_display('Coder',sprintf('Code generation successful for machine: "%s"\n',sf('get',machineId,'.name')));
end;

%-----------------------------------------------------------------------------------
function status = construct_chart_ir_for_rtw( targetId, parentTargetId,mainMachineId,chartId,auxiliaryInfo,hChart)
%
%
%

try
    coder_error_count_man('reset');
    sfc('construct_chart_ir_for_rtw',targetId,parentTargetId,mainMachineId,chartId,auxiliaryInfo,hChart);
    status = coder_error_count_man('get')~=0;
    if(status)
        sf_display('Coder',sprintf('IR Construction failed%c\n\n',7));
    end
catch ME
    sf_display('Coder',sprintf('IR Construction failed%s%c\n\n',ME.message,7));
    status = 1;
end

if ~status==1
    sf_display('Coder',sprintf('IR Construction successful for chart: "%s"\n',sf('FullNameOf',chartId)));
end;


%---------------------------------------------------------------------------------------
function [status,fileNameInfo,binaryDateNum] = make_method( targetId,parentTargetId,mainMachineId ) %#ok<INUSD>
%
%
%
machineId = sf('get', targetId, '.machine');
machineName = sf('get',machineId,'.name');

targetName = sf('get',targetId,'target.name');

currDir = pwd;
[rootDir,isCustomRootDir] = get_sf_proj_root(currDir);
if(isCustomRootDir)
    cd(rootDir);
    c = onCleanup(@()cd(currDir));
end

simulationTarget = strcmp(targetName,'sfun');

%makeInfo = sfc('makeinfo',targetId,parentTargetId,mainMachineId);
%fileNameInfo = makeInfo.fileNameInfo;
fileNameInfo = sf('get',targetId,'target.makeInfo');

if simulationTarget
    status = delete_target_sfunction_func(targetId);
    if (status == 1), throw_make_error; end;
    
    str = sprintf('Making simulation target "%s", ... \n\n', fileNameInfo.mexFunctionName);
    sf_display('Make', str);
    
    if(ispc)
        makeCommand = ['call ',fileNameInfo.makeBatchFile];
    else
        gmake = [matlabroot,'/bin/',lower(computer),'/gmake'];
        makeCommand = [gmake,' -f ',fileNameInfo.unixMakeFile];
    end
    modelDirectory = pwd;
    
    safely_execute_dos_command(fileNameInfo.targetDirName,makeCommand);
    
    isLibrary = sf('get',machineId,'machine.isLibrary');
    if(isLibrary)
        if(isunix)
            extString = 'a';
        else
            extString = 'lib';
        end
    else
        extString = mexext;
    end;
    
    dllFileName = [fileNameInfo.mexFunctionName,'.', extString];
    srcFileName = fullfile(fileNameInfo.targetDirName,dllFileName);
    if(isLibrary)
        destFileName = srcFileName;
    else
        destFileName = fullfile(modelDirectory,dllFileName);
    end
    if(exist(srcFileName,'file'))
        sf_display('Make',sprintf('Make successful for machine: "%s"\n', machineName));
        if(~strcmp(srcFileName,destFileName))
            % Move only the MEX file to the top directory. Leave the lib
            % files alone as they are now built specifically based on 
            % instances used in the mainMachine
            
            %G203073           
            [copySuccess, errMsg] = move_from_project_dir(fileNameInfo.targetDirName, dllFileName,...
                                                          fileNameInfo.dllDirFromMakeDir);
            
            if ~copySuccess
                throw_make_error(errMsg);
            end
            
            if(ispc)
                csfFile = [fileNameInfo.mexFunctionName,'.csf'];
                csfSourceFile = fullfile(fileNameInfo.targetDirName,csfFile);
                csfDestFile = fullfile(modelDirectory,[fileNameInfo.mexFunctionName,'.csf']);
            else
                csfFile = [dllFileName,'.csf'];
                csfSourceFile = fullfile(fileNameInfo.targetDirName,csfFile);
                csfDestFile = fullfile(modelDirectory,[dllFileName,'.csf']);
            end
            if(exist(csfSourceFile,'file'))
                try
                    if(exist(csfDestFile,'file'))
                        sf_delete_file(csfDestFile,1);
                    end
                    
            		%G203073           
                    %[copySuccess, errMsg] = 
                    move_from_project_dir(fileNameInfo.targetDirName, csfFile,...
                                          fileNameInfo.dllDirFromMakeDir);
                catch ME 
                    % Do nothing.
                end
            end
            
            
            %%% this is an undocumented feature given to us by
            %%% MATLAB parser. we call fschange function on pwd
            %%% to inform MATLAB parser that something changed
            %%% so that it will load the newly generated SFunction DLL
            fschange(pwd);
        end;
    else
        throw_make_error;
    end
    binaryFileInfo = dir(destFileName);
    binaryDateNum = binaryFileInfo.datenum;
else
    target_methods('make',targetId,parentTargetId);
    binaryDateNum = now;
end;
status = 0;


%---------------------------------------------------------------------------------------------------
function status = delete_target_sfunction_func( target )
%
%
%
if (~sf('get', target, '.simulationTarget')),
    status = 0;
    return;
end;

machineId	= sf('get', target, '.machine');
machineName	= sf('get', machineId, '.name');

mexFunctionName = [machineName,'_sfun'];
if(~sf('get',machineId,'machine.isLibrary'))
    if exist(mexFunctionName,'file')
        try
            feval(mexFunctionName,'sf_mex_unlock');
        catch ME 
        end
        clear(mexFunctionName); 
    end;
    
    sfunctionFileName = fullfile(pwd,[mexFunctionName,'.', mexext]);
    if exist(sfunctionFileName,'file')
        try 
            sf_delete_file(sfunctionFileName); 
        catch ME 
        end;
        fschange(pwd); % needed on network dirs for MATLAB to know the dir has changed
    end
    if exist(sfunctionFileName,'file')
        % this means delete failed. must be a locking problem. try clear('mex')
        sf_display('Make',sprintf('%s could not be deleted. Trying to delete again.\n',sfunctionFileName));
        clear('mex');
        try 
            sf_delete_file(sfunctionFileName); 
        catch ME %#ok<*NASGU>
        end
        fschange(pwd); % needed on network dirs for MATLAB to know the dir has changed
    end
    
    if exist(sfunctionFileName,'file')
        msgString = ['Two attempts to delete ',sfunctionFileName,' have failed.'];
        msgString = sprintf('%s\nThis file is either not writable or is locked by another process.\n',msgString);
        sf_display('Make', msgString);
        status = 1;
        return;
    end
else
    if(isunix)
        libext = 'a';
    else
        libext = 'lib';
    end
    
    sfunctionFileName = fullfile(pwd,[mexFunctionName,'.',libext]);
    if exist(sfunctionFileName,'file'),
        try 
            sf_delete_file(sfunctionFileName);
        catch ME
            sf_display('Make',sprintf('Problem deleting target lib-File %s\n',sfunctionFileName) );
            return;
        end
    end
end
status = 0;


function check_not_simulating( targetId, machineId, machineName, targetName)
if (sf('get',targetId,'.simulationTarget'))
    simStatus = get_param(machineName, 'SimulationStatus');
    switch(simStatus)
        case {'stopped','initializing'}
            % do nothing
        case {'running','paused','external'}
            construct_error(machineId,'Make',sprintf('%s is running --cannot operate on target: %s, during simulation.',machineName,targetName),1);
        otherwise,
            % unknown simulation status. Go through with make
    end
end


function set_busy( dialogFigure )
if dialogFigure==0 || ~ishandle(dialogFigure), return; end
set(dialogFigure,'Pointer','watch');

function set_idle( dialogFigure )
if dialogFigure==0 || ~ishandle(dialogFigure), return; end
set(dialogFigure,'Pointer','arrow');

%----------------------------------------------------------------------------------
function throw_make_error(msg)
%
% Throws a make error with the proper slsf-token.
%
if nargin > 0 && ~isempty(msg) 
    sf_display('Make', sprintf('%s\n',msg)); 
end;

error('Stateflow:MakeError',slsfnagctlr('NagToken'));


%----------------------------------------------------------------------------------
function [copySuccess, errMsg] = move_from_project_dir(projectDir, fileName,relPath)

% NOTE: In the following calls to dos and unix, we specify output arguments
% so as to suppress the output to command window.
currDir = cd(projectDir);
if ispc
    [s,w] = dos(['copy "', fileName, '" ', relPath]); %#ok<ASGLU>
    sf_delete_file(fileName,1);
    % On PC, we must copy and delete instead of move to deal with long
    % file-name issues. Not deleting it causes strange failures.
else
    [s,w] = unix(['mv ', fileName, ' ', relPath]); %#ok<ASGLU>
end
cd(currDir);

copySuccess = exist(fullfile(pwd,fileName),'file');
    
errMsg = '';
if(~copySuccess) 
    errMsg = sprintf('moving %s from %s to %s failed.',fileName,projectDir,pwd);
else
   if ispc
        [s,w] = dos(['attrib -r "', fileName, '"']); %#ok<ASGLU>
    else
        [s,w] = unix(['chmod +w ',fileName]); %#ok<ASGLU>
    end
end

function machineTypeStr = get_machine_type(machineId)
   
allLinks = sf('get',machineId,'machine.sfLinks');
for i = 1 : numel(allLinks)
    allLinks(i) = block2chart(allLinks(i));
end

    allCharts = sf('get',machineId,'machine.charts');

allCharts = [allCharts allLinks];

numEMLCharts = numel(allCharts(is_eml_chart(allCharts)));
numCharts = numel(allCharts);

hasEML = numEMLCharts > 0;
hasStateflow = (abs(numCharts - numEMLCharts) > 0);
if hasStateflow && hasEML
     machineTypeStr = 'Stateflow/Embedded MATLAB';
elseif hasEML
    machineTypeStr = 'Embedded MATLAB';
else
      machineTypeStr = 'Stateflow';
end    
    
