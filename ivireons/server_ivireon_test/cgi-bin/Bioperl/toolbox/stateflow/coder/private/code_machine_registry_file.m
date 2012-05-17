function code_machine_registry_file(fileNameInfo)
% CODE_MACHINE_REGISTRY_FILE(FILENAMEINFO)

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.8.4.25 $  $Date: 2010/03/15 23:51:17 $

        global gTargetInfo gMachineInfo

        fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.machineRegistryFile);
   sf_echo_generating('Coder',fileName);
        file = fopen(fileName,'Wt');
        if file<3
                construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
                return;
        end

fprintf(file,'#include "%s"\n',fileNameInfo.machineHeaderFile);

        if gTargetInfo.codingDebug
fprintf(file,'#include "sfcdebug.h"\n');
        end
        
        if gTargetInfo.codingSFunction
fprintf(file,'#define PROCESS_MEX_SFUNCTION_CMD_LINE_CALL\n');
fprintf(file,'unsigned int sf_process_check_sum_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] ) \n');
fprintf(file,'{\n');
fprintf(file,'     extern unsigned int sf_%s_process_check_sum_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] );\n',gMachineInfo.machineName);
                        for i=1:length(fileNameInfo.linkMachines)                                                        
fprintf(file,'     extern unsigned int sf_%s_process_check_sum_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] );\n',fileNameInfo.linkMachines{i});
                        end                                                                                              
fprintf(file,'                                                                                                       \n');
fprintf(file,'     if(sf_%s_process_check_sum_call(nlhs,plhs,nrhs,prhs)) return 1;                         \n',gMachineInfo.machineName);
                        for i=1:length(fileNameInfo.linkMachines)                                                        
fprintf(file,'     if(sf_%s_process_check_sum_call(nlhs,plhs,nrhs,prhs)) return 1;         \n',fileNameInfo.linkMachines{i});
                        end                                                                                              
fprintf(file,'     return 0;                                                                                           \n');
fprintf(file,'}                                                                                                      \n');
fprintf(file,'\n');

           if gTargetInfo.codingExtMode
fprintf(file,'unsigned int sf_process_testpoint_info_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] ) \n');
fprintf(file,'{\n');
fprintf(file,'     extern unsigned int sf_%s_process_testpoint_info_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] );\n',gMachineInfo.machineName);
                        for i=1:length(fileNameInfo.linkMachines)                                                        
fprintf(file,'     extern unsigned int sf_%s_process_testpoint_info_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] );\n',fileNameInfo.linkMachines{i});
                        end                                                                                              
fprintf(file,'                                                                                                       \n');
fprintf(file,'     if(sf_%s_process_testpoint_info_call(nlhs,plhs,nrhs,prhs)) return 1;                         \n',gMachineInfo.machineName);
                        for i=1:length(fileNameInfo.linkMachines)                                                        
fprintf(file,'     if(sf_%s_process_testpoint_info_call(nlhs,plhs,nrhs,prhs)) return 1;         \n',fileNameInfo.linkMachines{i});
                        end                                                                                              
fprintf(file,'     return 0;                                                                                           \n');
fprintf(file,'}                                                                                                      \n');
fprintf(file,'\n');
           end

fprintf(file,'unsigned int sf_process_autoinheritance_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] ) \n');
fprintf(file,'{\n');
fprintf(file,'     extern unsigned int sf_%s_autoinheritance_info( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] );\n',gMachineInfo.machineName);
fprintf(file,'     if(sf_%s_autoinheritance_info(nlhs,plhs,nrhs,prhs)) return 1;                         \n',gMachineInfo.machineName);
fprintf(file,'     return 0;                                                                                           \n');
fprintf(file,'}                                                                                                      \n');
fprintf(file,'unsigned int sf_process_get_eml_resolved_functions_info_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] )\n');
fprintf(file,'{\n');
fprintf(file,'     extern unsigned int sf_%s_get_eml_resolved_functions_info( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] );\n',gMachineInfo.machineName);
    for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'     extern unsigned int sf_%s_get_eml_resolved_functions_info( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] );\n',fileNameInfo.linkMachines{i});
    end
