function id = new_event(parentId, scope)
%NEW_EVENT( parentId, scope )

%   Jay R. Torgerson
%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.13.2.5 $  $Date: 2007/09/21 19:17:22 $

isEMorTTblk = is_eml_chart(parentId) || is_truth_table_chart(parentId);

if (nargin < 2)
    if isEMorTTblk
        scope = 'OUTPUT_EVENT';
    else
        scope = 'LOCAL_EVENT';
    end
end

if isEMorTTblk
    switch scope
        case {1, 'INPUT_EVENT'}
            type = 'trigger';
        case {2, 'OUTPUT_EVENT'}
            type = 'function_call';
        otherwise
            error('Stateflow:UnexpectedError','Unsupported event scope.');
    end
else
    type = 'event';
end

es = sf('EventsOf', parentId);
name = unique_name_for_list(es, type);

id = sf('new','event','.linkNode.parent', parentId,'.name', name, '.scope', scope);

switch sf('get', id, 'event.scope')
    case 1 % INPUT_EVENT
        sf('set', id, 'event.trigger', 'RISING_EDGE_EVENT');
    case 2 % OUTPUT_EVENT
        sf('set', id, 'event.trigger', 'FUNCTION_CALL');
    otherwise
end
