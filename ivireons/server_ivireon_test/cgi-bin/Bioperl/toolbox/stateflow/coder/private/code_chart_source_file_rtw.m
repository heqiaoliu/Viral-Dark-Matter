function code_chart_source_file_rtw(fileNameInfo, chart, specsIdx)

%    Copyright 1995-2009 The MathWorks, Inc.
%    $Revision: 1.1.6.30 $  $Date: 2009/11/13 05:20:02 $


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%  GLOBAL VARIABLES
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   global gChartInfo

   chartNumber = sf('get',chart,'chart.number');
   fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartSourceFiles{chartNumber+1}{specsIdx});
   sf_echo_generating('Coder',fileName);

   file = fopen(fileName,'Wt');
   if file<3
      construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
      return;
   end

fprintf(file,'%%implements "chartSource" "C"\n');

fprintf(file,'%%function ChartConfig(block, system) void\n');
fprintf(file,'  %%createrecord chartConfiguration { ...\n');
fprintf(file,'          executeAtInitialization  %.17g ...\n',gChartInfo.executeAtInitialization);
fprintf(file,'  }\n');
fprintf(file,'  %%return chartConfiguration\n');
fprintf(file,'%%endfunction\n');

   %% For charts participating RTWCG, only generate the ChartDataMap function,
   %% which is used by globalmaplib.tlc.
   if sf('get', chart, 'chart.rtwInfo.RTWCG')
       dump_chart_data_map_with_unified_dwork(file, chart);

       fclose(file);
       try_indenting_file(fileName);
       return;
   end

fprintf(file,'%%function ChartDefines(block,system) void\n');
fprintf(file,'   %%openfile chartConstBuf\n');

         namedConsts = sf('Cg','get_named_consts',chart);
         for namedConst = namedConsts
            codeStr = sf('Cg','get_named_const_def',namedConst,1);
fprintf(file,'         %s\n',strip_trailing_new_lines(codeStr));
         end
     
fprintf(file,'   %%closefile chartConstBuf\n');
fprintf(file,'   %%return chartConstBuf\n');
fprintf(file,'%%endfunction %%%% ChartDefines\n');

fprintf(file,'%%function ChartFunctions(block,system) void\n');
      x = sf('Cg','get_cg_fcn_data',chart);
      excludedFcn = x.chartGateway.ptr;
      funcs = sf('Cg','get_unshared_functions',chart);
fprintf(file,'   %%openfile chartFcnsBuf\n');

        % Inserting Target Math Fcn generation here
        fcnGenString = sf('Cg','get_module_used_target_fcns',chart);
fprintf(file,'     %s\n',strip_trailing_new_lines(fcnGenString));
%        % Inserting Target Math Includes here
%        moduleIncludeString = sf('Cg','get_module_target_include_directives',chart);
%...     $strip_trailing_new_lines(moduleIncludeString)$

         for func = funcs
            if ~isequal(func{1}.ptr,excludedFcn)
               declStr = sf('Cg', 'get_fcn_decl', func,1);
               if ~isempty(declStr)
fprintf(file,'              %%openfile fcnDeclBuf\n');
fprintf(file,'              %s\n',strip_trailing_new_lines(declStr));
fprintf(file,'              %%closefile fcnDeclBuf\n');
fprintf(file,'              %%assign fcnRec = SLibFcnPrototypeToRec(fcnDeclBuf)\n');
fprintf(file,'              %%addtorecord fcnRec Abstract "" Category "stateflow" GeneratedBy "" Type "Sub" GeneratedFor FcnGeneratedFor(system)\n');
fprintf(file,'              %%<SLibDumpFunctionBanner(fcnRec)>\n');
fprintf(file,'              %%undef fcnRec\n');
               end
               codeStr = sf('Cg','get_fcn_def',func,1);
fprintf(file,'            %s\n',strip_trailing_new_lines(codeStr));
            end
         end

         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % Multi-word fixed-point maximum wordsize (in bits)
         nMaxMWBits = sf('Cg','get_max_fxp_multiword_size',chart);
         if nMaxMWBits ~= 0
