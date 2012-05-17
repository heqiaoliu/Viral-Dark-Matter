function compute_machine_info

   global gMachineInfo gTargetInfo gDataInfo

   if(isempty(sf('get',gMachineInfo.target,'target.id')))
       construct_coder_error([],sprintf('sfc invoked with an invalid target id %d.',gMachineInfo.target),1);
   end

   gMachineInfo.machineName = sf('get',gMachineInfo.machineId,'machine.name');
   gMachineInfo.mainMachineName = sf('get',gMachineInfo.mainMachineId,'machine.name');
   gMachineInfo.targetName = sf('get',gMachineInfo.target,'target.name');

   if(~gTargetInfo.codingSFunction && ~gTargetInfo.codingRTW && ~gTargetInfo.codingHDL && ~gTargetInfo.codingPLC) % codingCustom
       %% For custom target code generation, filter out charts which have
       %% noCodegen flag set
       gMachineInfo.charts = sf('find',gMachineInfo.charts,'chart.noCodegenForCustomTargets',0);
   end

   % Chart specializations
   numCharts = length(gMachineInfo.charts);
   
   % gMachineInfo.specializations is pre-populated for slhdlc target.
   if ~isfield(gMachineInfo, 'specializations') || isempty(gMachineInfo.specializations)
       gMachineInfo.specializations = cell(1, numCharts);
       for i = 1:numCharts
           gMachineInfo.specializations{i} = sf('Cg', 'get_module_specializations', gMachineInfo.charts(i));
       end
   end

   for i=1:numCharts
       chart = gMachineInfo.charts(i);
       if gTargetInfo.codingHDL
           % do nothing. chart.unique.codegenName is already set in 
           % @hdlstateflow/@StateflowHDLInstantiation/emit.m
       elseif gTargetInfo.codingCustom && sfprivate('target_code_flags','get',gMachineInfo.target,'exportcharts')
           % custom target. if export chart names option is true, then just use the chart name.
           chartUniqueName = get_param(sfprivate('chart2block',chart),'name');
           chartUniqueName = genvarname(chartUniqueName); % make sure the name is cleaned up
           sf('set', chart, 'chart.unique.codegenName', chartUniqueName);
       else
           % In all other cases, chart codegen name is calculated internally in "cdr_get_codegen_name()"
           sf('set', chart, 'chart.unique.codegenName', '');
       end
       sf('set', chart, 'chart.number', i-1);
   end
   
   detect_chart_codegen_name_collisions;

   sf('set',gMachineInfo.machineId,'machine.activeTarget',gMachineInfo.target);
   sf('set',gMachineInfo.machineId,'machine.activeParentTarget',gMachineInfo.parentTarget);
   gMachineInfo.exportedFcnInfo = sf('get',get_relevant_machine,'machine.exportedFcnInfo');

   gMachineInfo.machineDataThreshold = length(sf('DataOf',gMachineInfo.machineId));

   gDataInfo.dataList = sf('DataIn',gMachineInfo.machineId);
   gDataInfo.dataNumbers = sf('get',gDataInfo.dataList,'data.number')';
   [sortedNumbers,indices] = sort(gDataInfo.dataNumbers);
   gDataInfo.dataList = gDataInfo.dataList(indices);
   gDataInfo.dataNumbers = sortedNumbers;

   gMachineInfo.eventList = sf('EventsIn',gMachineInfo.machineId);

   gMachineInfo.machineNumberVariableName = ['_',gMachineInfo.machineName,'MachineNumber_'];
   gMachineInfo.machineData = sf('DataOf',gMachineInfo.machineId);
   gMachineInfo.machineDataNumbers = sf('get',gMachineInfo.machineData,'data.number')';

   gMachineInfo.localData = sf('find',gMachineInfo.machineData,'data.scope','LOCAL_DATA');
   gMachineInfo.localDataNumbers = sf('get',gMachineInfo.localData,'data.number')';

   gMachineInfo.constantData = sf('find',gMachineInfo.machineData,'data.scope','CONSTANT_DATA');
   gMachineInfo.constantDataNumbers = sf('get',gMachineInfo.constantData,'data.number')';

   gMachineInfo.parameterData = sf('find',gMachineInfo.machineData,'data.scope','PARAMETER_DATA');
   gMachineInfo.parameterDataNumbers = sf('get',gMachineInfo.parameterData,'data.number')';

   gMachineInfo.exportedData = sf('find',gMachineInfo.machineData,'data.scope','EXPORTED_DATA');
   gMachineInfo.exportedDataNumbers = sf('get',gMachineInfo.exportedData,'data.number')';

   gMachineInfo.importedData = sf('find',gMachineInfo.machineData,'data.scope','IMPORTED_DATA');
   gMachineInfo.importedDataNumbers = sf('get',gMachineInfo.importedData,'data.number')';

   gMachineInfo.importedEvents = sf('find',gMachineInfo.eventList,'event.scope','IMPORTED_EVENT');
   gMachineInfo.exportedEvents = sf('find',gMachineInfo.eventList,'event.scope','EXPORTED_EVENT');


   gMachineInfo.machineEvents = sf('EventsOf',gMachineInfo.machineId);

   if gTargetInfo.codingLibrary && ~isempty(gMachineInfo.machineEvents)
       construct_coder_error(gMachineInfo.machineId,'Library machines cannot have machine-parented events',1);
   end

   gMachineInfo.localEvents = sf('find',gMachineInfo.machineEvents,'event.scope','LOCAL_EVENT');
   gMachineInfo.importedEvents = sf('find',gMachineInfo.machineEvents,'event.scope','IMPORTED_EVENT');
   gMachineInfo.exportedEvents = sf('find',gMachineInfo.machineEvents,'event.scope','EXPORTED_EVENT');


   gMachineInfo.eventVariableType = 'uint8_T';


   if gTargetInfo.codingRTW
       gMachineInfo.eventVariableName = '%<SLibGetSFEventName()>';
       hasMachineData = ~isempty(setxor(gMachineInfo.machineData, gMachineInfo.constantData));
       hasMachineEvents = ~isempty(gMachineInfo.machineEvents);
       if gTargetInfo.mdlrefInfo.isMultiInst
           if (hasMachineEvents || hasMachineData)
               str = sprintf(gTargetInfo.mdlrefInfo.err);
               construct_coder_error(gMachineInfo.machineId,str,1);
           end
       elseif(gTargetInfo.isErtMultiInstanced)
           if(hasMachineEvents)
               str = sprintf('ERT option "Generate reusable code" cannot be used \nin the presence of machine parented events.');
               construct_coder_error(gMachineInfo.machineId,str,1);
           end
           if(hasMachineData)
               if(strcmp(gTargetInfo.ertMultiInstanceErrCode,'Error'))
                   str = sprintf('ERT option "Generate reusable code" cannot be used \nin the presence of machine parented data \nwhen the ERT option "Reusable code error diagnostic"  \nis set to "Error".');
                   construct_coder_error(gMachineInfo.machineId,str,1);
               elseif(strcmp(gTargetInfo.ertMultiInstanceErrCode,'Warning'))
                   warning('Stateflow:CoderError','ERT option "Generate reusable code" may give unexpected results in the presence of\nmachine parented data.');
               end
           end
       end
       if(gTargetInfo.codingGenerateSFunction && hasMachineEvents)
                   str = 'S-Function Generation is not supported in presence of machine parented events.';
           construct_coder_error(gMachineInfo.machineId,str,1);
       end
   elseif gTargetInfo.codingSFunction
       gMachineInfo.eventVariableName = '_sfEvent_';
   else
       %Coding hdl or custom
       gMachineInfo.eventVariableName = sprintf('_sfEvent_%s_',gMachineInfo.machineName);
   end


   gMachineInfo.sfPrefix = '__sf_';

   dataCount = length(gDataInfo.dataList);
   gDataInfo.dataTypes = cell(1,dataCount);
   gDataInfo.sfDataTypes = cell(1,dataCount);
   gDataInfo.slDataTypes = cell(1,dataCount);


   initialize_data_information(gMachineInfo.machineData,gMachineInfo.machineDataNumbers);
   compute_machine_event_enums;

