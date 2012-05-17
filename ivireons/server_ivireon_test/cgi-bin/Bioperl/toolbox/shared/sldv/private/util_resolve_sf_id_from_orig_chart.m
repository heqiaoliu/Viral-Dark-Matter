function origId = util_resolve_sf_id_from_orig_chart(newId, origChartId)

%   Copyright 2008-2010 The MathWorks, Inc.
        
    objIsa = sf('get',newId,'.isa');
    sfisa = i_util_sfisa;     
    switch(objIsa)
        case sfisa.chart
            origId = origChartId;        
            
        case {sfisa.state, sfisa.transition, sfisa.junction, sfisa.data, sfisa.event}
            objectList = getObjectList(origChartId);
            ssIdNumber = sf('get',newId,'.ssIdNumber');
            origId = sf('find', objectList, '.ssIdNumber', ssIdNumber);
                                        
        otherwise
            origId = newId;           
    end           
end

function objectList = getObjectList(chartId)
    stateList = sf('get', chartId, 'chart.states');
    transList = sf('get', chartId, 'chart.transitions');
    juncList = sf('get', chartId, 'chart.junctions');
    dataList = sf('DataIn', chartId);
    eventList = sf('EventsIn', chartId);
    objectList = [stateList, transList, juncList, dataList, eventList];
end

function sfisa = i_util_sfisa
    persistent sfIsaStruct;
    
    if isempty(sfIsaStruct)
        sfIsaStruct.chart = sf('get', 'default', 'chart.isa');
        sfIsaStruct.state = sf('get', 'default', 'state.isa');
        sfIsaStruct.junction = sf('get', 'default', 'junction.isa');
        sfIsaStruct.transition = sf('get', 'default', 'transition.isa');
        sfIsaStruct.machine = sf('get', 'default', 'machine.isa');
        sfIsaStruct.target = sf('get', 'default', 'target.isa');
        sfIsaStruct.event = sf('get', 'default', 'event.isa');
        sfIsaStruct.data = sf('get', 'default', 'data.isa');
        sfIsaStruct.instance = sf('get', 'default', 'instance.isa');
        sfIsaStruct.script = sf('get', 'default', 'script.isa');
    end

    sfisa = sfIsaStruct;
end