fprintf(file,'     char commandName[64];\n');
fprintf(file,'     char machineName[128];\n');
fprintf(file,'     if (nrhs < 3) {\n');
fprintf(file,'          return 0;\n');
fprintf(file,'     }\n');
fprintf(file,'     if (!mxIsChar(prhs[0]) || !mxIsChar(prhs[1])) return 0;\n');
fprintf(file,'     mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));\n');
fprintf(file,'     commandName[(sizeof(commandName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'     if(strcmp(commandName,"get_eml_resolved_functions_info")) return 0;\n');
fprintf(file,'     mxGetString(prhs[1], machineName,sizeof(machineName)/sizeof(char));\n');
fprintf(file,'     machineName[(sizeof(machineName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'     if(strcmp(machineName, "%s") == 0) {\n',gMachineInfo.machineName);
fprintf(file,'         const mxArray *newRhs[2] = { NULL, NULL };\n');
fprintf(file,'         newRhs[0] = prhs[0];\n');
fprintf(file,'         newRhs[1] = prhs[2];\n');
fprintf(file,'         return sf_%s_get_eml_resolved_functions_info(nlhs,plhs,2,newRhs);\n',gMachineInfo.machineName);
fprintf(file,'     }\n');
    for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'     if(strcmp(machineName, "%s") == 0) {\n',fileNameInfo.linkMachines{i});
fprintf(file,'         const mxArray *newRhs[2] = { NULL, NULL };\n');
fprintf(file,'         newRhs[0] = prhs[0];\n');
fprintf(file,'         newRhs[1] = prhs[2];\n');
fprintf(file,'         return sf_%s_get_eml_resolved_functions_info(nlhs,plhs,2,newRhs);\n',fileNameInfo.linkMachines{i});
fprintf(file,'     }\n');
    end
fprintf(file,'     \n');
fprintf(file,'     return 0;\n');
fprintf(file,'}\n');

fprintf(file,'unsigned int sf_mex_unlock_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] ) \n');
fprintf(file,'{\n');
fprintf(file,'     char commandName[20];\n');
fprintf(file,'     if (nrhs<1 || !mxIsChar(prhs[0]) ) return 0;\n');
fprintf(file,'%s\n',sf_comment('/* Possible call to get the checksum */'));
fprintf(file,'     mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));\n');
fprintf(file,'     commandName[(sizeof(commandName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'     if(strcmp(commandName,"sf_mex_unlock")) return 0;\n');
fprintf(file,'   while(mexIsLocked()) {\n');
fprintf(file,'      mexUnlock();\n');
fprintf(file,'   }\n');
fprintf(file,'   return(1);\n');
fprintf(file,'}\n');


   if gTargetInfo.codingDebug
      if gTargetInfo.gencpp
          storageMod = 'extern "C"';
      else
          storageMod = 'extern';
      end
fprintf(file,'%s unsigned int sf_debug_api( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] );\n',storageMod);
        end
        if(gTargetInfo.codingSFunction)
fprintf(file,'static unsigned int ProcessMexSfunctionCmdLineCall(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])\n');
        else
fprintf(file,'unsigned int fsm_process_mex_cmd_line_call(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])\n');
        end
fprintf(file,'{\n');
                if(gTargetInfo.codingDebug)
fprintf(file,'     if(sf_debug_api(nlhs,plhs,nrhs,prhs)) return 1;\n');
                end
                if gTargetInfo.codingExtMode
fprintf(file,'     if(sf_process_testpoint_info_call(nlhs,plhs,nrhs,prhs)) return 1;                  \n');
                end
fprintf(file,'     if(sf_process_check_sum_call(nlhs,plhs,nrhs,prhs)) return 1;\n');
fprintf(file,'     if(sf_mex_unlock_call(nlhs,plhs,nrhs,prhs)) return 1;\n');
fprintf(file,'     if(sf_process_autoinheritance_call(nlhs,plhs,nrhs,prhs)) return 1;\n');
fprintf(file,'     if(sf_process_get_eml_resolved_functions_info_call(nlhs,plhs,nrhs,prhs)) return 1;\n');
fprintf(file,'     mexErrMsgTxt("Unsuccessful command.");\n');

fprintf(file,'     return 0;\n');
fprintf(file,'}\n');
fprintf(file,'static unsigned int sfMachineGlobalTerminatorCallable = 0;\n');
fprintf(file,'static unsigned int sfMachineGlobalInitializerCallable = 1;\n');
fprintf(file,'unsigned int sf_machine_global_initializer_called(void)\n');
fprintf(file,'{\n');
fprintf(file,'    return(!sfMachineGlobalInitializerCallable);\n');
fprintf(file,'}\n');

fprintf(file,'extern unsigned int sf_%s_method_dispatcher(SimStruct *S,  unsigned int chartFileNumber, const char* specsCksum, int_T method, void *data);\n',gMachineInfo.machineName);
                for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'extern unsigned int sf_%s_method_dispatcher(SimStruct *S, unsigned int chartFileNumber, const char* specsCksum, int_T method, void *data);\n',fileNameInfo.linkMachines{i});
                end
   globalMethodDispatcherPrototype = cpp_safe_prototype('unsigned int sf_machine_global_method_dispatcher(SimStruct *simstructPtr, const char *machineName, unsigned int chartFileNumber, const char* specsCksum, int_T method, void *data)');
fprintf(file,'%s\n',globalMethodDispatcherPrototype);
fprintf(file,'{\n');
fprintf(file,'     if(!strcmp(machineName,"%s")) {\n',gMachineInfo.machineName);
fprintf(file,'         return(sf_%s_method_dispatcher(simstructPtr,chartFileNumber,specsCksum,method,data));\n',gMachineInfo.machineName);
fprintf(file,'     }\n');
                for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'     if(!strcmp(machineName,"%s")) {\n',fileNameInfo.linkMachines{i});
fprintf(file,'         return(sf_%s_method_dispatcher(simstructPtr,chartFileNumber,specsCksum,method,data));\n',fileNameInfo.linkMachines{i});
fprintf(file,'     }\n');
                end
fprintf(file,'     return 0;\n');
fprintf(file,'}\n');

fprintf(file,'extern void %s_terminator(void);\n',gMachineInfo.machineName);
                for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'extern void %s_terminator(void);\n',fileNameInfo.linkMachines{i});
                end
   globalTermPrototype = cpp_safe_prototype('void sf_machine_global_terminator(void)');
