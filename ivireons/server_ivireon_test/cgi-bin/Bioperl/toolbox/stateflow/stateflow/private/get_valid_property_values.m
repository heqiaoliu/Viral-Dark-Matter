function propVals = get_valid_property_values(obj, propName)

% Copyright 2003-2009 The MathWorks, Inc.

    clsName = get(classhandle(obj), 'Name');
    
    switch (clsName)
    case 'Data'
        propVals = get_valid_data_property_values(obj, propName);
    case {'Event', 'Trigger', 'FunctionCall'}
        propVals = event_values_l(obj, propName);
    case 'Transition'
        propVals = transition_values_l(obj, propName);
    case {'State', 'AtomicSubchart'}
        propVals = state_values_l(obj, propName);
    otherwise
        propVals = get_default_property_values(obj, propName);      
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pv = event_values_l(obj, propName)

    parent = get(classhandle(obj.up), 'Name');
    switch propName    
    case 'Scope'
        switch parent
        case {'Chart'}
            pv = {'Local'; 'Input'; 'Output'};
        case {'BlockDiagram'}
            pv = {'Local'; 'Imported'; 'Exported'};
        case {'EMChart', 'TruthTableChart'}
            pv = {'Input'; 'Output'};
        otherwise
            pv = {'Local'};
        end
        
    case 'Trigger'
        scope = obj.Scope;
        if (isequal(scope, 'Output'))
            pv = {'Either'; 'Function call'};
        elseif (isequal(scope, 'Input'))
            pv = {'Either'; 'Rising'; 'Falling'; 'Function call'};
        else
            pv = {};
        end
        
    case 'Port'        
        scope = obj.scope;
        class = obj.class; % Stateflow event, trigger or function call
        pv = {};
        if (isequal(scope, 'Input'))
            others = find(obj.up, '-depth', 1, '-isa', class, 'Scope', scope); %#ok<GTARG>
            for i=1:length(others)
                pv = [pv;{sf_scalar2str(i)}];
            end
        end
        if (isequal(scope, 'Output'))
            otherData = find(obj.up, '-depth', 1, '-isa', 'Stateflow.Data', 'Scope', scope); %#ok<GTARG>
            dl = length(otherData);
            others = find(obj.up, '-depth', 1, '-isa', class, 'Scope', scope); %#ok<GTARG>
            for i=1:length(others)
                pv = [pv;{sf_scalar2str(dl+i)}];
            end
        end        
        
    otherwise
        pv = get_default_property_values(obj, propName);
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pv = transition_values_l(obj, propName)

    switch propName    
    case 'ExecutionOrder'        
        pv = {};
        try
            siblingList = sf('SemanticSiblingsOf',obj.id);        
            for i=1:length(siblingList)
                execOrder = sf('get', siblingList(i), 'transition.executionOrder');
                pv = [pv;{sf_scalar2str(execOrder)}];
            end
        catch ME
        end    
    otherwise
        pv = get_default_property_values(obj, propName);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pv = state_values_l(obj, propName)

    switch propName
    case 'ExecutionOrder'        
        pv = {};
        try
            siblingList = sf('SemanticSiblingsOf',obj.id);        
            for i=1:length(siblingList)
                execOrder = sf('get', siblingList(i), 'state.executionOrder');
                pv = [pv;{sf_scalar2str(execOrder)}];
            end
        catch ME
        end
        
    otherwise
        pv = get_default_property_values(obj, propName);
    end
    