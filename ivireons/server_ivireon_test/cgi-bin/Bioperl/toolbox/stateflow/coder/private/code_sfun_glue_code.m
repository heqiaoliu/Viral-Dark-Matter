function file = code_sfun_glue_code(fileNameInfo,file,...
                             chart,...
                             chartUniqueName,...
                             specsIdx)

%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.40.4.68 $  $Date: 2010/04/21 22:13:54 $

    %%%%%%%%%%%%%%%%%%%%%%%%% Coding options
    global gTargetInfo gChartInfo gDataInfo gMachineInfo

    % Chart data info has to be calculated after chart specialization is
    % known. i.e. during the chart code generation loop.
    initialize_data_information(gChartInfo.chartData,gChartInfo.chartDataNumbers,chart);

    chartFileNumber = sf('get',chart,'chart.chartFileNumber');
    chartNumber = sf('get',chart,'chart.number');

   [uniqueWkspDataNames,wkspData,II] = sf('Private','get_wksp_data_names_for_chart',chart);
   uniqueWskpData = wkspData(II);

fprintf(file,'/* SFunction Glue Code */\n');

   if gChartInfo.hasTestPoint
fprintf(file,'static void init_test_point_mapping_info(SimStruct *S);\n');
   end

fprintf(file,'void sf_%s_get_check_sum(mxArray *plhs[])\n',chartUniqueName);
fprintf(file,'{\n');
        % TLTODO: Remove chart.checksum and this function if we unify
        % single instantiated chart file naming scheme with that of a
        % multi-instantiated chart.
   
        numSpecs = length(gMachineInfo.specializations{chartNumber+1});
        if numSpecs > 1
            checksumVector = sf('Private', 'md5', gMachineInfo.specializations{chartNumber+1}{specsIdx});
        else
            checksumVector = sf('get',chart,'chart.checksum');
        end
        
        for i=1:4
fprintf(file,'         ((real_T *)mxGetPr((plhs[0])))[%.17g] = (real_T)(%.17gU);\n',(i-1),checksumVector(i));
        end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'mxArray *sf_%s_get_autoinheritance_info(void)\n',chartUniqueName);
fprintf(file,'{\n');
fprintf(file,'     const char *autoinheritanceFields[] = {"checksum","inputs","parameters","outputs"};\n');
fprintf(file,'     mxArray *mxAutoinheritanceInfo = mxCreateStructMatrix(1,1,4,autoinheritanceFields);\n');

fprintf(file,'     {\n');
fprintf(file,'         mxArray *mxChecksum = mxCreateDoubleMatrix(4,1,mxREAL);\n');
fprintf(file,'         double *pr = mxGetPr(mxChecksum);\n');
            checksumVector = sf('SyncAutoinheritanceChecksum', chart);
            for i=1:4
fprintf(file,'             pr[%.17g] = (double)(%.17gU);\n',(i-1),checksumVector(i));
            end
fprintf(file,'         mxSetField(mxAutoinheritanceInfo,0,"checksum",mxChecksum);\n');
fprintf(file,'     }\n');

        dump_autoinheritance_info_for_data(file, gChartInfo.chartInputData, 'inputs');
        dump_autoinheritance_info_for_data(file, gChartInfo.chartParameterData, 'parameters');
        dump_autoinheritance_info_for_data(file, gChartInfo.chartOutputData, 'outputs');
        
fprintf(file,'     return(mxAutoinheritanceInfo);\n');
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static mxArray *sf_get_sim_state_info_%s(void)\n',chartUniqueName);
fprintf(file,'{\n');
fprintf(file,'   const char *infoFields[] = {"chartChecksum", "varInfo"};\n');
fprintf(file,'   mxArray *mxInfo = mxCreateStructMatrix(1, 1, 2, infoFields);\n');
   simStateVarInfo = sf('get', chart, 'chart.simSnapshotVarInfo');
   numStateVars = length(simStateVarInfo);
   segSize = 10;
   encStrName = 'infoEncStr';
   dump_encoded_struct_vector(file, simStateVarInfo, segSize, encStrName);
fprintf(file,'   mxArray *mxVarInfo = sf_mex_decode_encoded_mx_struct_array(%s, %.17g, %.17g);\n',encStrName,numStateVars,segSize);
fprintf(file,'   mxArray *mxChecksum = mxCreateDoubleMatrix(1, 4, mxREAL);\n');
fprintf(file,'   sf_%s_get_check_sum(&mxChecksum);\n',chartUniqueName);
fprintf(file,'   mxSetField(mxInfo, 0, infoFields[0], mxChecksum);\n');
fprintf(file,'   mxSetField(mxInfo, 0, infoFields[1], mxVarInfo);\n');
fprintf(file,'   return mxInfo;\n');
fprintf(file,'}\n');
fprintf(file,'\n');
   if(gChartInfo.codingDebug)
fprintf(file,'static void chart_debug_initialization(SimStruct *S, unsigned int fullDebuggerInitialization)\n');
fprintf(file,'{\n');
fprintf(file,'   if(!sim_mode_is_rtw_gen(S)) {\n');
        if(gTargetInfo.codingMultiInstance)
fprintf(file,'        %s *chartInstance;\n',gChartInfo.chartInstanceTypedef);
fprintf(file,'        chartInstance = (%s *) ((ChartInfoStruct *)(ssGetUserData(S)))->chartInstance;\n',gChartInfo.chartInstanceTypedef);
        end
fprintf(file,'     if(ssIsFirstInitCond(S) && fullDebuggerInitialization==1) {\n');
fprintf(file,'        /* do this only if simulation is starting */\n');
           if gTargetInfo.codingSFunction
              instancePathName = 'ssGetPath(S)';
              simstructPtr = '(void *)S';
           else
              instancePathName = 'NULL';
              simstructPtr = 'NULL';
           end
   	        fclose(file);
   	           	      
            %%% Note that we need to count only those transitions that are not dangling
            %%% G68235
	        chartTransitions = sf('find',gChartInfo.chartTransitions,'~transition.dst.id',0);
   	        debugInfo.chart = chart;
   	        debugInfo.chartStates = gChartInfo.states;
   	        debugInfo.chartFunctions = gChartInfo.functions;
   	        debugInfo.chartTransitions = chartTransitions;
   	        debugInfo.chartDataNumbers = gChartInfo.chartDataNumbers;
   	        debugInfo.chartEvents = gChartInfo.chartEvents;
   	        debugInfo.instancePathName = instancePathName;
   	        debugInfo.simStructPtr = simstructPtr;
   	        debugInfo.dataChangeEventThreshold = gChartInfo.dataChangeEventThreshold;
   	        debugInfo.stateEntryEventThreshold = gChartInfo.stateEntryEventThreshold;
   	        debugInfo.stateExitEventThreshold = gChartInfo.stateExitEventThreshold;
   	        debugInfo.fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartSourceFiles{chartNumber+1}{specsIdx});
   	        debugInfo.dataList = gDataInfo.dataList;
   	        debugInfo.statesWithEntryEvent = gChartInfo.statesWithEntryEvent;  
   	        debugInfo.statesWithExitEvent = gChartInfo.statesWithExitEvent;
   	        debugInfo.dataWithChangeEvent = gChartInfo.dataWithChangeEvent;
   	        debugInfo.chartInstanceVarName = gChartInfo.chartInstanceVarName;
   	        debugInfo.machineNumberVariableName = gMachineInfo.machineNumberVariableName;
   	        sf('Cg','dump_chart_debug_init',debugInfo);
   	        file = fopen(debugInfo.fileName,'A');
fprintf(file,'     } else {\n');
fprintf(file,'        sf_debug_reset_current_state_configuration(%s,%schartNumber,%sinstanceNumber);\n',gMachineInfo.machineNumberVariableName,gChartInfo.chartInstanceVarName,gChartInfo.chartInstanceVarName);
fprintf(file,'     }\n');
fprintf(file,'   }\n');
fprintf(file,'}\n');
fprintf(file,'\n');
   end
fprintf(file,'\n');
fprintf(file,'static void sf_opaque_initialize_%s(void *chartInstanceVar)\n',chartUniqueName);
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
      if(gChartInfo.codingDebug)
