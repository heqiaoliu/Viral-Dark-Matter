function parseResult = collect_custom_code_symbols(relevantMachineId, parseObjectId, targetId, parentTargetId, customCode)

%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.4.2.13 $  $Date: 2010/05/20 03:35:56 $

customCode = expand_double_byte_string(customCode);

mainMachine = sf('get',parentTargetId,'target.machine');
mainMachineName = sf('get',mainMachine,'machine.name');

cppFlag = false;
try
    cppFlag = rtwprivate('rtw_is_cpp_build',mainMachineName);
catch ME %#ok
end

if (cppFlag)
    Options.Language.LanguageMode = 'cxx';
    Options.Language.LanguageExtra = {'--g++'};
else
    Options.Language.LanguageMode = 'c';
    Options.Language.LanguageExtra = {'--gcc'};
end

makeInfo = sfc('makeinfo',targetId,parentTargetId);
userIncludes = makeInfo.fileNameInfo.userIncludeDirs;

% Determine the current selected compiler
try
    currentCompiler = legacycode.ParserConfig('C', 'Selected');
    currentCompilerConfiguration = currentCompiler.process;
catch ME
    disp(ME.message);
    construct_warning(parseObjectId, 'Parse', ME.message);
    parseResult.status = 1;
    return;
end

% Windows systems only have one compiler for C and C++ code, while Linux
% and Mac have separate gcc and g++ compilers
if ~ispc
    Options.Preprocessor.Defines = {};
    Options.Preprocessor.SystemIncludeDirs = {};
    for i=1:length(currentCompilerConfiguration)
        if (strcmpi(currentCompilerConfiguration(i).Name, 'GNU C') && ~cppFlag) ...
            || (strcmpi(currentCompilerConfiguration(i).Name, 'GNU C++') && cppFlag)
            Options.Preprocessor.Defines = currentCompilerConfiguration(i).Details.ParserConfig.Defines;
            Options.Preprocessor.SystemIncludeDirs = currentCompilerConfiguration(i).Details.ParserConfig.Include;  
            break;
        end
    end
else
    Options.Preprocessor.Defines = currentCompilerConfiguration(1).Details.ParserConfig.Defines;
    Options.Preprocessor.SystemIncludeDirs = currentCompilerConfiguration(1).Details.ParserConfig.Include;
end
Options.Preprocessor.IncludeDirs = [{[matlabroot filesep 'extern' filesep 'include']}, ...
                                    {[matlabroot filesep 'simulink' filesep 'include']}, ...
                                    userIncludes];

if isempty(Options.Preprocessor.SystemIncludeDirs)
    % System include dir should not be empty. If it is, that means mexopts is not setup correctly. 
    mexStr = 'Custom code parser cannot figure out system include directories. You may need to run "mex -setup".';
    disp(mexStr);
    construct_warning(parseObjectId, 'Parse', mexStr);
    parseResult.status = 1;
    return;
end

% Make tweaks based on the selected compiler
if (strcmp(currentCompilerConfiguration(1).Manufacturer,'Microsoft'))
    Options.Language.LanguageExtra = {'--microsoft'};
elseif (strcmp(currentCompilerConfiguration(1).Manufacturer,'Sybase'))
    % this is for the Open Watcom C++ compiler
    Options.Language.LanguageExtra = {'--microsoft'};
    Options.Preprocessor.IgnoredMacros = {'__based'};  
elseif (strcmp(currentCompilerConfiguration(1).Manufacturer,'Intel'))
    Options.Language.LanguageExtra = {'--microsoft'};
end

Options.RemoveUnneededEntities = false;
Options.Language.PlainCharsAreSigned = currentCompilerConfiguration(1).Details.ParserConfig.PlainCharsAreSigned;
Options.Target = rtwhostwordlengths;
Options.Target.PointerNumBits = currentCompilerConfiguration(1).Details.ParserConfig.PointerNumBits*8;
Options.Language.AllowMultibyteChars = true;
Options.Language.AllowLongLong = true;

% Note: At this point, IgnoredMacros and Undefines are empty , but Defines is not empty
Options.Preprocessor.IgnoredMacros = {'TRUE', 'FALSE'};
Options.Preprocessor.Undefines = {'TRUE', 'FALSE'};
Options.Preprocessor.Defines = [Options.Preprocessor.Defines, {'TRUE=1', 'FALSE=0'}];

% Call EDG engine
[messages, parseResultCell] = slfrontend_mex({customCode},Options);

parseResult.variables = parseResultCell{1};
parseResult.functions = parseResultCell{2};
parseResult.types = parseResultCell{3};
parseResult.macros = parseResultCell{4};
parseResult.status = 0; % initialize to no error

machineWithCustomCode = sf('get',relevantMachineId,'machine.name');
openCustomCodeCommand = sprintf(['cs = getActiveConfigSet(''%s''); slCfgPrmDlg(cs,''Open''); slCfgPrmDlg(cs,''TurnToPage'',''Custom Code''); ' ... 
                                 'dlg = DAStudio.ToolRoot.getOpenDialogs; imd = DAStudio.imDialog.getIMWidgets(dlg(2)); ' ...
                                 'lb = imd.find(''tag'',''Tag_ConfigSet_Sim_CustomCode_CustomCodeList''); lb.select(1); ' ...
                                 'clear cs dlg imd lb;'],machineWithCustomCode); 

% Display all parser error/warning messages as warning messages
for i=1:length(messages)
    switch messages(i).kind
        case 'warning'
            msgKind = 'Warning';
        case 'error'
            msgKind = 'Error';
            parseResult.status = 1;
        otherwise
            continue;
    end
        
    if (isempty(messages(i).file))
        messages(i).file = sprintf('<a href="matlab: %s ">the custom code</a>', openCustomCodeCommand);
    elseif (~isempty(strfind(messages(i).file,filesep)))
        messages(i).file = sprintf('<a href="matlab: edit ''%s''; editor = editorservices.getActive; editor.goToLine(%d); clear editor;">%s</a>', ...
                                   messages(i).file, messages(i).line, messages(i).file);
    end
    
    if (messages(i).line ~= 0)
        messages(i).line = sprintf('line %d of ',messages(i).line);
    else
        messages(i).line = '';
    end
    
    construct_warning(parseObjectId, 'Parse', sprintf('%s while parsing custom code:\nIn %s%s,\n%s:\n%s', ...
                      msgKind, messages(i).line, messages(i).file, messages(i).desc, messages(i).detail));
end
