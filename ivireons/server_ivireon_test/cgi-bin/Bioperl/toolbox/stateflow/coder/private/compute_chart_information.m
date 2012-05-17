function	compute_chart_information(chart)

%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.17.4.25 $  $Date: 2010/02/25 08:36:46 $
%   Compute instance independent chart information.

	global gTargetInfo gChartInfo gMachineInfo

	sortAllStatesByName = 1; % this will override the geometrical sort
                            % for AND states => required for G84273
    if(sf('Private','is_eml_based_chart',chart) &&...
          sf('get',chart,'chart.eml.noDebugging'))
        gChartInfo.codingDebug = 0;
    else
        gChartInfo.codingDebug = gTargetInfo.codingDebug;
    end

	gChartInfo.states = sf('SubstatesIn',chart,sortAllStatesByName);% passing 1 to get a lexicographic
	gChartInfo.functions = sf('FunctionsIn',chart);
    gChartInfo.simulinkFunctions = sf('find', gChartInfo.functions, 'state.simulink.isSimulinkFcn', 1);
	gChartInfo.chartTransitions = sf('Private','chart_real_transitions',chart);

	if(export_chart_functions(chart))
		gChartInfo.functionsToBeExported = sf('find',gChartInfo.functions,'state.treeNode.parent',chart);
	else
		gChartInfo.functionsToBeExported = [];
	end
	gChartInfo.functionsNotToBeExported = sf('Private','vset',gChartInfo.functions,'-',gChartInfo.functionsToBeExported);

	gChartInfo.chartData = sf('DataIn',chart);
	gChartInfo.chartDataNumbers = sf('get',gChartInfo.chartData,'data.number')';

	allTemporaryData = sf('find',gChartInfo.chartData,'data.scope','TEMPORARY_DATA');

	chartTemporaryData = sf('find',allTemporaryData,'data.linkNode.parent',chart);
	funcTemporaryData = sf('find',allTemporaryData,'~data.linkNode.parent',chart);

    % G269739, G142162: throw proper errors
    if(gTargetInfo.codingRTW && ~isempty(gChartInfo.functionsToBeExported))
        
       if gTargetInfo.mdlrefInfo.isMultiInst
           str = sprintf(gTargetInfo.mdlrefInfo.err);
           construct_coder_error(gMachineInfo.machineId,str,1);
       end
       if(gTargetInfo.isErtMultiInstanced)
           str = sprintf('ERT option "Generate reusable code" cannot be used in the presence of exported graphical functions.');
           if(strcmp(gTargetInfo.ertMultiInstanceErrCode,'Error'))
               construct_coder_error(chart,str,1);
           elseif(strcmp(gTargetInfo.ertMultiInstanceErrCode,'Warning'))
               warning(str);
           end
       end
       if(strcmp(gTargetInfo.rtwProps.systemTargetFile,'grt_malloc.tlc'))
           str = sprintf('GRT Malloc Code-format cannot be used in the presence of exported graphical functions.');
           construct_coder_error(chart,str,1);           
       end
    end
           
	% WISH fix this later. for now we consider temporary data same as local data

	if(sf('HasAtleastOneSubstate',chart))
		% has substates. cannot have temporary data
		gChartInfo.chartLocalData = [chartTemporaryData,sf('find',gChartInfo.chartData,'data.scope','LOCAL_DATA')];
		gChartInfo.chartLocalDataNumbers = sf('get',gChartInfo.chartLocalData,'data.number')';
		chartTemporaryData = [];
		chartTemporaryDataNumbers = [];
	else
		% stateless chart. can have temporary data
		gChartInfo.chartLocalData = [sf('find',gChartInfo.chartData,'data.scope','LOCAL_DATA')];
		gChartInfo.chartLocalDataNumbers = sf('get',gChartInfo.chartLocalData,'data.number')';
		chartTemporaryDataNumbers = sf('get',chartTemporaryData,'data.number')';
	end
	funcTemporaryDataNumbers = sf('get',funcTemporaryData,'data.number')';

	gChartInfo.chartConstantData = sf('find',gChartInfo.chartData,'data.scope','CONSTANT_DATA');
	gChartInfo.chartConstantDataNumbers = sf('get',gChartInfo.chartConstantData,'data.number')';

	chartParentedData = sf('DataOf',chart);

	gChartInfo.chartInputData = sf('find',chartParentedData,'data.scope','INPUT_DATA');
	gChartInfo.chartInputDataNumbers = sf('get',gChartInfo.chartInputData,'data.number')';

	gChartInfo.chartParameterData = sf('find',chartParentedData,'data.scope','PARAMETER_DATA');
	gChartInfo.chartParameterDataNumbers = sf('get',gChartInfo.chartParameterData,'data.number')';

	gChartInfo.chartOutputData = sf('find',chartParentedData,'data.scope','OUTPUT_DATA');
	gChartInfo.chartOutputDataNumbers = sf('get',gChartInfo.chartOutputData,'data.number')';

    gChartInfo.chartEvents = sf('EventsIn',chart);
    gChartInfo.chartLocalEvents = sf('find',gChartInfo.chartEvents,'event.scope','LOCAL_EVENT');
    gChartInfo.chartOutputEvents = sf('find',gChartInfo.chartEvents,'event.scope','OUTPUT_EVENT');
    gChartInfo.chartInputEvents = sf('find',gChartInfo.chartEvents,'event.scope','INPUT_EVENT');
    gChartInfo.chartFcnCallOutputEvents = sf('find',gChartInfo.chartOutputEvents,'event.trigger','FUNCTION_CALL_EVENT');
    sf('set',gChartInfo.chartFcnCallOutputEvents,'event.functionCallIndex',[0:(length(gChartInfo.chartFcnCallOutputEvents)-1)]');

    gChartInfo.chartNumSLFcnOutputs = 0;
    gChartInfo.chartNumSLFcnInputs = 0;
    for i=1:length(gChartInfo.simulinkFunctions)
        fcnData = sf('DataOf', gChartInfo.simulinkFunctions(i));
        gChartInfo.chartNumSLFcnInputs = gChartInfo.chartNumSLFcnInputs + length(sf('find', fcnData, 'data.scope', 'FUNCTION_INPUT_DATA'));
        gChartInfo.chartNumSLFcnOutputs = gChartInfo.chartNumSLFcnOutputs + length(sf('find', fcnData, 'data.scope', 'FUNCTION_OUTPUT_DATA'));
    end

	gChartInfo.chartHasContinuousTime = 0;
	if gTargetInfo.codingSFunction
		gChartInfo.chartHasContinuousTime = sf('Cg','get_chart_has_continuous_time',chart);
	elseif gTargetInfo.codingRTW
	   if(sf('get',chart,'chart.updateMethod')==2) && ~sf('Private', 'is_plant_model_chart', chart)
	      msgString = sprintf('Continuous update specified for this chart %s (#%d).\n This is not supported for RTW.',sf('FullNameOf',chart,'/'),chart);
          construct_coder_error(chart,msgString);
	   end
	end

    if(gTargetInfo.codingSFunction)
        gTargetInfo.codingMultiInstance = sf('ChartIsMultiInstantiable', chart);
    end
    
	if gTargetInfo.codingRTW
		gChartInfo.chartInstanceVarName = '%<LibSFChartInstance(block)>';
	else
		if(gTargetInfo.codingMultiInstance)
			gChartInfo.chartInstanceVarName = 'chartInstance->';
		else
			gChartInfo.chartInstanceVarName = 'chartInstance.';
		end
	end   
   
   if sf('Private', 'is_sf_chart', chart)
       hChart = idToHandle(sfroot, chart);
       % The UDD interface shows the semantic "execute at initialization"
       % value accounting for things such as the actual raw "execute at
       % initialization" being unset but the chart being a Moore chart.
       gChartInfo.executeAtInitialization = hChart.ExecuteAtInitialization;
       gChartInfo.initializeOutput = hChart.InitializeOutput;
   else
       gChartInfo.executeAtInitialization = 0;
       gChartInfo.initializeOutput = 0;
   end
