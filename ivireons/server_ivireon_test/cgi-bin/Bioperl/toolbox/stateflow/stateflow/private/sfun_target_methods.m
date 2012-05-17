function output = sfun_target_methods(method, targetId, varargin)
% output = sfun_target_methods(method, targetId, varargin)
% Target function for sfun targets.  See target_methods.m

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.12.4.14 $  $Date: 2009/12/28 04:52:31 $

output = feval(method,targetId,varargin{:});


function output = name(~,varargin) %#ok<DEFNU>
    output = 'sfun';


function output = initialize(~,varargin) %#ok<DEFNU>
	output = [];

function output = language(~,varargin) %#ok<DEFNU>
    output = 'ANSI-C';

function output = preparse(~,varargin) %#ok<DEFNU>
output = [];

function output = postparse(~,varargin) %#ok<DEFNU>
output = [];

function output = precode(~,varargin) %#ok<DEFNU>
output = [];

function output = postcode(~,varargin) %#ok<DEFNU>
output = [];

function output = make(~,varargin) %#ok<DEFNU>
output = [];

function output = machineheadertop(~,varargin) %#ok<DEFNU>
	output = [];
    
function output = buildcommands(~,varargin) %#ok<DEFNU>
    % return Nx3 cell array of <Menu string, Button string, method string>
    output = {...
        'Stateflow Target (incremental)',       'Build', 'sf_incremental_build';
        'Rebuild All (including libraries)',    'Rebuild All', 'sf_nonincremental_build';
        'Make without generating code',         'Make', 'sf_make';
        'Clean All (delete generated code/executables)','Clean All', 'sf_make_clean';
        'Clean Objects (delete executables only)', 'Clean Objects', 'sf_make_clean_objects';
    };

    if sf('Feature','Developer')
        output = [output; 
                {'Generate Code Only (non-incremental)'}, {'Generate'},{'sf_nonincremental_code'}];
    end

function output = build(targetId, varargin)
        
output = default_target_methods('build',targetId,varargin{:});

function output = targetproperties(~,varargin) %#ok<DEFNU>
    % target_methods(targetId, 'targetproperties')
    output = {...
        'Custom code included at the top of generated code',      'target.customCode';
        'Custom include directory paths',                         'target.userIncludeDirs';
        'Custom source files',                                    'target.userSources';
        'Custom libraries',                                       'target.userLibraries';
        'Reserved Names',                                         'target.reservedNames';
        'Custom initialization code (called from mdlInitialize)', 'target.customInitializer';
        'Custom termination code (called from mdlTerminate)',     'target.customTerminator';
    };

function ok = has_blas_support
    matlabRoot = sf('Private','sf_get_component_root','matlab');
    compilerInfo = sf('Private','compilerman','get_compiler_info');
    archName = computer('arch');
    if strcmp(computer,'PCWIN') || strcmp(computer,'PCWIN64')
        compilerName = compilerInfo.compilerName;
        if strcmp(compilerName, 'msvc80') || ...
           strcmp(compilerName, 'msvc60')
            compilerName = 'microsoft';
        end
        blasLibFile = fullfile(matlabRoot,'extern','lib',archName,compilerName,'libmwblas.lib');
    else
        blasLibFile = fullfile(matlabRoot,'bin',archName,'libmwblas.so');
    end
    ok = exist(blasLibFile,'file');

function output = codeflags(targetId,varargin) %#ok<DEFNU>
    persistent flags
    
    if(isempty(flags))
        flags = [];
        
        flag.name = 'debug';
        flag.type = 'boolean';
        flag.description = 'Enable debugging/animation';
        flag.defaultValue = 1;
        flags = [flags,flag];

        flag.name = 'overflow';
        flag.type = 'boolean';
        flag.description = 'Enable overflow detection (with debugging)';
        flag.defaultValue = 1;
        flags = [flags,flag];

        
        flag.name = 'echo';
        flag.type = 'boolean';
        flag.description = 'Echo expressions without semicolons';
        flag.defaultValue = 0;
        flags = [flags,flag];

        flag.name = 'blas';
        flag.type = 'boolean';
        flag.description = 'Use BLAS (Basic Linear Algebra Subprograms) library if possible';
        flag.defaultValue = 0;
        flags = [flags,flag];

        flag.name = 'integrity';
        flag.type = 'boolean';
        flag.description = 'Memory integrity checks';
        flag.defaultValue = 1;
        flags = [flags,flag];

        flag.name = 'extrinsic';
        flag.type = 'boolean';
        flag.description = 'Extrinsic calls';
        flag.defaultValue = 1;
        flags = [flags,flag];

        flag.name = 'ctrlc';
        flag.type = 'boolean';
        flag.description = 'Ctrl-C checking';
        flag.defaultValue = 1;
        flags = [flags,flag];

        for i=1:length(flags)
            flags(i).visible = 'on';
            flags(i).enable = 'on';
        end
    end
    if sf('feature','EML BlasSupport')
        hasBlasSupport = has_blas_support;
        if ~hasBlasSupport
            flags(4).enable = 'off';
            flags(4).value = 0;
        else
            flags(4).enable = 'on';
        end
    end
    flags = target_code_flags('fill',targetId,flags);
    output = flags;

