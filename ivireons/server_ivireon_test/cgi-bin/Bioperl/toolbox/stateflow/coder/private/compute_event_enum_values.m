function  compute_event_enum_values(chart,...
                                   file,...
                                   defineFlag)
%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.3.2.10 $  $Date: 2010/02/25 08:36:48 $

	global gChartInfo gMachineInfo

	for event = [gChartInfo.chartLocalEvents,gChartInfo.chartInputEvents]
		eventNumber = sf('get',event,'event.number');
		eventUniqueName = sf('CodegenNameOf',event);
		
		enumVal = eventNumber;
		enumStr = ['event_',eventUniqueName];
		sf('set',event,'event.eventEnumStr',enumStr,'event.eventEnumeration',enumVal);
	end

    if(sf('feature', 'EMLActionLangInfrastructure') == 0)
        gChartInfo.statesWithEntryEvent = sf('find',gChartInfo.states,'state.hasEntryEvent',1);
        gChartInfo.statesWithExitEvent = sf('find',gChartInfo.states,'state.hasExitEvent',1);
        gChartInfo.dataWithChangeEvent = sf('find',gChartInfo.chartData,'data.hasChangeEvent',1);

        if(isempty(gChartInfo.chartEvents))
            gChartInfo.dataChangeEventThreshold = gMachineInfo.machineEventThreshold;
        else
            gChartInfo.dataChangeEventThreshold = max(sf('get',gChartInfo.chartEvents,'event.number'))+1;
        end

        enumVal = gChartInfo.dataChangeEventThreshold;
        for data = gChartInfo.dataWithChangeEvent
            dataNumber = sf('get',data,'data.number');
            dataUniqueName = sf('CodegenNameOf',data);
            enumStr = ['data_change_in_',dataUniqueName];
            sf('set',data,'data.changeEventEnumStr',enumStr,'data.changeEventEnumeration',enumVal);
            enumVal = enumVal+1;
        end
        gChartInfo.stateEntryEventThreshold = enumVal;
        for state = gChartInfo.statesWithEntryEvent
    		enumStr = ['entry_to_',sf('CodegenNameOf',state)];
        	sf('set',state,'state.entryEventEnumStr',enumStr,'state.entryEventEnumeration',enumVal);
            enumVal = enumVal+1;
        end

        gChartInfo.stateExitEventThreshold = enumVal;
        for state = gChartInfo.statesWithExitEvent
            enumStr = ['exit_from_',sf('CodegenNameOf',state)];
            sf('set',state,'state.exitEventEnumStr',enumStr,'state.exitEventEnumeration',enumVal);
            enumVal = enumVal+1;
        end
    end
