function sfH = getSLFunction(simH)
    % Gets the Stateflow.SLFunction object corresponding to a
    % Simulink.Subsystem object.
    %
    % Usage:
    %   sfH = sfprivate('getSLFunction', simH)
    % where
    %   simH: UDD handle to a Simulink.Subsystem object contained inside a
    %   Stateflow chart.
    % returns
    %   sfH: UDD handle of Stateflow object corresponding to the SL
    %   function.

    %   Copyright 2008-2009 The MathWorks, Inc.


    isParentStateFlowSubSystem = strcmp(get_param(simH.Parent,'Type'),'block') ...
        && strcmp(get_param(simH.Parent,'BlockType'),'SubSystem') ...
        && strcmp(get_param(simH.Parent,'MaskType'),'Stateflow');
    
    % return empty if the subsystem is not under a Stateflow chart.
    if ~isParentStateFlowSubSystem
        sfH = [];
        return
    end

    r = sfroot;
    chartId = sfprivate('block2chart', simH.Parent);
    fcnIds = sf('FunctionsIn', chartId);

    fcnId = sf('find', fcnIds, 'state.simulink.isSimulinkFcn', 1, ...
                               'state.simulink.blockName', simH.Name);

    if ~isempty(fcnId)
        sfH = r.idToHandle(fcnId);
    else
        sfH = [];
    end