fprintf(file,'%s\n',globalTermPrototype);
fprintf(file,'{\n');
fprintf(file,'     if(sfMachineGlobalTerminatorCallable) {\n');
fprintf(file,'             sfMachineGlobalTerminatorCallable = 0;\n');
fprintf(file,'             sfMachineGlobalInitializerCallable = 1;\n');
fprintf(file,'             %s_terminator();\n',gMachineInfo.machineName);
                for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'             %s_terminator();\n',fileNameInfo.linkMachines{i});
                end
                
                if gTargetInfo.codingDebug
fprintf(file,'     sf_debug_terminate();\n');
                end

fprintf(file,'     }\n');
fprintf(file,'     return;\n');
fprintf(file,'}\n');
fprintf(file,'extern void %s_initializer(void);\n',gMachineInfo.machineName);
                for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'extern void %s_initializer(void);\n',fileNameInfo.linkMachines{i});
                end

fprintf(file,'extern void %s_register_exported_symbols(SimStruct* S);\n',gMachineInfo.machineName);
           for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'extern void %s_register_exported_symbols(SimStruct* S);\n',fileNameInfo.linkMachines{i});
           end

      if(gTargetInfo.codingDebug)
fprintf(file,'extern void %s_debug_initialize(void);\n',gMachineInfo.machineName);
         for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'extern void %s_debug_initialize(void);\n',fileNameInfo.linkMachines{i});
         end
      end

fprintf(file,'void sf_register_machine_exported_symbols(SimStruct* S)\n');
fprintf(file,'{\n');
fprintf(file,'    %s_register_exported_symbols(S);\n',gMachineInfo.machineName);
       for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'        %s_register_exported_symbols(S);\n',fileNameInfo.linkMachines{i});
       end
