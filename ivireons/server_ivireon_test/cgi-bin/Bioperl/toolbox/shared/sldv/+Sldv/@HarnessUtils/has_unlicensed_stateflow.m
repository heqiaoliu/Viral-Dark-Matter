function status = has_unlicensed_stateflow(modelH)

%   Copyright 2008-2009 The MathWorks, Inc.

    status = false;

    machineId = sf('find','all','machine.name',get_param(modelH,'Name'));
    if ~isempty(machineId) && machineId>0
        [charts,linkCharts] = sf('get',machineId,'.charts','.linkCharts');
        if ( ~isempty(charts) || ~isempty(linkCharts))            
            allEMLblocks = all(sf('Private','is_eml_chart',charts)) && ...
                all(is_eml_link(linkCharts));                                        
            status = ~allEMLblocks && ~license('test','Stateflow');     
        end
    end
end

function res = is_eml_link(id)
    res = zeros(size(id));
    for i=1:length(id)
        res(i) = strcmp(sf('Private', 'get_linktype', id(i)), 'eml');
    end
end
% LocalWords:  linktype
