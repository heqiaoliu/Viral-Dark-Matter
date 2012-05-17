function varargout = sfc( method, varargin)
% This is an entry point into Stateflow Code Generator
% for internal use only and not for general use.
% Help text is suppressed intentionally as
% this function is called by Stateflow internal code.
% Please refer to Stateflow API documentation for details
% on command line interface to code-generation.
%

%
%   Copyright 1995-2010 The MathWorks, Inc.
%
if(nargin<1)
    help(mfilename);
    return;
end

switch(lower(method))
    case 'coder_options'
        varargout = cell(1,max(1,nargout));
        varargout{:} = coder_options(varargin{:});
        return;
    case 'private'
        if(length(varargin)<1)
            construct_coder_error([],'',1);
            return;
        end
        fcnName = varargin{1};
        inArgs = varargin(2:end);
        if(nargout>0)
            varargout = cell(1,nargout);
            [varargout{:}] = feval(fcnName,inArgs{:});
        else
            feval(fcnName,inArgs{:});
        end
        return;
    case 'revision'
        varargout{1} = '$Revision: 1.72.2.28.2.1 $  $Date: 2010/06/17 14:13:57 $';
        return;
    case 'language'
        varargout{1} = 'ANSI-C';
        return;
    case {'clean_objects','clean','code','codeincremental','codenonincremental','filenameinfo','makeinfo','construct_chart_ir_for_rtw'}
        %WISH error check nargin
        if(length(varargin)<1)
            errorMsg = sprintf('Usage: sfc(methodName,targetId[,parentTargetId])');
            construct_coder_error([], errorMsg,1);
            return;
        end

        target = varargin{1};

        if(length(target)~=1 || ~sf('ishandle',target))
            errorMsg = sprintf('sfc invoked with invalid target id %d.',target);
            construct_coder_error([], errorMsg,1);
            return;
        end

        if(length(varargin)>1)
            parentTarget = varargin{2};
        else
            parentTarget = target;
        end
        if(length(varargin)>=3)
            mainMachineId = varargin{3};
        else
            mainMachineId = 0;
        end
        if(length(varargin)>=4)
            currentChartId = varargin{4};
        else
            currentChartId = [];
        end
        if(length(varargin)>=5)
            auxiliaryInfo = varargin{5};
        else
            auxiliaryInfo = [];
        end
        if(length(varargin)>=6)
            hChart = varargin{6};
        else
            hChart = [];
        end

        if(length(parentTarget)~=1 || ~sf('ishandle',parentTarget))
            errorMsg = sprintf('sfc invoked with invalid parent target id %d.',parentTarget);
            construct_coder_error([], errorMsg,1);
        end
    case 'reset_cdr_module_cache'
        return;
    case 'flush_cdr_module_cache'
        return;
    otherwise,
        construct_coder_error([],'',1);
        return;
end

sf('Private','coder_error_count_man','reset');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% GLOBAL FLAGS AND ARRAYS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global gTargetInfo gChartInfo gDataInfo gMachineInfo %#ok<NUSED>

%%%%%%%BEGIN: MINIMAL STUFF THAT NEEDS TO BE DONE%%%%%%%

gMachineInfo.target = target;
gMachineInfo.parentTarget = parentTarget;

gMachineInfo.mainMachineId = mainMachineId;
gMachineInfo.machineId = sf('get',gMachineInfo.target,'target.machine');
if(isempty(gMachineInfo.mainMachineId) || gMachineInfo.mainMachineId==0)
    gMachineInfo.mainMachineId = gMachineInfo.machineId;
end

gMachineInfo.charts = sf('Private','get_instantiated_charts_in_machine',gMachineInfo.machineId);
selectedCodegenForHDLorPLC = ~isempty(currentChartId) && targetIsHDLorPLC(parentTarget);
if selectedCodegenForHDLorPLC
    % HDL and PLC code gen only. If currentChartId is not empty, generate code
    % for specified chart(s) only non-incrementally.
    gMachineInfo.charts = intersect(gMachineInfo.charts, currentChartId);
    if ~isempty(hChart)
        spec = sf('SFunctionSpecialization', currentChartId, hChart);
        gMachineInfo.specializations = {{spec}};
    end