fprintf(file,'}\n');

   if (slfeature('LegacyCodeIntegration') == 1) && gTargetInfo.codingSFunction
fprintf(file,'#include "lgcycode.c"      %s\n',sf_comment('/* Legacy Code Integration interface mechanism */'));
   end

   globalInitPrototype = cpp_safe_prototype('bool callCustomFcn(char initFlag)');
fprintf(file,'%s\n',globalInitPrototype);
fprintf(file,'{\n');
   if (slfeature('LegacyCodeIntegration') == 1) && gTargetInfo.codingSFunction
fprintf(file,'    mxArray *plhs[1] = {NULL};\n');
fprintf(file,'    mxArray *prhs[2];\n');
fprintf(file,'    double  flag;\n');
fprintf(file,'    int     ret;\n');

fprintf(file,'    prhs[0] = mxCreateString("%s");\n',gMachineInfo.machineName);
fprintf(file,'    prhs[1] = mxCreateString("LegacyCodeIntegration");\n');
fprintf(file,'    ret = mexCallMATLAB(1,plhs,2,prhs,"get_param");\n');
fprintf(file,'    mxDestroyArray(prhs[0]);\n');
fprintf(file,'    mxDestroyArray(prhs[1]);\n');
fprintf(file,'    if ((ret != 0) || (plhs[0] == NULL) || mxIsEmpty(plhs[0]) || !mxIsClass(plhs[0], "Simulink.LegacyCodeIntegration"))\n');
fprintf(file,'        return false;\n');

fprintf(file,'    prhs[0] = plhs[0];\n');
fprintf(file,'    plhs[0] = NULL;\n');
fprintf(file,'    ret = mexCallMATLAB(1,plhs,1,prhs,"getCustomFcnFlag");\n');
fprintf(file,'    mxDestroyArray(prhs[0]);\n');
fprintf(file,'    if ((ret != 0) || (plhs[0] == NULL)) return false;\n');

fprintf(file,'    flag = mxGetScalar(plhs[0]);\n');

fprintf(file,'    if ((flag > -1e-3) && (flag < 1e-3)) {\n');
fprintf(file,'        mxDestroyArray(plhs[0]);\n');
fprintf(file,'        return false;\n');
fprintf(file,'    }\n');

fprintf(file,'    mxDestroyArray(plhs[0]);\n');

fprintf(file,'    legacy_code_interface(initFlag);\n');
fprintf(file,'    return true;\n');
   else
fprintf(file,'    return false;\n');
   end
fprintf(file,'}\n');

   globalInitPrototype = cpp_safe_prototype('void sf_machine_global_initializer(SimStruct* S)');
fprintf(file,'%s\n',globalInitPrototype);
fprintf(file,'{\n');
fprintf(file,'    bool simModeIsRTWGen = sim_mode_is_rtw_gen(S);\n');
fprintf(file,'    if(sfMachineGlobalInitializerCallable) {\n');
fprintf(file,'        sfMachineGlobalInitializerCallable = 0;\n');
fprintf(file,'        sfMachineGlobalTerminatorCallable =1;\n');
fprintf(file,'        if(simModeIsRTWGen) {\n');
fprintf(file,'            sf_register_machine_exported_symbols(S);\n');
fprintf(file,'        }\n');
           if(gTargetInfo.codingDebug)
fprintf(file,'            if(!simModeIsRTWGen) {\n');
fprintf(file,'                %s_debug_initialize();\n',gMachineInfo.machineName);
fprintf(file,'            }\n');
           end        
fprintf(file,'        %s_initializer();\n',gMachineInfo.machineName);
           for i=1:length(fileNameInfo.linkMachines)
               if(gTargetInfo.codingDebug)
fprintf(file,'                if(!simModeIsRTWGen) {\n');
fprintf(file,'                    %s_debug_initialize();\n',fileNameInfo.linkMachines{i});
fprintf(file,'                }\n');
               end        
fprintf(file,'            %s_initializer();\n',fileNameInfo.linkMachines{i});
           end