fprintf(file,'          %%<DeclareFixedPointWordSizeUsage(%.17g)>\n',nMaxMWBits);
         end
         
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % RTW symbol naming pass for unshared fncs and named constants
         symbols  = [funcs namedConsts];
         numSym   = length(symbols);
         symNames = cell(1, numSym);

         for i = 1:numSym
            % Extract symbol name only if following pattern exists.
            % Otherwise regexprep() would leave the original symbol string untouched.
            symNames{i} = regexprep( sf('Cg', 'get_symbol_name', symbols(i)), ...
                                     '^%<block\.SymbolMapping\.(\S+)>$', '$1' );
         end
         symInfo.functions = symNames(1:length(funcs));
         symInfo.defines = symNames(length(funcs)+1:end);

         sf('set',chart,'chart.rtwInfo.sfSymbols', symInfo);
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
fprintf(file,'   %%closefile chartFcnsBuf\n');
fprintf(file,'   %%return chartFcnsBuf\n');
fprintf(file,'%%endfunction %%%% ChartFunctions\n');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Function prototypes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%function ChartFunctionProtos(block,system) void\n');
fprintf(file,'   %%openfile prototypesBuf\n');

      funcs = sf('Cg','get_unshared_functions',chart);
         for func = funcs
            codeStr = strip_trailing_new_lines(sf('Cg','get_fcn_decl',func,1));
            if ~isempty(codeStr)
fprintf(file,'   %s\n',codeStr);
            end
         end

fprintf(file,'   %%closefile prototypesBuf\n');
fprintf(file,'   %%<SLibCacheSystemCodeToFile("sys_sf_chart_fcn_prototype",system,prototypesBuf)>\n');
fprintf(file,'%%endfunction %%%% ChartFunctionProtos\n');


fprintf(file,'%%function ChartSharedFunctions(block,system) void\n');
fprintf(file,'   %%openfile chartFcnsBuf\n');
         modelName = sf('get',get_relevant_machine,'machine.name');
         if(~rtw_gen_shared_utils(modelName))
            sharedFuncs = sf('Cg', 'get_shared_functions', chart);
            if(~isempty(funcs))
               for func = sharedFuncs
                  fcnName = sf('Cg','get_symbol_name', func);
                  fcnDefCodeStr = sf('Cg','get_fcn_def',func,1);
fprintf(file,'                 %%if %%<!SFLibLookupUtilityFunction("%s")>\n',fcnName);
fprintf(file,'                    %s\n',strip_trailing_new_lines(fcnDefCodeStr));
fprintf(file,'                    %%<SFLibInsertUtilityFunction("%s")>\n',fcnName);
fprintf(file,'                 %%endif\n');
               end
            end
         end
fprintf(file,'   %%closefile chartFcnsBuf\n');
fprintf(file,'   %%return chartFcnsBuf\n');
fprintf(file,'%%endfunction %%%% ChartSharedFunctions\n');

    if sf('Private', 'is_plant_model_chart', chart)
fprintf(file,'%%function Derivatives(block,system) void\n');
      x = sf('Cg','get_cg_fcn_data',chart);
fprintf(file,'   %%openfile codeBuf\n');
         codeStr = sf('Cg','get_fcn_body',x.derivatives);
fprintf(file,'      %s\n',strip_trailing_new_lines(codeStr));
fprintf(file,'   %%closefile codeBuf\n');
fprintf(file,'   %%return codeBuf\n');
fprintf(file,'%%endfunction  %%%% Derivatives\n');

fprintf(file,'%%function ZeroCrossings(block,system) void\n');
      x = sf('Cg','get_cg_fcn_data',chart);
fprintf(file,'   %%openfile codeBuf\n');
         codeStr = sf('Cg','get_fcn_body',x.zeroCrossings);
fprintf(file,'      %s\n',strip_trailing_new_lines(codeStr));
fprintf(file,'   %%closefile codeBuf\n');
fprintf(file,'   %%return codeBuf\n');
fprintf(file,'%%endfunction  %%%% ZeroCrossings\n');
    end

