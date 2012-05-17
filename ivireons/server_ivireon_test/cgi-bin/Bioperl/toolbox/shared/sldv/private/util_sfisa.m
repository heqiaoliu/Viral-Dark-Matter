function sfisa = util_sfisa
%UTIL_SFISA - Returns a structure for determining SF classes

%  Copyright 1984-2010 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $  $Date: 2010/01/25 22:44:29 $



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
        sfIsaStruct.script = sf('get','default','script.isa');

    end

    sfisa = sfIsaStruct;
    
    