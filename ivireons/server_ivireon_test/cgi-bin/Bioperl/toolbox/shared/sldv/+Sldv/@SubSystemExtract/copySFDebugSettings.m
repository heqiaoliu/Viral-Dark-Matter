function copySFDebugSettings(obj)

%   Copyright 2010 The MathWorks, Inc.

    [~, mexf] = inmem;
    sfIsHere = any(strcmp(mexf,'sf'));
    if(sfIsHere)
        rt = sfroot;
        sourceMachine = rt.find('-isa','Stateflow.Machine','Name',get_param(obj.OrigModelH,'Name'));
        destMachine = rt.find('-isa','Stateflow.Machine','Name',get_param(obj.ModelH,'Name'));

        if ~isempty(destMachine) && ~isempty(sourceMachine)           

            destMachine.Debug.Animation.Enabled  = sourceMachine.Debug.Animation.Enabled;
            destMachine.Debug.Animation.Delay = sourceMachine.Debug.Animation.Delay;
            destMachine.Debug.BreakOn.ChartEntry = sourceMachine.Debug.BreakOn.ChartEntry;
            destMachine.Debug.BreakOn.EventBroadcast = sourceMachine.Debug.BreakOn.EventBroadcast;
            destMachine.Debug.BreakOn.StateEntry = sourceMachine.Debug.BreakOn.StateEntry;
            destMachine.Debug.DisableAllBreakpoints = sourceMachine.Debug.DisableAllBreakpoints;
            destMachine.Debug.RunTimeCheck.CycleDetection = sourceMachine.Debug.RunTimeCheck.CycleDetection;
            destMachine.Debug.RunTimeCheck.DataRangeChecks = sourceMachine.Debug.RunTimeCheck.DataRangeChecks;
            destMachine.Debug.RunTimeCheck.StateInconsistencies = sourceMachine.Debug.RunTimeCheck.StateInconsistencies;
            destMachine.Debug.RunTimeCheck.TransitionConflicts = sourceMachine.Debug.RunTimeCheck.TransitionConflicts;
        end
    end
end