function setSFDebugSettings(modelH, settings)

%   Copyright 2009 The MathWorks, Inc.

    if ~isempty(settings)
        modelName = get_param(modelH, 'Name');
        m = find(sfroot, '-isa', 'Stateflow.Machine', 'Name', modelName); %#ok<GTARG>
        m.Debug.Animation.Enabled = settings.animation;
        m.Debug.BreakOn.ChartEntry = settings.chartE;
        m.Debug.BreakOn.EventBroadcast = settings.eventB;
        m.Debug.BreakOn.StateEntry = settings.stateE;
        m.Debug.DisableAllBreakpoints = settings.disableAll;
        m.Debug.RunTimeCheck.CycleDetection = settings.cycleDetect;
        m.Debug.RunTimeCheck.DataRangeChecks = settings.dataRange;
        m.Debug.RunTimeCheck.StateInconsistencies = settings.stateInc;
        m.Debug.RunTimeCheck.TransitionConflicts = settings.transitions;
    end
end