function code_sfun_imported_functions(file, chart)
    states = sf('SubstatesIn', chart);
    compStates = sf('find', states, 'state.simulink.isComponent', 1);
    
    subchartIds = zeros(size(compStates));
    for i=1:length(compStates)
        subchartIds(i) = sfprivate('subchart_man', 'getSubchartId', compStates(i));
    end
    subchartIds = unique(subchartIds);
    
    if ~isempty(subchartIds)
fprintf(file,'     /* Declarations for functions imported from subchart components */\n');
    end
    
    for i=1:length(subchartIds)
        specs = sf('Cg', 'get_module_specializations', subchartIds(i));
        for j = 1:length(specs)
            chartUniqueName = sf('AtomicSubchartCodegenNameOf', subchartIds(i), specs{j});
            dump_imported_functions(file, chartUniqueName);
        end
    end
end

function dump_imported_functions(file, chartUniqueName)
fprintf(file,' extern boolean_T sf_exported_auto_isStableFcn_%s(SimStruct* S);\n',chartUniqueName);
fprintf(file,' extern mxArray*  sf_exported_auto_compChartGetSimStateFcn_%s(SimStruct* S);\n',chartUniqueName);
fprintf(file,' extern void      sf_exported_auto_compChartSetSimStateFcn_%s(SimStruct* S, const mxArray* st);\n',chartUniqueName);
fprintf(file,' extern void      sf_exported_auto_compChartDuringFcn_%s(SimStruct* S);\n',chartUniqueName);
fprintf(file,' extern void      sf_exported_auto_compChartEnterFcn_%s(SimStruct* S);\n',chartUniqueName);
fprintf(file,' extern void      sf_exported_auto_compChartExitFcn_%s(SimStruct* S);\n',chartUniqueName);
fprintf(file,' extern void      sf_exported_auto_compChartGatewayFcn_%s(SimStruct* S);\n',chartUniqueName);
fprintf(file,' extern void      sf_exported_auto_compChartEnableFcn_%s(SimStruct* S);\n',chartUniqueName);
fprintf(file,' extern void      sf_exported_auto_compChartDisableFcn_%s(SimStruct* S);\n',chartUniqueName);
fprintf(file,' extern void      sf_exported_auto_compChangeDetectionInitFcn_%s(SimStruct* S);\n',chartUniqueName);
fprintf(file,' extern void      sf_exported_auto_compChangeDetectionBufferFcn_%s(SimStruct* S);\n',chartUniqueName);
fprintf(file,' extern void      sf_exported_auto_compChartInitCondFcn_%s(SimStruct* S);\n',chartUniqueName);
end
