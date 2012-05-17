function generate_code_for_charts_and_machine(fileNameInfo,codingRebuildAll)

% Copyright 2003-2010 The MathWorks, Inc.

   global gMachineInfo
   global gTargetInfo

   incCodeGenInfo = compute_inc_codegen_info(fileNameInfo,codingRebuildAll);
   display_startup_message(fileNameInfo);
   genCount = 0;


   mainMachineId = gMachineInfo.mainMachineId;
   machineName = gMachineInfo.machineName;
   mainMachineName = gMachineInfo.mainMachineName;
   targetName = gMachineInfo.targetName;

   for i = 1:length(gMachineInfo.charts)
        chart = gMachineInfo.charts(i);
        chartFileNumber = sf('get',chart,'chart.chartFileNumber');
        chartName = sf('get',chart,'.name');

        %TLTODO: handle code generated now
        sf('set', chart, 'chart.codeGeneratedNow', any(incCodeGenInfo.flags{i}));
        if ~any(incCodeGenInfo.flags{i})
            continue;
        end
            
        compute_chart_information(chart);
        
        if gTargetInfo.codingRTW
            rtwInstanceInfo = [];
        end

        numSpecs = length(gMachineInfo.specializations{i});
        for j = 1:numSpecs
            if(~incCodeGenInfo.flags{i}(j))
                continue;
            end

            thisSpec = gMachineInfo.specializations{i}{j};
            
            %TLTODO: handle folllowing block
            % Let EML know what charts need to be reconsidered for its resolved functions
            targetId = gTargetInfo.target;
            targetName = sf('get',targetId,'.name');
            targetName0 = sfprivate('get_eml_metadata_target_name',targetName);
            machineName0 = sfprivate('get_eml_metadata_machine_name',machineName);
            rebuildMetaData = sf('get', mainMachineId, '.eml.rebuildMetaData');
            if ~isempty(rebuildMetaData) && isfield(rebuildMetaData, targetName0)
                chartFiles = rebuildMetaData.(targetName0).(machineName0).rebuiltChartFiles;
                if ~any(chartFiles == chartFileNumber)
                    chartFiles = sort([chartFiles chartFileNumber]);
                    rebuildMetaData.(targetName0).(machineName0).rebuiltChartFiles = chartFiles;
                    sf('set',mainMachineId,'.eml.rebuildMetaData', rebuildMetaData);
                end
            end
                
            genCount=genCount+1;
            if(mod(genCount,80)==0)
                newLine = 1;
            else
                newLine = 0;
            end
        
            display_chart_codegen_message(chart,newLine);

            try
                errorsOccurred = construct_module(chart, 0.0, thisSpec, fileNameInfo);
            catch ME
                errorsOccurred = 1;
                construct_coder_error(chart,ME.message,0);
            end

            if ~errorsOccurred
                sfprivate('sf_compile_stats', 'snap', machineName, chartFileNumber, targetName, 'generate_code_for_chart_begin');
                SLPerfTools.Tracer.logStateflowData('sf_compile', machineName, targetName, mainMachineName, chartName, 'generate_code_for_chart', true);
                code_chart_header_file(fileNameInfo,chart,j);
                code_chart_source_file(fileNameInfo,chart,j);
                sf('Cg','destroy_module',chart);
                SLPerfTools.Tracer.logStateflowData('sf_compile', machineName, targetName, mainMachineName, chartName, 'generate_code_for_chart', false);
                sfprivate('sf_compile_stats', 'snap', machineName, chartFileNumber, targetName, 'generate_code_for_chart_end');
                
                if gTargetInfo.codingRTW
                    tlcFile = fileNameInfo.chartTLCFiles{i}{j};
                    outputFcn = fileNameInfo.chartOutputsFcns{i}{j};
                    initFcn = fileNameInfo.chartInitializeFcns{i}{j};
            
                    instanceInfo = get_instance_rtw_info(chart, thisSpec, tlcFile, outputFcn, initFcn);
                    rtwInstanceInfo = [rtwInstanceInfo instanceInfo];
                end
            end
        end
        
        if gTargetInfo.codingRTW
            sf('set', chart, 'chart.rtwInfo.instanceInfo', rtwInstanceInfo);
        end
   end
   
   if gTargetInfo.codingRTW
        gMachineInfo.ctxInfo.eventVarUsed = false;
        for i = 1:length(gMachineInfo.charts)
            chart = gMachineInfo.charts(i);
            if(~any(incCodeGenInfo.flags{i})) %TLTODO: better way to handle???
                chartFileNumber = sf('get', chart, 'chart.chartFileNumber');
                chartNumber = find(incCodeGenInfo.infoStruct.chartFileNumbers==chartFileNumber);
                if (incCodeGenInfo.infoStruct.chartInfo(chartNumber).usesGlobalEventVar) 
                    gMachineInfo.ctxInfo.eventVarUsed = true;
                end
            else
                % if we are here, we have just generated the TLC file for this chart
                % chart.rtwInfo is uptodate 
                if sf('get', chart, 'chart.rtwInfo.usesGlobalEventVar')
                    gMachineInfo.ctxInfo.eventVarUsed = true;
                end
            end
        end
        
        for i = 1:length(fileNameInfo.linkMachines)
            infoStruct = sf('Private','infomatman','load','binary',fileNameInfo.linkMachines{i},gMachineInfo.mainMachineId,'rtw');
            if any([infoStruct.chartInfo.usesGlobalEventVar]);
                gMachineInfo.ctxInfo.eventVarUsed = true;
            end
        end
   else
        gMachineInfo.ctxInfo.eventVarUsed = true;      
   end
   
    
   if ~gTargetInfo.codingHDL && ~gTargetInfo.codingPLC
       sf('Cg','construct_machine_module',gMachineInfo.ctxInfo);
       if(sf('Private','coder_error_count_man','get')==0)
           sfprivate('sf_compile_stats', 'snap', machineName, targetName, 'generate_code_for_machine_begin');
           SLPerfTools.Tracer.logStateflowData('sf_compile', machineName, targetName, mainMachineName, 'machine', 'generate_code_for_machine', true);
           fileNameInfo = code_aux_support_files(fileNameInfo);
           code_machine_header_file(fileNameInfo);
           code_machine_source_file(fileNameInfo);
           code_interface_and_support_files(incCodeGenInfo,fileNameInfo);
           SLPerfTools.Tracer.logStateflowData('sf_compile', machineName, targetName, mainMachineName, 'machine', 'generate_code_for_machine', false);
           sfprivate('sf_compile_stats', 'snap', machineName, targetName, 'generate_code_for_machine_end');
       end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function display_startup_message(fileNameInfo)
   global gMachineInfo
   msgString = sprintf('Code Directory :\n     "%s"\n',fileNameInfo.targetDirName);
   sf('Private','sf_display','Coder',msgString);

   msgString = sprintf('Machine (#%d): "%s"  Target : "%s"\n',gMachineInfo.machineId,gMachineInfo.machineName,gMachineInfo.targetName);
   sf('Private','sf_display','Coder',msgString);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function display_chart_codegen_message(chart,newLine)
   chartFullName = sf('FullNameOf',chart,'/');
   chartShortName = chartFullName(find(chartFullName=='/', 1, 'last' )+1:end);
   msgString = sprintf('\nChart "%s" (#%d):\n',chartShortName,chart);
   sf('Private','sf_display','Coder',msgString);
   if(newLine)
      sf('Private','sf_display','Coder',sprintf('.\n'),2);
   else
      sf('Private','sf_display','Coder','.',2);
   end      
   sfprivate('set_model_status_bar',sf('get',get_relevant_machine,'machine.name'),['Generating code for ',chartShortName]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y_or_n = yes_or_no(val)
    if val
        y_or_n = 'Yes';
    else
        y_or_n = 'No';
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function instanceInfo = get_instance_rtw_info(chart, spec, tlcFile, outputFcn, initFcn)

    instanceInfo.specialization = spec;
    instanceInfo.TLCFile = tlcFile;
    instanceInfo.OutputsFcn = outputFcn;
    instanceInfo.InitializeFcn = initFcn;
    instanceInfo.ReusableOutputs = sf('get', chart, 'chart.rtwInfo.reusableOutputs');
    instanceInfo.ExpressionableInputs = sf('get', chart, 'chart.rtwInfo.expressionableInputs');
    instanceInfo.Inline = yes_or_no(sf('get', chart, 'chart.rtwInfo.chartWhollyInlinable'));
    instanceInfo.usesDSPLibrary = sf('get', chart, 'chart.rtwInfo.usesDSPLibrary');
    instanceInfo.sfSymbols = sf('get', chart, 'chart.rtwInfo.sfSymbols');
    instanceInfo.gatewayCannotBeInlinedMultipleTimes = sf('get', chart, 'chart.rtwInfo.gatewayCannotBeInlinedMultipleTimes');
    instanceInfo.outputEventsWithMultipleCallers = sf('get', chart, 'chart.rtwInfo.outputEventsWithMultipleCallers');
    instanceInfo.dworkInfo = sf('get', chart, 'chart.rtwInfo.dWorkVarInfo');
    instanceInfo.RTWCG = sf('get', chart, 'chart.rtwInfo.RTWCG');
    instanceInfo.requiredStackSize = sf('get', chart, 'chart.rtwInfo.requiredStackSize');
    