fprintf(file,'    }\n');
fprintf(file,'    return;\n');
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'#define PROCESS_MEX_SFUNCTION_EVERY_CALL\n');
fprintf(file,'\n');
fprintf(file,'unsigned int ProcessMexSfunctionEveryCall(int_T nlhs, mxArray *plhs[], int_T nrhs, const mxArray *prhs[]);\n');
fprintf(file,'\n');
fprintf(file,'#include "simulink.c"      %s\n',sf_comment('/* MEX-file interface mechanism */'));
fprintf(file,'\n');
fprintf(file,'static void sf_machine_load_sfunction_ptrs(SimStruct *S)\n');
fprintf(file,'{\n');
fprintf(file,'    ssSetmdlInitializeSampleTimes(S,__mdlInitializeSampleTimes);\n');
fprintf(file,'    ssSetmdlInitializeConditions(S,__mdlInitializeConditions);\n');
fprintf(file,'    ssSetmdlOutputs(S,__mdlOutputs);\n');
fprintf(file,'    ssSetmdlTerminate(S,__mdlTerminate);\n');
fprintf(file,'    ssSetmdlRTW(S,__mdlRTW);\n');
fprintf(file,'    ssSetmdlSetWorkWidths(S,__mdlSetWorkWidths);\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_HASSIMULATIONCONTEXTIO)\n');
fprintf(file,'    ssSetmdlSimulationContextIO(S,__mdlSimulationContextIO);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_START)\n');
fprintf(file,'    ssSetmdlStart(S,__mdlStart);\n');
fprintf(file,'#endif\n');
fprintf(file,'    \n');
fprintf(file,'#if defined(RTW_GENERATED_ENABLE)\n');
fprintf(file,'    ssSetRTWGeneratedEnable(S,__mdlEnable);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(RTW_GENERATED_DISABLE)\n');
fprintf(file,'    ssSetRTWGeneratedDisable(S,__mdlDisable);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_ENABLE)\n');
fprintf(file,'    ssSetmdlEnable(S,__mdlEnable);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_DISABLE)\n');
fprintf(file,'    ssSetmdlDisable(S,__mdlDisable);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_SIM_STATUS_CHANGE)\n');
fprintf(file,'    ssSetmdlSimStatusChange(S,__mdlSimStatusChange);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_EXT_MODE_EXEC)\n');
fprintf(file,'    ssSetmdlExtModeExec(S,__mdlExtModeExec);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_UPDATE)\n');
fprintf(file,'    ssSetmdlUpdate(S,__mdlUpdate);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_PROCESS_PARAMETERS)\n');
fprintf(file,'    ssSetmdlProcessParameters(S,__mdlProcessParameters);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_ZERO_CROSSINGS)\n');
fprintf(file,'    ssSetmdlZeroCrossings(S,__mdlZeroCrossings);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_DERIVATIVES)\n');
fprintf(file,'    ssSetmdlDerivatives(S,__mdlDerivatives);\n');
fprintf(file,'#endif\n');
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'unsigned int ProcessMexSfunctionEveryCall(int_T nlhs, mxArray *plhs[], int_T nrhs, const mxArray *prhs[])\n');
fprintf(file,'{\n');
fprintf(file,'   if (nlhs < 0) {\n');
fprintf(file,'      SimStruct *S = (SimStruct *)plhs[_LHS_SS];\n');
fprintf(file,'      int_T flag = (int_T)(*(real_T*)mxGetPr(prhs[_RHS_FLAG]));\n');
fprintf(file,'      if (flag == SS_CALL_MDL_SET_WORK_WIDTHS) {\n');
fprintf(file,'         sf_machine_load_sfunction_ptrs(S);\n');
fprintf(file,'      }\n');
fprintf(file,'   }\n');
fprintf(file,'   return 0;\n');
fprintf(file,'}\n');
        end
        
        fclose(file);
        try_indenting_file(fileName);

function result = cpp_safe_prototype(prototype)

    global gTargetInfo;

    result = prototype;
    if gTargetInfo.gencpp
        result = ['extern "C" ' result];
    end;
