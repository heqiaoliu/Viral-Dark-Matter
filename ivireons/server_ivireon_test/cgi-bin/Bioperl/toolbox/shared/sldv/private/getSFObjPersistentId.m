function [path type num] = getSFObjPersistentId(objId, blockH)
% Copyright 1990-2010 The MathWorks, Inc.

    num = -1; %#ok<NASGU>
    type = '-'; %#ok<NASGU>

	if nargin<2
		blockH = [];
	end

    objIsa = sf('get',objId,'.isa');
    sfisa = i_util_sfisa; 
    switch(objIsa)
    case sfisa.chart
        num = sf('get',objId,'chart.number');
        type = 'C';
        cn = objId;
    case sfisa.state
        num = sf('get',objId,'state.number');
        type = 'S';
        cn = sf('get',objId,'state.chart');
    case sfisa.transition
        num = sf('get',objId,'transition.number');
        type = 'T';
        cn = sf('get',objId,'transition.chart');                
    case sfisa.data
        num = sf('get',objId,'data.number');
        type = 'D';
        cn = '';
    case sfisa.event
        num = sf('get',objId,'event.number');
        type = 'E';
        cn = '';
    case sfisa.script
        num = 0; %TBD
        type = 'SC';
        path = ['/' sf('get',objId,'.name')];
        return;
    otherwise
        error('SLDV:SF:Unsup', 'Unsupported stateflow element');
    end

    if ~isempty(cn),        
		if isempty(blockH)
			blockH = sf('Private','chart2block',cn);
		else
			if strcmp(get_param(blockH,'BlockType'),'S-Function')
				blockH = get_param(get_param(blockH,'Parent'),'Handle');
			end
		end
		path = getfullname(blockH);
    else
        path = '';
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

% LocalWords:  SLDV TBD Unsup
