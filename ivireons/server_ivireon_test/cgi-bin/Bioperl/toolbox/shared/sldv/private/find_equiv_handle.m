function blockH = find_equiv_handle(sfId)

% Copyright 2005-2010 The MathWorks, Inc.

    blockH = 0;

    objIsa = sf('get',sfId,'.isa');
    sfisa = util_sfisa;

    switch(objIsa)
    case sfisa.chart
        chartId = sfId;
    case sfisa.state
        chartId = sf('get',sfId,'.chart');
    case sfisa.transition
        chartId = sf('get',sfId,'.chart');
    case sfisa.junction
        chartId = sf('get',sfId,'.chart');
    case sfisa.event
        blockH = find_equiv_handle(sf('get',sfId,'.linkNode.parent'));
        return;
    case sfisa.data    
        blockH = find_equiv_handle(sf('get',sfId,'.linkNode.parent'));
        return;
    case sfisa.machine
        blockH = get_param(sf('FullNameOf',sfId,'.'),'Handle');
        return;
    case sfisa.script
        blockH = sfId;
        return;
    otherwise
        return;
    end
    blockH = sf('Private','chart2block',chartId);
    if length(blockH)>1
        blockH = sf('get',sfId,'.activeInstance');
    end   