fprintf(file,'   chart_debug_initialization(((%s*) chartInstanceVar)->S,0);\n',gChartInfo.chartInstanceTypedef);
      end
      %G236089: initialize parameters before we initialize chart
fprintf(file,'   initialize_params_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
fprintf(file,'   initialize_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
   else
      if(gChartInfo.codingDebug)
fprintf(file,'   chart_debug_initialization(chartInstance.S,0);\n');
      end
      %G236089: initialize parameters before we initialize chart
fprintf(file,'   initialize_params_%s();\n',chartUniqueName);
fprintf(file,'   initialize_%s();\n',chartUniqueName);
   end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void sf_opaque_enable_%s(void *chartInstanceVar)\n',chartUniqueName);
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
fprintf(file,'   enable_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'   enable_%s();\n',chartUniqueName);
   end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void sf_opaque_disable_%s(void *chartInstanceVar)\n',chartUniqueName);
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
fprintf(file,'   disable_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'   disable_%s();\n',chartUniqueName);
   end
fprintf(file,'}\n');
fprintf(file,'\n');
   if sf('Private', 'is_plant_model_chart', chart)
fprintf(file,'   static void sf_opaque_zeroCrossings_%s(void *chartInstanceVar)\n',chartUniqueName);
fprintf(file,'   {\n');
       if gTargetInfo.codingMultiInstance
fprintf(file,'      zeroCrossings_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
      else
fprintf(file,'      zeroCrossings_%s();\n',chartUniqueName);
      end
fprintf(file,'   }\n');
fprintf(file,'   \n');
fprintf(file,'   static void sf_opaque_outputs_%s(void *chartInstanceVar)\n',chartUniqueName);
fprintf(file,'   {\n');
       if gTargetInfo.codingMultiInstance
fprintf(file,'      outputs_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
      else
fprintf(file,'      outputs_%s();\n',chartUniqueName);
      end
fprintf(file,'   }\n');
fprintf(file,'   \n');
fprintf(file,'   static void sf_opaque_derivatives_%s(void *chartInstanceVar)\n',chartUniqueName);
fprintf(file,'   {\n');
       if gTargetInfo.codingMultiInstance
fprintf(file,'      derivatives_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
      else
fprintf(file,'      derivatives_%s();\n',chartUniqueName);
      end
fprintf(file,'   }\n');
   end
fprintf(file,'\n');
fprintf(file,'static void sf_opaque_gateway_%s(void *chartInstanceVar)\n',chartUniqueName);
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
fprintf(file,'   sf_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'   sf_%s();\n',chartUniqueName);
   end
fprintf(file,'}\n');
fprintf(file,'\n');

if instrument_ext_mode_exec
fprintf(file,'static void sf_opaque_ext_mode_exec_%s(void *chartInstanceVar)\n',chartUniqueName);
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
fprintf(file,'   ext_mode_exec_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'   ext_mode_exec_%s();\n',chartUniqueName);
   end
fprintf(file,'}\n');
fprintf(file,'\n');
end

fprintf(file,'static mxArray* sf_internal_get_sim_state_%s(SimStruct* S)\n',chartUniqueName);
fprintf(file,'{\n');
fprintf(file,'    ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);\n');
fprintf(file,'    mxArray *plhs[1] = {NULL};\n');
fprintf(file,'    mxArray *prhs[4];\n');
fprintf(file,'    int mxError = 0;\n');
fprintf(file,'\n');
fprintf(file,'    prhs[0] = mxCreateString("chart_simctx_raw2high");\n');
fprintf(file,'    prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));\n');
       if gTargetInfo.codingMultiInstance
fprintf(file,'    prhs[2] = (mxArray*) get_sim_state_%s((%s*)chartInfo->chartInstance); /* raw sim ctx */\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
       else
fprintf(file,'    prhs[2] = (mxArray*) get_sim_state_%s(); /* raw sim ctx */\n',chartUniqueName);
       end
fprintf(file,'    prhs[3] = sf_get_sim_state_info_%s(); /* state var info */\n',chartUniqueName);
fprintf(file,'\n');
fprintf(file,'    mxError = sf_mex_call_matlab(1, plhs, 4, prhs, "sfprivate");\n');
fprintf(file,'\n');
fprintf(file,'    mxDestroyArray(prhs[0]);\n');
fprintf(file,'    mxDestroyArray(prhs[1]);\n');
fprintf(file,'    mxDestroyArray(prhs[2]);\n');
fprintf(file,'    mxDestroyArray(prhs[3]);\n');
fprintf(file,'\n');
fprintf(file,'    if (mxError || plhs[0] == NULL) {\n');
fprintf(file,'        sf_mex_error_message("Stateflow Internal Error: \\nError calling ''chart_simctx_raw2high''.\\n");\n');
fprintf(file,'    }\n');
fprintf(file,'\n');
fprintf(file,'    return plhs[0];\n');
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void sf_internal_set_sim_state_%s(SimStruct* S, const mxArray *st)\n',chartUniqueName);
fprintf(file,'{\n');
fprintf(file,'    ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);\n');
fprintf(file,'    mxArray *plhs[1] = {NULL};\n');
fprintf(file,'    mxArray *prhs[4];\n');
fprintf(file,'    int mxError = 0;\n');
fprintf(file,'    \n');
fprintf(file,'    prhs[0] = mxCreateString("chart_simctx_high2raw");\n');
fprintf(file,'    prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));\n');
fprintf(file,'    prhs[2] = mxDuplicateArray(st); /* high level simctx */\n');
fprintf(file,'    prhs[3] = (mxArray*) sf_get_sim_state_info_%s(); /* state var info */\n',chartUniqueName);
fprintf(file,'    \n');
fprintf(file,'    mxError = sf_mex_call_matlab(1, plhs, 4, prhs, "sfprivate");\n');
fprintf(file,'    \n');
fprintf(file,'    mxDestroyArray(prhs[0]);\n');
fprintf(file,'    mxDestroyArray(prhs[1]);\n');
fprintf(file,'    mxDestroyArray(prhs[2]);\n');
fprintf(file,'    mxDestroyArray(prhs[3]);\n');
fprintf(file,'    \n');
fprintf(file,'    if (mxError || plhs[0] == NULL) {\n');
fprintf(file,'        sf_mex_error_message("Stateflow Internal Error: \\nError calling ''chart_simctx_high2raw''.\\n");\n');
fprintf(file,'    }\n');
fprintf(file,'    \n');
       if gTargetInfo.codingMultiInstance
fprintf(file,'    set_sim_state_%s((%s*)chartInfo->chartInstance, mxDuplicateArray(plhs[0]));\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
       else
fprintf(file,'    set_sim_state_%s(mxDuplicateArray(plhs[0]));\n',chartUniqueName);
       end
fprintf(file,'    mxDestroyArray(plhs[0]);\n');
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static mxArray* sf_opaque_get_sim_state_%s(SimStruct* S)\n',chartUniqueName);
fprintf(file,'{\n');
if sf('ChartBehaveLikeSubchart', chart)
fprintf(file,'    return NULL;\n');
else
fprintf(file,'    return sf_internal_get_sim_state_%s(S);\n',chartUniqueName);
end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void sf_opaque_set_sim_state_%s(SimStruct* S, const mxArray *st)\n',chartUniqueName);
fprintf(file,'{\n');
if ~sf('ChartBehaveLikeSubchart', chart)
fprintf(file,'    sf_internal_set_sim_state_%s(S, st);\n',chartUniqueName);
end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void sf_opaque_terminate_%s(void *chartInstanceVar)\n',chartUniqueName);
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
fprintf(file,' if(chartInstanceVar!=NULL) {\n');
fprintf(file,'     SimStruct *S = ((%s*) chartInstanceVar)->S;\n',gChartInfo.chartInstanceTypedef);
fprintf(file,'     if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {\n');
fprintf(file,'         sf_clear_rtw_identifier(S);\n');
fprintf(file,'     }\n');
fprintf(file,'     finalize_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);

        if gChartInfo.hasTestPoint
fprintf(file,'     if(!sim_mode_is_rtw_gen(S)) {\n');
fprintf(file,'        ssSetModelMappingInfoPtr(S, NULL);\n');
fprintf(file,'     }\n');
        end

fprintf(file,'     free((void *)chartInstanceVar);\n');
fprintf(file,'     ssSetUserData(S,NULL);\n');
fprintf(file,' }\n');
    else
fprintf(file,'   if (sim_mode_is_rtw_gen(chartInstance.S) || sim_mode_is_external(chartInstance.S)) {\n');
fprintf(file,'       sf_clear_rtw_identifier(chartInstance.S);\n');
fprintf(file,'   }\n');
fprintf(file,'   finalize_%s();\n',chartUniqueName);
   end
fprintf(file,'}\n');
fprintf(file,'\n');
   if gChartInfo.chartHasContinuousTime && ~sf('Private', 'is_plant_model_chart', chart)
fprintf(file,'static void sf_opaque_store_current_config(void *chartInstanceVar)\n');
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
fprintf(file,'   store_current_config((%s*) chartInstanceVar);\n',gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'    store_current_config();\n');
   end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void sf_opaque_restore_before_last_major_step(void *chartInstanceVar)\n');
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
fprintf(file,'   restore_before_last_major_step((%s*) chartInstanceVar);\n',gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'    restore_before_last_major_step();\n');
   end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void sf_opaque_restore_last_major_step(void *chartInstanceVar)\n');
fprintf(file,'{\n');
   if gTargetInfo.codingMultiInstance
fprintf(file,'   restore_last_major_step((%s*) chartInstanceVar);\n',gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'    restore_last_major_step();\n');
   end
fprintf(file,'}\n');
fprintf(file,'\n');
   end
fprintf(file,'\n');
fprintf(file,'static void  sf_opaque_init_subchart_simstructs(void *chartInstanceVar)\n');
fprintf(file,'{\n');
   if gTargetInfo.codingMultiInstance
fprintf(file,'   compInitSubchartSimstructsFcn_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'    compInitSubchartSimstructsFcn_%s();\n',chartUniqueName);
   end
fprintf(file,'}\n');

if sf('ChartBehaveLikeSubchart', chart)

fprintf(file,'boolean_T sf_exported_auto_isStableFcn_%s(SimStruct* S)\n',chartUniqueName);
fprintf(file,'{\n');
   if gTargetInfo.codingMultiInstance
fprintf(file,'   %s *chartInstance;\n',gChartInfo.chartInstanceTypedef);
fprintf(file,'   chartInstance = (%s*)(((ChartInfoStruct *)ssGetUserData(S))->chartInstance);\n',gChartInfo.chartInstanceTypedef);
fprintf(file,'   return isStableFcn_%s(chartInstance);\n',chartUniqueName);
   else
fprintf(file,'   return isStableFcn_%s();\n',chartUniqueName);
   end
fprintf(file,'}\n');
fprintf(file,'   \n');
fprintf(file,'mxArray* sf_exported_auto_compChartGetSimStateFcn_%s(SimStruct* S)\n',chartUniqueName);
fprintf(file,'{\n');
fprintf(file,'    return (mxArray*) sf_internal_get_sim_state_%s(S);\n',chartUniqueName);
fprintf(file,'}\n');
fprintf(file,'void sf_exported_auto_compChartSetSimStateFcn_%s(SimStruct* S, const mxArray* info)\n',chartUniqueName);
fprintf(file,'{\n');
fprintf(file,'    sf_internal_set_sim_state_%s(S, info);\n',chartUniqueName);
fprintf(file,'}\n');
fprintf(file,'  \n');
    dump_auto_export_fcn(file, 'compChartEnterFcn', chartUniqueName)
    dump_auto_export_fcn(file, 'compChartExitFcn', chartUniqueName)
    dump_auto_export_fcn(file, 'compChartDuringFcn', chartUniqueName)
    dump_auto_export_fcn(file, 'compChartEnableFcn', chartUniqueName)
    dump_auto_export_fcn(file, 'compChartDisableFcn', chartUniqueName)
    dump_auto_export_fcn(file, 'compChartGatewayFcn', chartUniqueName)
    dump_auto_export_fcn(file, 'compChangeDetectionInitFcn', chartUniqueName)
    dump_auto_export_fcn(file, 'compChangeDetectionBufferFcn', chartUniqueName)
    dump_auto_export_fcn(file, 'compChartInitCondFcn', chartUniqueName)
    
end

fprintf(file,'   \n');
fprintf(file,'extern unsigned int sf_machine_global_initializer_called(void);\n');
fprintf(file,'static void mdlProcessParameters_%s(SimStruct *S)\n',chartUniqueName);
fprintf(file,'{\n');
fprintf(file,'   int i;\n');
fprintf(file,'   for(i=0;i<ssGetNumRunTimeParams(S);i++) {\n');
fprintf(file,'      if(ssGetSFcnParamTunable(S,i)) {\n');
fprintf(file,'         ssUpdateDlgParamAsRunTimeParam(S,i);\n');
fprintf(file,'      }\n');
fprintf(file,'   }\n');
      %%G340326: mdlProcessParameters is called prior to mdlStart 
      %% for modelreference normal-mode simulation. In this case
      %% we should return early and not worry about updating our internal
      %% cache of param values (which causes crashes). We will get a chance to react to them
      %% during mdlInitconds anyway. 
fprintf(file,'   if(sf_machine_global_initializer_called()) {\n');
   if gTargetInfo.codingMultiInstance
fprintf(file,'       initialize_params_%s((%s*)(((ChartInfoStruct *)ssGetUserData(S))->chartInstance));\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'       initialize_params_%s();\n',chartUniqueName);
   end
fprintf(file,'   }\n');
fprintf(file,'}\n');
fprintf(file,'\n');

if gTargetInfo.codingExtMode
   dworkInfo = sf('get', chart, 'chart.rtwInfo.dWorkVarInfo');
   hasOpaqueTypes = false;

   % For xpc external mode animation. Map dwork rtwIdentifier to c-api testpoint path.
fprintf(file,'mxArray *sf_%s_get_testpoint_info(void)\n',chartUniqueName);
fprintf(file,'{\n');
   tpInfo = dworkInfo([dworkInfo.isTestPoint] ~= 0);

   if ~isempty(tpInfo)
      unneededFns = fieldnames(tpInfo);
      neededFieldIdx = strcmp(unneededFns, 'varName') | strcmp(unneededFns, 'path');
      unneededFns(neededFieldIdx) = [];
      tpInfo = rmfield(tpInfo, unneededFns);
      numTp = length(tpInfo);
   
      segSize = 10;
      encStrName = 'infoEncStr';
      dump_encoded_struct_vector(file, tpInfo, segSize, encStrName);
fprintf(file,'   mxArray *mxTpInfo = sf_mex_decode_encoded_mx_struct_array(%s, %.17g, %.17g);\n',encStrName,numTp,segSize);
fprintf(file,'   return mxTpInfo;\n');
   else
fprintf(file,'   return NULL;\n');
   end
fprintf(file,'}\n');
fprintf(file,'\n');

   if ~isempty(dworkInfo) && any([dworkInfo.isOpaque])
      hasOpaqueTypes = true;
      opaqueTypes = unique({dworkInfo(find([dworkInfo.isOpaque] ~= 0)).type});
fprintf(file,'static void sf_set_sfun_opaque_type_sizes(SimStruct *S)\n');
fprintf(file,'{\n');
fprintf(file,'    DTypeId typeId;\n');
      for t = opaqueTypes(:)'
fprintf(file,'    typeId = ssRegisterDataType(S, "%s");\n',t{1});
fprintf(file,'    ssSetDataTypeSize(S, typeId, sizeof(%s));\n',t{1});
      end
fprintf(file,'}\n');
fprintf(file,'\n');
   end

fprintf(file,'static void sf_set_sfun_dwork_info(SimStruct *S)\n');
fprintf(file,'{\n');
   if ~isempty(dworkInfo)
      % Remove sfun unused fields for compactness
      dworkInfo = rmfield(dworkInfo, {'varName', 'typeSize', 'isOpaque', 'bitWidth', 'extModeUpload', 'isTestPoint', 'objName', 'path', 'resolveToSignalObject'});
      numDWorks = length(dworkInfo);
      segSize = 10;
      encStrName = 'dworkEncStr';
      dump_encoded_struct_vector(file, dworkInfo, segSize, encStrName);
fprintf(file,'   sf_set_encoded_dwork_info(S, %s, %.17g, %.17g);\n',encStrName,numDWorks,segSize);
      if hasOpaqueTypes
fprintf(file,'    sf_set_sfun_opaque_type_sizes(S);\n');
      end
   end
fprintf(file,'}\n');
fprintf(file,'\n');
end

fprintf(file,'static void mdlSetWorkWidths_%s(SimStruct *S)\n',chartUniqueName);
fprintf(file,'{\n');
      %%% set number of s-function parameters
      if(length(uniqueWskpData)>0)
         for i= 1:length(uniqueWskpData)
            if(i==1)
               paramNames = sprintf('"p%d"',i);
            else
               paramNames = sprintf('%s,"p%d"',paramNames,i);
            end
         end
fprintf(file,'   /* Actual parameters from chart:\n');
fprintf(file,'      %s\n',sprintf('%s ',uniqueWkspDataNames{:}));
fprintf(file,'   */\n');
fprintf(file,'   const char_T *rtParamNames[] = {%s};\n',paramNames);
fprintf(file,'\n');

      
fprintf(file,'   ssSetNumRunTimeParams(S,ssGetSFcnParamsCount(S));\n');
         for i= 1:length(uniqueWskpData)
            dataId = uniqueWskpData(i);
            dataNumber = sf('get',dataId,'data.number');
            actualDataType = sf('CoderDataType',dataId);
            if(strcmp(actualDataType,'structure'))
                if ~sf('get', dataId, 'data.isNonTunable')
fprintf(file,'                 ssRegDlgParamAsRunTimeParam(S, %.17g, %.17g, rtParamNames[%.17g], sf_get_param_data_type_id(S,%.17g));\n',(i-1),(i-1),(i-1),(i-1));
                end
                % Currently, there is no support for RT structure parameters
                % in S-functions, so we don't register them as RT
                % parameters as we currently only support non-tunable
                % structure parameters.
                continue;
            end
fprintf(file,'         /* registration for %s*/\n',uniqueWkspDataNames{i});
            if(strcmp(actualDataType,'fixpt'))
fprintf(file,'         {\n');
			    [fixptExponent,fixptSlope,fixptBias,fixptWordLength,fixptIsSigned] = sf('FixPtProps',dataId);
fprintf(file,'             DTypeId dataTypeId = sf_get_fixpt_data_type_id(S,\n');
fprintf(file,'                                                            (unsigned int)%s,\n',sprintf('%d',fixptWordLength));
fprintf(file,'                                                            (bool)%s,\n',sprintf('%d',fixptIsSigned));
fprintf(file,'                                                            (int)%s,\n',sprintf('%d',fixptExponent));
fprintf(file,'                                                            (double)%s,\n',sprintf('%.17g',fixptSlope));
fprintf(file,'                                                            (double)%s);\n',sprintf('%.17g',fixptBias));
fprintf(file,'             ssRegDlgParamAsRunTimeParam(S, %.17g, %.17g, rtParamNames[%.17g], dataTypeId);\n',(i-1),(i-1),(i-1));
fprintf(file,'         }\n');
            else
                if(strcmp(actualDataType,'enumerated'))
                    dataUDDObject = idToHandle(sfroot,dataId);
fprintf(file,'                 ssRegDlgParamAsRunTimeParam(S, %.17g, %.17g, rtParamNames[%.17g], sf_get_enum_data_type_id(S,"?%s"));\n',(i-1),(i-1),(i-1),dataUDDObject.CompiledType);
                else
fprintf(file,'             ssRegDlgParamAsRunTimeParam(S, %.17g, %.17g, rtParamNames[%.17g], %s);\n',(i-1),(i-1),(i-1),gDataInfo.slDataTypes{dataNumber+1});
            end
         end
         end
fprintf(file,'\n');
     end

     if(sf('Cg','time_var_accessed',chart))
fprintf(file,'   ssSetNeedAbsoluteTime(S,1);\n');
     end
fprintf(file,'\n');
      for i=1:length(gChartInfo.functionsToBeExported)
         expFcnName = sf('get',gChartInfo.functionsToBeExported(i),'.name');
fprintf(file,'   ssRegMdlInfo(S, "%s", MDL_INFO_ID_GRPFCNNAME, 0, 0, (void*) ssGetPath(S));\n',expFcnName);
      end

    mainMachineName = sf('get',gMachineInfo.mainMachineId,'machine.name');

fprintf(file,' if(sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {\n');
fprintf(file,'     int_T chartIsInlinable =\n');
fprintf(file,'               (int_T)sf_is_chart_inlinable(S,"%s","%s",%.17g);\n',gMachineInfo.machineName,mainMachineName,chartFileNumber);
fprintf(file,'     ssSetStateflowIsInlinable(S,chartIsInlinable);\n');
fprintf(file,'		ssSetRTWCG(S,sf_rtw_info_uint_prop(S,"%s","%s",%.17g,"RTWCG"));\n',gMachineInfo.machineName,mainMachineName,chartFileNumber);
        if(sf('Cg','enable_is_trivial',chart))
fprintf(file,'      ssSetEnableFcnIsTrivial(S,1);\n');
fprintf(file,'      ssSetDisableFcnIsTrivial(S,1);\n');
        end
fprintf(file,'		ssSetNotMultipleInlinable(S,sf_rtw_info_uint_prop(S,"%s","%s",%.17g,"gatewayCannotBeInlinedMultipleTimes"));\n',gMachineInfo.machineName,mainMachineName,chartFileNumber);
        numOutputFcnCalls = length(gChartInfo.chartFcnCallOutputEvents) + length(gChartInfo.simulinkFunctions);
        if (numOutputFcnCalls > 0)
fprintf(file,'         sf_mark_output_events_with_multiple_callers(S,"%s","%s",%.17g,%.17g);\n',gMachineInfo.machineName,mainMachineName,chartFileNumber,numOutputFcnCalls);
        end
        portNum = 0;
fprintf(file,'     if(chartIsInlinable) {            \n');
            for i=1:(length(gChartInfo.chartInputDataNumbers)+gChartInfo.chartNumSLFcnOutputs)
              %%% if the chart is wholly inlinable, 
              %%% its inputs reusable for RTW optimization
fprintf(file,'           ssSetInputPortOptimOpts(S, %.17g, SS_REUSABLE_AND_LOCAL);\n',portNum);
              portNum = portNum + 1;
            end
            if(length(gChartInfo.chartInputDataNumbers)>0)
fprintf(file,'             sf_mark_chart_expressionable_inputs(S,"%s","%s",%.17g,%.17g);\n',gMachineInfo.machineName,mainMachineName,chartFileNumber,length(gChartInfo.chartInputDataNumbers));
            end
            if(length(gChartInfo.chartOutputDataNumbers)>0)
                % Calculate the total number of output ports of the
                % S-function which need to be marked as reusable or not.
                % This includes real data output ports, connections to
                % _inputs_ of SL functions, and either-edge type output
                % events which are also connected to S-function output
                % ports.
                totalOutputs = length(gChartInfo.chartOutputDataNumbers)+ gChartInfo.chartNumSLFcnInputs + length(gChartInfo.chartOutputEvents) - length(gChartInfo.chartFcnCallOutputEvents);
fprintf(file,'             sf_mark_chart_reusable_outputs(S,"%s","%s",%.17g,%.17g);\n',gMachineInfo.machineName,mainMachineName,chartFileNumber,totalOutputs);
            end
fprintf(file,'     }\n');
        if ~isempty(gChartInfo.chartInputEvents)          
fprintf(file,'       ssSetInputPortOptimOpts(S, %.17g, SS_REUSABLE_AND_LOCAL);\n',portNum);
        end

fprintf(file,'     sf_set_rtw_dwork_info(S,"%s","%s",%.17g);\n',gMachineInfo.machineName,mainMachineName,chartFileNumber);

fprintf(file,'     ssSetHasSubFunctions(S,!(chartIsInlinable));\n');
        if (gChartInfo.executeAtInitialization)
fprintf(file,'           ssSetCallsOutputInInitFcn(S,1);\n');
        end
fprintf(file,' } else {\n');
        if gTargetInfo.codingExtMode
fprintf(file,'        sf_set_sfun_dwork_info(S);\n');
        end
fprintf(file,' }\n');
fprintf(file,'\n');
    hasMachineEvents = ~isempty(gMachineInfo.machineEvents);
    hasExportedChartFunctions = ~isempty(gChartInfo.functionsToBeExported);   
    if ~(hasMachineEvents || hasExportedChartFunctions)
fprintf(file,'     ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);\n');
    end

    checksumVector = double((sf('get',chart,'chart.rtwChecksum')));
fprintf(file,' ssSetChecksum0(S,(%.17gU));\n',checksumVector(1));
fprintf(file,' ssSetChecksum1(S,(%.17gU));\n',checksumVector(2));
fprintf(file,' ssSetChecksum2(S,(%.17gU));\n',checksumVector(3));
fprintf(file,' ssSetChecksum3(S,(%.17gU));\n',checksumVector(4));
fprintf(file,'\n');
    numContStates = double(sf('get',chart,'chart.plantModelingInfo.numContStates'));
    if numContStates > 0
fprintf(file,' ssSetNumContStates(S,%.17g);\n',numContStates);
    else
fprintf(file,' ssSetmdlDerivatives(S, NULL);\n');
    end
fprintf(file,'\n');
fprintf(file,'   ssSetExplicitFCSSCtrl(S,1);\n');
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void mdlRTW_%s(SimStruct *S)\n',chartUniqueName);
fprintf(file,'{\n');
fprintf(file,'   if(sim_mode_is_rtw_gen(S)) {\n');
fprintf(file,'      sf_write_symbol_mapping(S, "%s", "%s",%.17g);\n',gMachineInfo.machineName,mainMachineName,chartFileNumber);
      if sf('Private','is_eml_chart',chart)
fprintf(file,'	      ssWriteRTWStrParam(S, "StateflowChartType", "Embedded MATLAB");\n');
      elseif sf('Private','is_truth_table_chart',chart)
fprintf(file,'       ssWriteRTWStrParam(S, "StateflowChartType", "Truth Table");\n');
      else
fprintf(file,'	      ssWriteRTWStrParam(S, "StateflowChartType", "Stateflow");\n');
      end
fprintf(file,'   }\n');
fprintf(file,'      \n');
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void mdlStart_%s(SimStruct *S)\n',chartUniqueName);
fprintf(file,'{\n');
       if gTargetInfo.codingMultiInstance
fprintf(file,' %s *chartInstance;\n',gChartInfo.chartInstanceTypedef);
fprintf(file,' chartInstance = (%s *)malloc(sizeof(%s));\n',gChartInfo.chartInstanceTypedef,gChartInfo.chartInstanceTypedef);
fprintf(file,' memset(chartInstance, 0, sizeof(%s));\n',gChartInfo.chartInstanceTypedef);
fprintf(file,' if(chartInstance==NULL) {\n');
fprintf(file,'     sf_mex_error_message("Could not allocate memory for chart instance.");\n');
fprintf(file,' }\n');
fprintf(file,' %schartInfo.chartInstance = chartInstance;\n',gChartInfo.chartInstanceVarName);
       else
fprintf(file,' %schartInfo.chartInstance = NULL;\n',gChartInfo.chartInstanceVarName);
       end
     
fprintf(file,' %schartInfo.isEMLChart = %.17g;\n',gChartInfo.chartInstanceVarName,sf('Private','is_eml_chart',chart));
fprintf(file,' %schartInfo.chartInitialized = 0;\n',gChartInfo.chartInstanceVarName);
fprintf(file,' %schartInfo.sFunctionGateway = sf_opaque_gateway_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.initializeChart = sf_opaque_initialize_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.terminateChart = sf_opaque_terminate_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.enableChart = sf_opaque_enable_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.disableChart = sf_opaque_disable_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.getSimState = sf_opaque_get_sim_state_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.setSimState = sf_opaque_set_sim_state_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.getSimStateInfo = sf_get_sim_state_info_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
    if sf('Private', 'is_plant_model_chart', chart)
fprintf(file,'    %schartInfo.zeroCrossings = sf_opaque_zeroCrossings_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,'    %schartInfo.outputs = sf_opaque_outputs_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,'    %schartInfo.derivatives = sf_opaque_derivatives_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
    else
fprintf(file,'    %schartInfo.zeroCrossings = NULL;\n',gChartInfo.chartInstanceVarName);
fprintf(file,'    %schartInfo.outputs = NULL;\n',gChartInfo.chartInstanceVarName);
fprintf(file,'    %schartInfo.derivatives = NULL;\n',gChartInfo.chartInstanceVarName);
    end
fprintf(file,' %schartInfo.mdlRTW = mdlRTW_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.mdlStart = mdlStart_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.mdlSetWorkWidths = mdlSetWorkWidths_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);

       if instrument_ext_mode_exec
fprintf(file,' %schartInfo.extModeExec = sf_opaque_ext_mode_exec_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
       else
fprintf(file,' %schartInfo.extModeExec = NULL;\n',gChartInfo.chartInstanceVarName);
       end

       if gChartInfo.chartHasContinuousTime && ~sf('Private', 'is_plant_model_chart', chart)
fprintf(file,' %schartInfo.restoreLastMajorStepConfiguration = sf_opaque_restore_last_major_step;\n',gChartInfo.chartInstanceVarName);
fprintf(file,' %schartInfo.restoreBeforeLastMajorStepConfiguration = sf_opaque_restore_before_last_major_step;\n',gChartInfo.chartInstanceVarName);
fprintf(file,' %schartInfo.storeCurrentConfiguration = sf_opaque_store_current_config;\n',gChartInfo.chartInstanceVarName);
       else
fprintf(file,' %schartInfo.restoreLastMajorStepConfiguration = NULL;\n',gChartInfo.chartInstanceVarName);
fprintf(file,' %schartInfo.restoreBeforeLastMajorStepConfiguration = NULL;\n',gChartInfo.chartInstanceVarName);
fprintf(file,' %schartInfo.storeCurrentConfiguration = NULL;\n',gChartInfo.chartInstanceVarName);
       end
      
fprintf(file,' %sS = S;\n',gChartInfo.chartInstanceVarName);
fprintf(file,' ssSetUserData(S,(void *)(&(%schartInfo))); %s\n',gChartInfo.chartInstanceVarName,sf_comment('/* register the chart instance with simstruct */'));
fprintf(file,'\n');
      if gTargetInfo.codingMultiInstance
fprintf(file,'     init_dsm_address_info(chartInstance);\n');
      else
fprintf(file,'     init_dsm_address_info();\n');
      end
fprintf(file,' if(!sim_mode_is_rtw_gen(S)) {\n');
      if gChartInfo.hasTestPoint
fprintf(file,'     init_test_point_mapping_info(S);\n');
      end
fprintf(file,' }\n');
fprintf(file,'   sf_opaque_init_subchart_simstructs(%schartInfo.chartInstance);\n',gChartInfo.chartInstanceVarName);

      if(gChartInfo.codingDebug)
fprintf(file,'   chart_debug_initialization(S,1);\n');
      end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'void %s_method_dispatcher(SimStruct *S, int_T method, void *data)\n',chartUniqueName);
fprintf(file,'{\n');
fprintf(file,'  switch (method) {\n');
fprintf(file,'  case SS_CALL_MDL_START:\n');
fprintf(file,'    mdlStart_%s(S);\n',chartUniqueName);
fprintf(file,'    break;\n');
fprintf(file,'  case SS_CALL_MDL_SET_WORK_WIDTHS:\n');
fprintf(file,'    mdlSetWorkWidths_%s(S);\n',chartUniqueName);
fprintf(file,'    break;\n');
fprintf(file,'  case SS_CALL_MDL_PROCESS_PARAMETERS:\n');
fprintf(file,'    mdlProcessParameters_%s(S);\n',chartUniqueName);
fprintf(file,'    break;\n');
fprintf(file,'  default:\n');
fprintf(file,'    /* Unhandled method */\n');
fprintf(file,'    sf_mex_error_message("Stateflow Internal Error:\\n"\n');
fprintf(file,'                         "Error calling %s_method_dispatcher.\\n"\n',chartUniqueName);
fprintf(file,'                         "Can''t handle method %%d.\\n", method);\n');
fprintf(file,'    break;\n');
fprintf(file,'  }\n');
fprintf(file,'}\n');
fprintf(file,'\n');

   if gChartInfo.hasTestPoint
      dump_capi_data_mapping_info_code(file, chart);
   end
   
   return;

function dump_autoinheritance_info_for_data(file, dataSet, fieldName)
fprintf(file,' {\n');
        numData = length(dataSet);
        if numData
fprintf(file,'         const char *dataFields[] = {"size","type","complexity"};\n');
fprintf(file,'         mxArray *mxData = mxCreateStructMatrix(1,%.17g,3,dataFields);\n',numData);
            for i=0:numData-1
fprintf(file,'             {\n');
                    data = dataSet(i+1);
                    dataParsedInfo = sf('DataParsedInfo', data);
                    dataSize = dataParsedInfo.size;
                    while (length(dataSize)<2)
                        dataSize(end+1) = 1;
                    end
                    dataSizeNumel = numel(dataSize);
fprintf(file,'                 mxArray *mxSize = mxCreateDoubleMatrix(1,%.17g,mxREAL);\n',dataSizeNumel);
fprintf(file,'                 double *pr = mxGetPr(mxSize);\n');
                    for s=0:dataSizeNumel-1
fprintf(file,'                 pr[%.17g] = (double)(%.17g);\n',s,dataSize(s+1));
                    end
fprintf(file,'                 mxSetField(mxData,%.17g,"size",mxSize);\n',i);
fprintf(file,'             }            \n');
fprintf(file,'             {\n');
fprintf(file,'                 const char *typeFields[] = {"base","fixpt"};\n');
fprintf(file,'                 mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);\n');
                    base = dataParsedInfo.type.base;
fprintf(file,'                 mxSetField(mxType,0,"base",mxCreateDoubleScalar(%.17g));\n',base);
                    actualDataType = sf('CoderDataType', data);
                    if strcmp(actualDataType,'fixpt')
fprintf(file,'                 {\n');
fprintf(file,'                     const char *fixptFields[] = {"isSigned","wordLength","bias","slope","exponent"};\n');
fprintf(file,'                     mxArray *mxFixpt = mxCreateStructMatrix(1,1,5,fixptFields);\n');
                        isSigned = dataParsedInfo.type.fixpt.isSigned;
fprintf(file,'                     mxSetField(mxFixpt,0,"isSigned",mxCreateDoubleScalar(%.17g));\n',isSigned);
                        wordLength = dataParsedInfo.type.fixpt.wordLength;
fprintf(file,'                     mxSetField(mxFixpt,0,"wordLength",mxCreateDoubleScalar(%.17g));\n',wordLength);
                        bias = dataParsedInfo.type.fixpt.bias;
fprintf(file,'                     mxSetField(mxFixpt,0,"bias",mxCreateDoubleScalar(%.17g));\n',bias);
                        slope = dataParsedInfo.type.fixpt.slope;
fprintf(file,'                     mxSetField(mxFixpt,0,"slope",mxCreateDoubleScalar(%.17g));\n',slope);
                        exponent = dataParsedInfo.type.fixpt.exponent;
fprintf(file,'                     mxSetField(mxFixpt,0,"exponent",mxCreateDoubleScalar(%.17g));\n',exponent);
fprintf(file,'                     mxSetField(mxType,0,"fixpt",mxFixpt);\n');
fprintf(file,'                 }\n');
                    else
fprintf(file,'                     mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));\n');
                    end
fprintf(file,'                 mxSetField(mxData,%.17g,"type",mxType);\n',i);
fprintf(file,'             }                        \n');
                dataComplexity = dataParsedInfo.complexity;
fprintf(file,'             mxSetField(mxData,%.17g,"complexity",mxCreateDoubleScalar(%.17g));\n',i,dataComplexity);
            end
fprintf(file,'         mxSetField(mxAutoinheritanceInfo,0,"%s",mxData);\n',fieldName);
        else
fprintf(file,'         mxSetField(mxAutoinheritanceInfo,0,"%s",mxCreateDoubleMatrix(0,0,mxREAL));            \n',fieldName);
        end
fprintf(file,' }\n');

function dump_encoded_struct_vector(file, sVec, segSize, encStrName)
   len = length(sVec);
   numSeg = ceil(len / segSize);
fprintf(file,'   const char *%s[] = {\n',encStrName);
   for i = 1:numSeg
      idxLow = (i - 1) * segSize + 1;
      idxUp = min(i * segSize, len);
      encStr = sf('mxEncode', sVec(idxLow:idxUp));
      encStr = regexprep(encStr, '"', '\\"');
      if i ~= numSeg
fprintf(file,'   "%s",\n',encStr);
      else
fprintf(file,'   "%s"\n',encStr);
      end
   end
fprintf(file,'   };\n');

function dataTypeMap = construct_capi_data_type_map(testPointData, testPointStates)

   global gDataInfo
   
   numTpData = length(testPointData);
   dataTypeMap = cell(numTpData, 1);
   
   tpDataNumbers = sf('get', testPointData, 'data.number');

   for i = 1:numTpData
      %%% {cName, mwName, numElements, elemMapIndex, dataSize, slDataId, isComplex, isPointer} as a string
      
      idx = tpDataNumbers(i) + 1;
      mwTypeName = gDataInfo.dataTypes{idx};
      slTypeName = gDataInfo.slDataTypes{idx};
      if strcmp(slTypeName, 'SS_ENUM_TYPE')
          cTypeName = ['enum ' mwTypeName];
      else
          cTypeName = mwTypeName;
      end
      dataParsedInfo = sf('DataParsedInfo', testPointData(i));
      isComplex = dataParsedInfo.complexity;

      dataTypeEntry = sprintf('{"%s", "%s", 0, 0, sizeof(%s), %s, %d, 0}', ...
                              cTypeName, mwTypeName, cTypeName, slTypeName, isComplex);
                              
      dataTypeMap{i} = dataTypeEntry;
   end

   if ~isempty(testPointStates)
      stateTpTypeEntry = '{"uint8_T", "uint8_T", 0, 0, sizeof(uint8_T), SS_UINT8, 0, 0}';
      dataTypeMap{numTpData+1} = stateTpTypeEntry;
   end

   return;
      
function [fixPointMap,fixPtDataPresent] = construct_capi_fixed_point_map(testPointData, testPointStates)

   numTpData = length(testPointData);
   fixPointMap = cell(numTpData, 1);
   
   fixPtDataPresent = false;
   
   nonFixptEntry.slope    = 1.0;
   nonFixptEntry.bias     = 0.0;
   nonFixptEntry.wordLen  = 64;
   nonFixptEntry.exponent = 0;
   nonFixptEntry.scaling  = 'rtwCAPI_FIX_RESERVED';
   nonFixptEntry.signed = 0;
   
   for i = 1:numTpData
      actualDataType = sf('CoderDataType', testPointData(i));
      if strcmp(actualDataType,'fixpt')
         fixPtDataPresent = true;
         [exponent, slope, bias, nBits, isSigned] = sf('FixPtProps', testPointData(i));
         
         fixPointEntry.slope    = slope;
         fixPointEntry.bias     = bias;
         fixPointEntry.wordLen  = nBits; 	
         fixPointEntry.exponent = exponent;
         fixPointEntry.scaling  = 'rtwCAPI_FIX_UNIFORM_SCALING';
         fixPointEntry.signed   = isSigned;
      else
         fixPointEntry = nonFixptEntry;
      end
      fixPointMap{i} = fixPointEntry;
   end
   
   if ~isempty(testPointStates)
      fixPointMap{numTpData+1} = nonFixptEntry;
   end

   return;
   
function dimensionMap = construct_capi_dimension_map(testPointData, testPointStates)

   global gDataInfo

   numTpData = length(testPointData);
   dimensionMap = cell(numTpData, 1);
   
   tpDataNumbers = sf('get', testPointData, 'data.number');
   
   for i = 1:numTpData
      %%% dataOrientation, dimArrIdx, numDims, dims   as a structure

      idx = tpDataNumbers(i) + 1;
      dataSize = gDataInfo.dataSizeArrays{idx};
      
      dimensionEntry.numDims = 2; %%% scalar, vector, or matrix, all unified to have 2 dimensions
      dimensionEntry.dimArrIdx = 0; %%% initialize to 0 first
      
      if isempty(dataSize) || prod(dataSize) == 1
         dimensionEntry.orient = 'rtwCAPI_SCALAR';
         dimensionEntry.dims   = [1 1];
      elseif length(dataSize) == 1
         dimensionEntry.orient = 'rtwCAPI_VECTOR';
         dimensionEntry.dims   = [dataSize 1];
      elseif length(dataSize) == 2
         dimensionEntry.orient = 'rtwCAPI_MATRIX_COL_MAJOR';
         dimensionEntry.dims   = dataSize;
      else
         %%% N-D array
         dimensionEntry.numDims = length(dataSize);
         dimensionEntry.orient = 'rtwCAPI_MATRIX_COL_MAJOR_ND';
         dimensionEntry.dims   = dataSize;
      end

      dimensionMap{i} = dimensionEntry;
   end
   
   if ~isempty(testPointStates)
      stateTpDimEntry.numDims = 2;
      stateTpDimEntry.dimArrIdx = 0;
      stateTpDimEntry.orient = 'rtwCAPI_SCALAR';
      stateTpDimEntry.dims   = [1 1];
      dimensionMap{numTpData+1} = stateTpDimEntry;
   end

   return;
   
function [uniqMap, mapping] = uniquify_capi_string_map(map)

   [uniqMap, tmp, mapping] = unique(map);
   return;
   
function [uniqMap, mapping, valueMap] = uniquify_capi_fixpt_map(map, valueArrayName)

   numEntries = length(map);
   
   %%% construct value map for fixpt slope, bias first
   values = zeros(2*numEntries, 1);
   for i = 1:numEntries
      values(2*i - 1) = map{i}.slope;
      values(2*i)     = map{i}.bias;
   end
   [valueMap, tmp, valueMapping] = unique(values);
   
   nonFixptItemStr = '{NULL, NULL, rtwCAPI_FIX_RESERVED, 64, 0, 0}';
   strMap = cell(numEntries, 1);
   for i = 1:numEntries
      slopeIdx = valueMapping(2*i - 1);
      biasIdx  = valueMapping(2*i);
                    
      if strcmp(map{i}.scaling, 'rtwCAPI_FIX_RESERVED')
         strMap{i} = nonFixptItemStr;
      else
         strMap{i} = sprintf('{&%s[%d], &%s[%d], %s, %d, %d, %d}', ...
                             valueArrayName, slopeIdx-1, valueArrayName, biasIdx-1, ...
                             map{i}.scaling, map{i}.wordLen, map{i}.exponent, map{i}.signed);
      end
   end
   
   [uniqMap, tmp, mapping] = unique(strMap);
   return;

function [uniqMap, mapping] = uniquify_capi_dimension_map(map)

   numEntries = length(map);
   strMap = cell(numEntries, 1);
   for i = 1:numEntries
      dimsStr = sprintf('%d,', map{i}.dims);
      strMap{i} = sprintf('%s|%d|%s', map{i}.orient, map{i}.numDims, dimsStr);
   end
   
   [tmp, uniqSampleIdx, mapping] = unique(strMap);
   uniqMap = map(uniqSampleIdx);

   idx = 0;
   for i = 1:length(uniqMap)
      uniqMap{i}.dimArrIdx = idx;
      idx = idx + uniqMap{i}.numDims;
   end

   return;
   
function dump_capi_string_map(file, map)

fprintf(file,'%s','    ');
if(~isempty(map))
    fprintf(file,'%s,\n',map{1:end-1});
    fprintf(file,'%s',map{end});
end


function dump_capi_data_type_map_struct(file, map)

fprintf(file,'\n');
fprintf(file,'static const rtwCAPI_DataTypeMap dataTypeMap[] = {\n');
fprintf(file,'   /* cName, mwName, numElements, elemMapIndex, dataSize, slDataId, isComplex, isPointer */\n');
   dump_capi_string_map(file, map);
fprintf(file,'};\n');

   return;
   
function dump_capi_fixed_point_value_array(file, fixPtValueMap, fixPtValArrName)

   numEntries = length(fixPtValueMap);
fprintf(file,'\n');
fprintf(file,'static real_T %s[%.17g] = {\n',fixPtValArrName,numEntries);
   strMap = cell(numEntries, 1);
   for i = 1:numEntries
      strMap{i} = sprintf('%g', fixPtValueMap(i));
   end
   dump_capi_string_map(file, strMap);
fprintf(file,'};\n');

   return;

function dump_capi_fixed_point_map_struct(file, map)

fprintf(file,'\n');
fprintf(file,'static const rtwCAPI_FixPtMap fixedPointMap[] = {\n');
fprintf(file,'   /* *fracSlope, *bias, scaleType, wordLength, exponent, isSigned */\n');
   dump_capi_string_map(file, map);
fprintf(file,'};\n');

   return;

function dump_capi_dimension_map_struct(file, map)

fprintf(file,'\n');
fprintf(file,'static const rtwCAPI_DimensionMap dimensionMap[] = {\n');
fprintf(file,'   /* dataOrientation, dimArrayIndex, numDims*/\n');
   numEntries = length(map);
   strMap = cell(numEntries, 1);
   for i = 1:numEntries
      strMap{i} = sprintf('{%s, %d, %d}', map{i}.orient, map{i}.dimArrIdx, map{i}.numDims);
   end
   dump_capi_string_map(file, strMap);
fprintf(file,'};\n');

   return;

function dump_capi_dimension_array(file, map)

fprintf(file,'\n');
fprintf(file,'static const uint_T dimensionArray[] = {\n');
   numEntries = length(map);
   strMap = cell(numEntries, 1);
   for i = 1:numEntries
      dimsStr = sprintf('%d, ', map{i}.dims);
      strMap{i} = dimsStr(1:end-2);
   end
   dump_capi_string_map(file, strMap);
fprintf(file,'};\n');

   return;

% A dummy sample time map to satisfy !NULL assertion in floating scope code
function dump_capi_sample_time_map_struct(file)

fprintf(file,'\n');
fprintf(file,'static real_T sfCAPIsampleTimeZero = 0.0;\n');
fprintf(file,'static const rtwCAPI_SampleTimeMap sampleTimeMap[] = {\n');
fprintf(file,'   /* *period, *offset, taskId, mode */\n');
fprintf(file,'   {&sfCAPIsampleTimeZero, &sfCAPIsampleTimeZero, 0, 0}\n');
fprintf(file,'};\n');

   return;
   
function dump_capi_test_point_signals_struct(file, ...
                                             chart, ...
                                             testPointData, ...
                                             testPointStates, ...
                                             dataTypeMapping, ...
                                             fixPointMapping, ...
                                             dimensionMapping)

fprintf(file,'\n');
fprintf(file,'static const rtwCAPI_Signals testPointSignals[] = {\n');
fprintf(file,'   /* addrMapIndex, sysNum, SFRelativePath, dataName, portNumber, dataTypeIndex, dimIndex, fixPtIdx, sTimeIndex */\n');
   numTpData = length(testPointData);
   numTpStates = length(testPointStates);
   strMap = cell(numTpData+numTpStates, 1);
   
   for i = 1:numTpData
      sfRelativePath = sf('FullNameOf', testPointData(i), chart, '.');
      dataName = sf('get', testPointData(i), 'data.name');
      strMap{i} = sprintf('{%d, 0,"StateflowChart/%s", "%s", 0, %d, %d, %d, 0}', ...
                          i-1, sfRelativePath, dataName, ...
                          dataTypeMapping(i)-1, dimensionMapping(i)-1, fixPointMapping(i)-1);
   end

   idx = numTpData + 1;
   for i = 1:numTpStates
      sfRelativePath = sf('FullNameOf', testPointStates(i), chart, '.');
      stateName = sf('get', testPointStates(i), 'state.name');
      strMap{idx} = sprintf('{%d, 0, "StateflowChart/%s", "%s", 0, %d, %d, %d, 0}', ...
                            idx-1, sfRelativePath, stateName, ...
                            dataTypeMapping(numTpData+1)-1, dimensionMapping(numTpData+1)-1, fixPointMapping(numTpData+1)-1);
      idx = idx + 1;
   end

   dump_capi_string_map(file, strMap);
fprintf(file,'};\n');

   return;

function dump_capi_data_mapping_static_info_struct(file, testPointData, testPointStates)

   numTestPoints = length(testPointData) + length(testPointStates);
   
fprintf(file,'\n');
fprintf(file,'static rtwCAPI_ModelMappingStaticInfo testPointMappingStaticInfo = {\n');
fprintf(file,'   /* block signal monitoring */\n');
fprintf(file,'   {\n');
fprintf(file,'      testPointSignals,  /* Block signals Array  */\n');
fprintf(file,'      %.17g   /* Num Block IO signals */\n',numTestPoints);
fprintf(file,'   },\n');
fprintf(file,'\n');
fprintf(file,'   /* parameter tuning */\n');
fprintf(file,'   {\n');
fprintf(file,'      NULL,   /* Block parameters Array    */\n');
fprintf(file,'      0,      /* Num block parameters      */\n');
fprintf(file,'      NULL,   /* Variable parameters Array */\n');
fprintf(file,'      0       /* Num variable parameters   */\n');
fprintf(file,'   },\n');
fprintf(file,'\n');
fprintf(file,'   /* block states */\n');
fprintf(file,'   {\n');
fprintf(file,'      NULL,   /* Block States array        */\n');
fprintf(file,'      0       /* Num Block States          */\n');
fprintf(file,'   },\n');
fprintf(file,'\n');
fprintf(file,'   /* Static maps */\n');
fprintf(file,'   {\n');
fprintf(file,'      dataTypeMap,    /* Data Type Map            */\n');
fprintf(file,'      dimensionMap,   /* Data Dimension Map       */\n');
fprintf(file,'      fixedPointMap,  /* Fixed Point Map          */\n');
fprintf(file,'      NULL,           /* Structure Element map    */\n');
fprintf(file,'      sampleTimeMap,  /* Sample Times Map         */\n');
fprintf(file,'      dimensionArray  /* Dimension Array          */     \n');
fprintf(file,'   },\n');
fprintf(file,'\n');
fprintf(file,'   /* Target type */\n');
fprintf(file,'   "float"\n');
fprintf(file,'};\n');

   return;

function dump_capi_init_data_mapping_info_fcn(file, chart)

   global gTargetInfo gChartInfo
   tpInfoAccessFcns = sf('Cg', 'get_testpoint_accessfcn_names', chart);
   
fprintf(file,'\n');
fprintf(file,'static void init_test_point_mapping_info(SimStruct *S) {\n');
fprintf(file,'   rtwCAPI_ModelMappingInfo *testPointMappingInfo;\n');
fprintf(file,'   void **testPointAddrMap;\n');
   if gTargetInfo.codingMultiInstance
fprintf(file,'   %s *chartInstance;\n',gChartInfo.chartInstanceTypedef);
fprintf(file,'\n');
fprintf(file,'   chartInstance = (%s *) ((ChartInfoStruct *)(ssGetUserData(S)))->chartInstance;\n',gChartInfo.chartInstanceTypedef);
fprintf(file,'   %s(chartInstance);\n',tpInfoAccessFcns.initAddrMapFcn);
fprintf(file,'   testPointMappingInfo = %s(chartInstance);\n',tpInfoAccessFcns.mappingInfoAccessFcn);
fprintf(file,'   testPointAddrMap = %s(chartInstance);\n',tpInfoAccessFcns.addrMapAccessFcn);
   else
fprintf(file,'\n');
fprintf(file,'   %s();\n',tpInfoAccessFcns.initAddrMapFcn);
fprintf(file,'   testPointMappingInfo = %s();\n',tpInfoAccessFcns.mappingInfoAccessFcn);
fprintf(file,'   testPointAddrMap = %s();\n',tpInfoAccessFcns.addrMapAccessFcn);
   end
fprintf(file,'\n');
fprintf(file,'   rtwCAPI_SetStaticMap(*testPointMappingInfo, &testPointMappingStaticInfo);\n');
fprintf(file,'   rtwCAPI_SetLoggingStaticMap(*testPointMappingInfo, NULL);\n');
fprintf(file,'   rtwCAPI_SetInstanceLoggingInfo(*testPointMappingInfo, NULL);\n');
fprintf(file,'   rtwCAPI_SetPath(*testPointMappingInfo, "");\n');
fprintf(file,'   rtwCAPI_SetFullPath(*testPointMappingInfo, NULL);\n');
fprintf(file,'   rtwCAPI_SetDataAddressMap(*testPointMappingInfo, testPointAddrMap);\n');
fprintf(file,'   rtwCAPI_SetChildMMIArray(*testPointMappingInfo, NULL);\n');
fprintf(file,'   rtwCAPI_SetChildMMIArrayLen(*testPointMappingInfo, 0);\n');
fprintf(file,'\n');
fprintf(file,'   ssSetModelMappingInfoPtr(S, testPointMappingInfo);\n');
fprintf(file,'}\n');

   return;

function dump_capi_data_mapping_info_code(file, chart)
   
   global gChartInfo
   
   if ~gChartInfo.hasTestPoint
      return;
   end

   testPointData = gChartInfo.testPoints.data;
   testPointStates = gChartInfo.testPoints.state;
   
   dataTypeMap = construct_capi_data_type_map(testPointData, testPointStates);
   [fixPointMap,fixPtDataPresent] = construct_capi_fixed_point_map(testPointData, testPointStates);
   dimensionMap = construct_capi_dimension_map(testPointData, testPointStates);
   
   fixPtValArrName = 'fixPtSlopeBiasVals';
   [dataTypeMap, dataTypeUniqMapping] = uniquify_capi_string_map(dataTypeMap);
   [fixPointMap, fixPointUniqMapping, fixPtValueMap] = uniquify_capi_fixpt_map(fixPointMap, fixPtValArrName);
   [dimensionMap, dimensionUniqMapping] = uniquify_capi_dimension_map(dimensionMap);
   
   dump_capi_data_type_map_struct(file, dataTypeMap);
   if(fixPtDataPresent)
       dump_capi_fixed_point_value_array(file, fixPtValueMap, fixPtValArrName);
   end
   dump_capi_fixed_point_map_struct(file, fixPointMap);
   dump_capi_dimension_map_struct(file, dimensionMap);
   dump_capi_dimension_array(file, dimensionMap);
   dump_capi_sample_time_map_struct(file);
   dump_capi_test_point_signals_struct(file, chart, testPointData, testPointStates, ...
                                       dataTypeUniqMapping, ...
                                       fixPointUniqMapping, ...
                                       dimensionUniqMapping);
   dump_capi_data_mapping_static_info_struct(file, testPointData, testPointStates);
   dump_capi_init_data_mapping_info_fcn(file, chart);
   
   return;
   
function result = instrument_ext_mode_exec

global gChartInfo gTargetInfo

result = gChartInfo.codingDebug && gTargetInfo.codingExtMode;
return;

function dump_auto_export_fcn(file, fcnName, chartUniqueName)

    global gTargetInfo gChartInfo

fprintf(file,'void sf_exported_auto_%s_%s(SimStruct* S)\n',fcnName,chartUniqueName);
fprintf(file,'{\n');
   if gTargetInfo.codingMultiInstance
fprintf(file,'   %s *chartInstance;\n',gChartInfo.chartInstanceTypedef);
fprintf(file,'   chartInstance = (%s*)(((ChartInfoStruct *)ssGetUserData(S))->chartInstance);\n',gChartInfo.chartInstanceTypedef);
fprintf(file,'   %s_%s(chartInstance);\n',fcnName,chartUniqueName);
   else
fprintf(file,'   %s_%s();\n',fcnName,chartUniqueName);
   end
fprintf(file,'}\n');