function compute_machine_event_enums
    global gMachineInfo
%   $Revision: 1.1.6.18.2.1 $  $Date: 2010/06/17 14:13:58 $

    for event = [gMachineInfo.localEvents,gMachineInfo.importedEvents,gMachineInfo.exportedEvents]
        eventUniqueName = sf('CodegenNameOf',event);
        eventNumber = sf('get',event,'event.number');
        enumVal = eventNumber;
        enumStr = ['event_',eventUniqueName];
        sf('set',event,'event.eventEnumStr',enumStr,'event.eventEnumeration',enumVal);
    end

    gMachineInfo.machineDataWithChangeEvent = sf('find',[gMachineInfo.localData,gMachineInfo.exportedData],'data.hasChangeEvent',1);

    gMachineInfo.machineDataChangeEventThreshold = length(gMachineInfo.localEvents) + length(gMachineInfo.importedEvents) + length(gMachineInfo.exportedEvents);
    gMachineInfo.machineEventThreshold = gMachineInfo.machineDataChangeEventThreshold+...
                            length(gMachineInfo.machineDataWithChangeEvent);

    enumVal = gMachineInfo.machineDataChangeEventThreshold;
    for data =  gMachineInfo.machineDataWithChangeEvent
       dataUniqueName = sf('CodegenNameOf',data);
        enumStr = ['data_change_in_',dataUniqueName];
        sf('set',data,'data.changeEventEnumStr',enumStr,'data.changeEventEnumeration',enumVal);
        enumVal = enumVal+1;
    end

function detect_chart_codegen_name_collisions
   global gMachineInfo gTargetInfo
   
   if (gTargetInfo.codingCustom && sfprivate('target_code_flags','get',gMachineInfo.target,'exportcharts'))
       numCharts = length(gMachineInfo.charts);
       names = cell(1, numCharts);
       for i=1:numCharts
          names{i} = sf('get', gMachineInfo.charts(i), 'chart.unique.codegenName');
          for j=1:i-1
              if(strcmp(names{i},names{j}))
                 str = sprintf('Charts (#%d) and (#%d) result in the same filename "%s.c" for the generated code.\n "Use Chart Names with No Mangling" option cannot be used',...
                               gMachineInfo.charts(i),...
                               gMachineInfo.charts(j),...
                               names{i});
                                
              	 construct_coder_error([gMachineInfo.charts(i),gMachineInfo.charts(j)],str,1);
              end
          end
       end
   end
   