end
chartFileNumbers = sf('get',gMachineInfo.charts,'chart.chartFileNumber');
[~,sortedIndices] = sort(chartFileNumbers);
gMachineInfo.charts = gMachineInfo.charts(sortedIndices);

gTargetInfo.target = target;
gTargetInfo.parentTarget = parentTarget;

%%%%%%%END:  MINIMAL STUFF THAT NEEDS TO BE DONE%%%%%%%

switch(method)
    case 'clean'
        [status varargout{1}] = cdr_init_all_info([]);
        clean_code_gen_dir(varargout{1}.targetDirName');
        cdr_cleanup_all_info;
    case 'clean_objects'
        [status varargout{1}] = cdr_init_all_info([]);
        clean_code_gen_dir(varargout{1}.targetDirName,1);
        cdr_cleanup_all_info;
    case {'code','codeIncremental','codeNonIncremental'}
        switch(method)
            case {'code','codeIncremental'}
                codingRebuildAll=0;
            case {'codeNonIncremental'}
                codingRebuildAll=1;
        end
        [status varargout{1}] = cdr_init_all_info('Code');        
        sf('set',gTargetInfo.target,'target.makeInfo',varargout{1});

        if selectedCodegenForHDLorPLC
            codingRebuildAll = 1;
        end

        if ~status
            status = construct_context_for_machine;
        end
        if(~status)
            generate_code_for_charts_and_machine(varargout{1},codingRebuildAll);
        end
        cdr_cleanup_all_info;
    case 'construct_chart_ir_for_rtw'
        [status varargout{1}] = cdr_init_all_info([]);
        if ~status
            status = construct_context_for_machine(auxiliaryInfo);
        end
        if ~status
            status = construct_chart_ir_for_rtw(currentChartId, hChart);
        end
        if ~status
            % Module will be destroyed already in case of errors.
            % Do not destroy again!  See construct_module.m
            sf('Cg','destroy_module',currentChartId);
        end
        cdr_cleanup_all_info;
    case 'filenameinfo'
        [status varargout{1}] = cdr_init_all_info([]);
        cdr_cleanup_all_info;
    case 'makeinfo'
        [status makeInfo.fileNameInfo] =  cdr_init_all_info([]);
        varargout{1} = makeInfo;
        if gTargetInfo.codingSFunction && makeInfo.fileNameInfo.mexOptsIgnored
            sf('Private','construct_warning',[],'Make',...
                ['The mex compiler specified using ''mex -setup'' ',...
                'is not supported for simulation builds.  '...
                'Using the lcc compiler instead.'...
                ]);
        end
        cdr_cleanup_all_info;
    otherwise,
        construct_coder_error([],'',1);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [status fileNameInfo] = cdr_init_all_info(msgType)
global gTargetInfo;

status = 0;
compute_target_info();
compute_machine_info();
fileNameInfo = create_file_name_info();
if ~isempty(msgType)
    if gTargetInfo.codingSFunction && ...
            fileNameInfo.mexOptsIgnored && ...
            strcmpi(computer, 'PCWIN64')
        try
            cc = mex.getCompilerConfigurations;
            ccName = cc.Name;
        catch ME %#ok<NASGU>
            ccName = '<unknown>';
        end
        if fileNameInfo.mexOptsNotFound
            msgText = sprintf(...
                ['Unable to locate ''mexopts.bat'', and therefore cannot determine which compiler to use for simulation builds.\n',...
                'Use ''mex -setup'' to select a supported compiler.']);
        else
            msgText = sprintf(...
                ['The mex compiler ''%s'' is not supported for simulation builds.\n',...
                'Use ''mex -setup'' to select a supported compiler.'], ccName);
        end
        throwFlag = false;
        sf('Private','construct_error',[],msgType,msgText,throwFlag);
        error('Stateflow:mexCompiler',msgText); 
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cdr_cleanup_all_info
global gMachineInfo
sf('set',gMachineInfo.machineId,'machine.activeTarget',0);
sf('set',gMachineInfo.machineId,'machine.activeParentTarget',0);
clear global gMachineInfo gTargetInfo gChartInfo gDataInfo

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = targetIsHDLorPLC(target)

targetName = sf('get',target,'target.name');
result = strcmp(targetName,'slhdlc') || strcmp(targetName,'plc');
