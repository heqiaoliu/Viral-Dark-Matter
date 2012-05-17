function code_chart_header_file_rtw(fileNameInfo, chart, specsIdx)


%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2010/04/05 22:58:14 $


    chartNumber = sf('get',chart,'chart.number');
    fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartHeaderFiles{chartNumber+1}{specsIdx});
    chartSpecUniqueName = fileNameInfo.chartSpecUniqueNames{chartNumber+1}{specsIdx};

    sf_echo_generating('Coder',fileName);

    file = fopen(fileName,'Wt');
    if file<3
        construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
        return;
    end

fprintf(file,'%s\n',get_boiler_plate_comment('chart',chart));

    %% For charts participating RTWCG, only generate the boiler plate comment
    %% NOTE: We have to generate at least an empty file for incremental codegen to work
    if sf('get', chart, 'chart.rtwInfo.RTWCG')
        fclose(file);
        try_indenting_file(fileName);
        return;
    end

fprintf(file,'%%implements "chartHeader" "C"\n');
fprintf(file,'%%function CacheOutputs(block,system) void\n');

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Types
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   types = sf('Cg','get_types',chart);

   %% First, emit types that do not depend on user types to model_types.h
   gen_typedefs(file, chart, types, false, chartSpecUniqueName);

   %% Emit types that depend on user types to model.h
   gen_typedefs(file, chart, types, true, chartSpecUniqueName);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%% function Decls
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%openfile externFcnsBuf\n');
    funcs = sf('Cg','get_unshared_functions',chart);
    for func = funcs
         codeStr = sf('Cg','get_fcn_decl',func,0);
fprintf(file,'   %s\n',strip_trailing_new_lines(codeStr));
    end
fprintf(file,'%%closefile externFcnsBuf\n');
fprintf(file,'%%<SLibCacheCodeToFile("sf_chart_fcn_decl",externFcnsBuf)>\n');


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%% shared function Decls
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   modelName = sf('get',get_relevant_machine,'machine.name');
   if(~rtw_gen_shared_utils(modelName))
fprintf(file,'   %%openfile externFcnsBuf\n');
       funcs = sf('Cg','get_shared_functions',chart);
       for func = funcs
            codeStr = sf('Cg','get_fcn_decl',func,0);
            fcnName = sf('Cg','get_symbol_name', func);
fprintf(file,'         %%if %%<!SFLibLookupUtilityFunctionDecl("%s")>\n',fcnName);
fprintf(file,'            %s\n',strip_trailing_new_lines(codeStr));
fprintf(file,'            %%<SFLibInsertUtilityFunctionDecl("%s")>\n',fcnName);
fprintf(file,'         %%endif\n');
       end
fprintf(file,'   %%closefile externFcnsBuf\n');
fprintf(file,'   %%<SLibCacheCodeToFile("sf_chart_fcn_decl",externFcnsBuf)>\n');
   end

fprintf(file,'\n');
fprintf(file,'%%endfunction %%%% CacheOutputs\n');
    fclose(file);
    try_indenting_file(fileName);

function gen_typedefs(file, chart, types, emitDependentOnUserTypes, chartSpecUniqueName)
if isempty(types)
   return;
end

fprintf(file,'%%openfile typedefsBuf\n');

      chartInstanceTypedefGuard = ['_' upper(['CS',chartSpecUniqueName,'_ChartStruct'])];
      if emitDependentOnUserTypes
          chartInstanceTypedefGuard = [chartInstanceTypedefGuard '_custom'];
      end
      for type = types
           dependOnUserTypes = sf('Cg', 'does_type_depend_on_user_types', type);
           if dependOnUserTypes == emitDependentOnUserTypes
               codeStr = sf('Cg','get_type_def',type,0);
fprintf(file,'            %s\n',codeStr);
           end
      end
fprintf(file,'%%closefile typedefsBuf\n');
fprintf(file,'   %%if !WHITE_SPACE(typedefsBuf)\n');
fprintf(file,'      %%openfile tempBuf\n');
fprintf(file,'#ifndef %s\n',chartInstanceTypedefGuard);
fprintf(file,'#define %s\n',chartInstanceTypedefGuard);
fprintf(file,'      %%<typedefsBuf>\\\n');
fprintf(file,' #endif /* %s */\n',chartInstanceTypedefGuard);
fprintf(file,'      %%closefile tempBuf\n');
if emitDependentOnUserTypes
fprintf(file,'%%<SLibCacheCodeToFile("sf_chart_data_basedOnUserType_typedef",tempBuf)>\n');
else
fprintf(file,'%%<SLibCacheCodeToFile("sf_chart_standalone_data_typedef",tempBuf)>\n');
end
fprintf(file,'   %%endif\n');
fprintf(file,'\n');