% The chart gateway is always inlined so we only emit the body
% for this function
fprintf(file,'%%function Outputs(block,system) void\n');
      x = sf('Cg','get_cg_fcn_data',chart);
fprintf(file,'   %%openfile codeBuf\n');
    if sf('Private', 'is_plant_model_chart', chart)
fprintf(file,'    if (%%<LibIsMajorTimeStep()>) {\n');
         codeStr = sf('Cg','get_fcn_body',x.chartGateway);
fprintf(file,'      %s\n',strip_trailing_new_lines(codeStr));
fprintf(file,'    }\n');
       codeStr = sf('Cg','get_fcn_body',x.outputs);
fprintf(file,'    %s\n',strip_trailing_new_lines(codeStr));
    else
       codeStr = sf('Cg','get_fcn_body',x.chartGateway);
fprintf(file,'    %s\n',strip_trailing_new_lines(codeStr));
    end
fprintf(file,'   %%closefile codeBuf\n');
fprintf(file,'   %%return codeBuf\n');
fprintf(file,'%%endfunction  %%%% Outputs\n');

% The chart data initializer is always inlined so we only emit the body
% for this function
fprintf(file,'%%function InlinedInitializerCode(block,system) Output\n');
fprintf(file,'   %%<SLibResetSFChartInstanceAccessed(block)>\\\n');
fprintf(file,'   %%openfile initBodyBuf\n');
         x = sf('Cg','get_cg_fcn_data',chart);
         str = sf('Cg','get_fcn_body',x.chartDataInitializer);
fprintf(file,'      %s\n',str);
fprintf(file,'   %%closefile initBodyBuf\n');
fprintf(file,'   %%if !WHITE_SPACE(initBodyBuf)\n');
fprintf(file,'      /* Initialize code for chart: ''%%<LibGetBlockName(block)>'' */\n');
fprintf(file,'      %%<initBodyBuf>\\\n');
fprintf(file,'   %%endif\n');
fprintf(file,'%%endfunction\n');
fprintf(file,'\n');
fprintf(file,'\n');
% The chart enable is always inlined so we only emit the body
% for this function
fprintf(file,'%%function EnableUnboundOutputEventsCode(block,system) Output\n');
fprintf(file,'   %%openfile initBodyBuf\n');
         x = sf('Cg','get_cg_fcn_data',chart);
         str = sf('Cg','get_fcn_body',x.chartEnable);
fprintf(file,'      %s\n',str);
fprintf(file,'   %%closefile initBodyBuf\n');
fprintf(file,'   %%if !WHITE_SPACE(initBodyBuf)\n');
fprintf(file,'      /* Enable code for chart: ''%%<LibGetBlockName(block)>'' */\n');
fprintf(file,'      %%<initBodyBuf>\\\n');
fprintf(file,'   %%endif\n');
fprintf(file,'%%endfunction\n');
fprintf(file,'\n');
% The chart disable is always inlined so we only emit the body
% for this function
fprintf(file,'%%function DisableUnboundOutputEventsCode(block,system) Output\n');
fprintf(file,'   %%openfile initBodyBuf\n');
         x = sf('Cg','get_cg_fcn_data',chart);
         str = sf('Cg','get_fcn_body',x.chartDisable);
fprintf(file,'      %s\n',str);
fprintf(file,'   %%closefile initBodyBuf\n');
fprintf(file,'   %%if !WHITE_SPACE(initBodyBuf)\n');
fprintf(file,'      /* Disable code for chart: ''%%<LibGetBlockName(block)>'' */\n');
fprintf(file,'      %%<initBodyBuf>\\\n');
fprintf(file,'   %%endif\n');
fprintf(file,'%%endfunction\n');
fprintf(file,'\n');

% Emit shared functions and header files.
fprintf(file,'%%function DumpSharedUtils(block,system) void\n');
   funcs = sf('Cg', 'get_shared_functions', chart);
   if(~isempty(funcs))
      modelName = sf('get',get_relevant_machine,'machine.name');
      if(rtw_gen_shared_utils(modelName))
