function code_machine_header_file_rtw(fileNameInfo)
% CODE_MACHINE_HEADER_FILE(FILENAMEINFO)

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.17 $  $Date: 2009/10/24 19:41:25 $

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%  GLOBAL VARIABLES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%% Coding options
    global gMachineInfo gTargetInfo



    fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.machineHeaderFile);
    sf_echo_generating('Coder',fileName);
    machine = gMachineInfo.machineId;
    
    file = fopen(fileName,'Wt');
    if file<3
        construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
    end
fprintf(file,'%%implements "machineHeader" "C"\n');
fprintf(file,'%%function CacheOutputs(block,system) void\n');
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% A few useful defines and includes from RTW
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%if FEVAL("sf_rtw","usesDSPLibrary",CompiledModel.Name)\n');
fprintf(file,'   %%<LibAddToCommonIncludes("dsp_%s")>\n',fileNameInfo.rtwDspLibIncludeFileName);
fprintf(file,'%%endif\n');
    
    customCodeSettings = get_custom_code_settings(gMachineInfo.target,gMachineInfo.parentTarget);
    customCodeString = customCodeSettings.customCode;
    if(~isempty(customCodeString))
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %% Custom Code Included on the target
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'   %%openfile ccBuf\n');
    customCodeString = sf('Private','expand_double_byte_string',customCodeString);
fprintf(file,'   %s\n',customCodeString);
fprintf(file,'\n');
fprintf(file,'   %%closefile ccBuf\n');
fprintf(file,'   %%<SLibCacheCodeToFile("sf_machine_incl",ccBuf)>\n');
fprintf(file,'\n');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Types
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%openfile typedefsBuf   \n');
    types = sf('Cg','get_types',machine);
    for type = types
         codeStr = sf('Cg','get_type_def',type,0);
fprintf(file,'   %s         \n',codeStr);
    end
fprintf(file,'%%closefile typedefsBuf\n');
fprintf(file,'%%<SLibCacheCodeToFile("sf_machine_typedef",typedefsBuf)>\n');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Named Constants
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%openfile definesBuf   \n');
    namedConsts = sf('Cg','get_named_consts',machine);
    for namedConst = namedConsts
         codeStr = sf('Cg','get_named_const_def',namedConst,0);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
    end
fprintf(file,'%%closefile definesBuf\n');
fprintf(file,'%%<SLibCacheCodeToFile("sf_machine_data_define",definesBuf)>\n');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Vars
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%openfile externDataBuf\n');
    vars = sf('Cg','get_non_exported_vars',machine);
    for var = vars
         codeStr = sf('Cg','get_var_decl',var,0);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
    end
fprintf(file,'%%closefile externDataBuf\n');
fprintf(file,'%%<SLibCacheCodeToFile("sf_machine_extern_data_decl",externDataBuf)>\n');

fprintf(file,'%%openfile externDataBuf\n');
    vars = sf('Cg','get_exported_vars',machine);
    for var = vars
         codeStr = sf('Cg','get_var_decl',var,0);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
    end
fprintf(file,'%%closefile externDataBuf\n');
fprintf(file,'%%<SLibCacheCodeToFile("sf_machine_public_extern_data_decl",externDataBuf)>\n');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% function Decls
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fprintf(file,'%%openfile externDataBuf\n');
fprintf(file,'\n');
    funcs = sf('Cg','get_functions',machine);
    for func = funcs
        codeStr = sf('Cg','get_fcn_decl',func,0);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
    end
    if(gTargetInfo.codingLibrary & gMachineInfo.parentTarget~=gMachineInfo.target)
      % exported fcns are already included in the parent machine
    else
%       dump_exported_fcn_prototypes(file);
    end
fprintf(file,'%%closefile externDataBuf\n');
fprintf(file,'%%<SLibCacheCodeToFile("sf_machine_extern_fcn_decl",externDataBuf)>\n');

fprintf(file,'%%endfunction %%%% CacheOutputs\n');
fprintf(file,' \n');
fprintf(file,'\n');
    fclose(file);
    try_indenting_file(fileName);

            