fprintf(file,'      %%if EXISTS(::GenUtilsSrcInSharedLocation) && (::GenUtilsSrcInSharedLocation == 1)\n');
fprintf(file,'         %%if !ISFIELD(::CompiledModel, "RTWInfoMatFile")\n');
fprintf(file,'            %%<LoadRTWInfoMatFileforTLC()>\n');
fprintf(file,'         %%endif    \n');
         for func = funcs
            fcnName = sf('Cg','get_symbol_name', func);
            fcnDefCodeStr = sf('Cg','get_fcn_def',func,1);
            fcnDeclCodeStr = sf('Cg','get_fcn_decl',func,0);         
            sharedUtilTargetIncludes = sf('Cg','get_shared_fcn_target_includes',func);
            dump_single_shared_util(file, fcnName, fcnDefCodeStr, fcnDeclCodeStr, sharedUtilTargetIncludes);
         end
fprintf(file,'      %%else\n');
fprintf(file,'         %%error WISH change error message, unable to dump shared utils\n');
fprintf(file,'      %%endif  \n');
      end
   end
fprintf(file,'%%endfunction\n');
fprintf(file,'\n');

   dump_chart_data_map_with_unified_dwork(file, chart);

   fclose(file);
   try_indenting_file(fileName);
   
   
function dump_single_shared_util(file, fcnName, fcnDefCodeStr, fcnDeclCodeStr, sharedUtilTargetIncludes)
fprintf(file,' %%if %%<!SFLibLookupUtilityFunction("%s")>\n',fcnName);
fprintf(file,'     %%<SFLibInsertUtilityFunction("%s")>\n',fcnName);
fprintf(file,'     %%openfile defCode\n');
fprintf(file,'     %s\n',sharedUtilTargetIncludes);
fprintf(file,'     %s\n',fcnDefCodeStr);
fprintf(file,'     %%closefile defCode\n');
fprintf(file,'     %%openfile declCode\n');
fprintf(file,'     %s\n',fcnDeclCodeStr);
fprintf(file,'     %%closefile declCode\n');
fprintf(file,'     %%<SLibDumpUtilsSourceCode("%s", declCode, defCode)>\n',fcnName);
fprintf(file,' %%endif\n');


function dump_chart_data_map_with_unified_dwork(file, chart)

    dworkInfo = sf('get', chart, 'chart.rtwInfo.dWorkVarInfo');
    numDWorks = length(dworkInfo);
    
fprintf(file,'%%function ChartDataMap(block, system) void\n');
fprintf(file,'  %%createrecord ChartDataElements {\\\n');
fprintf(file,'    NumChartData   %.17g \\\n',numDWorks);
fprintf(file,'    ChartDataDefaults {\\\n');
fprintf(file,'      RecordType   "ChartData"\\\n');
fprintf(file,'      Dimensions   []\\\n');
fprintf(file,'      IsTestPoint  0\\\n');
fprintf(file,'    }\\\n');

    for i = 1:numDWorks
        
fprintf(file,'    ChartData {\\\n');
fprintf(file,'      Name         "%s"\\\n',dworkInfo(i).varName);
fprintf(file,'      SFName       "%s"\\\n',dworkInfo(i).objName);
fprintf(file,'      Path         "%s"\\\n',dworkInfo(i).path);

      if ~isempty(dworkInfo(i).size)
          % Not a scalar, which is the default case
          dims = sprintf('%d,', dworkInfo(i).size);
fprintf(file,'      Dimensions   [%s]\\\n',dims(1:end-1));
      end
      
      if dworkInfo(i).isTestPoint
fprintf(file,'      IsTestPoint  1\\\n');
      end
        
fprintf(file,'    }\\\n');
    end
    
fprintf(file,'  }\n');
fprintf(file,'  %%return ChartDataElements\n');
fprintf(file,'%%endfunction\n');
