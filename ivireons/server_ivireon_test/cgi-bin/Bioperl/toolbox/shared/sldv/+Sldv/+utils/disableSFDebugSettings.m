function originalSettings = disableSFDebugSettings(modelH)

%   Copyright 2009 The MathWorks, Inc.

    settings = [];
    modelName = get_param(modelH, 'Name');
    try
        m = find(sfroot, '-isa', 'Stateflow.Machine', 'Name', modelName); %#ok<GTARG>
        if ~isempty(m)
            settings.animation = m.Debug.Animation.Enabled;
            settings.chartE = m.Debug.BreakOn.ChartEntry;
            settings.eventB = m.Debug.BreakOn.EventBroadcast;
            settings.stateE = m.Debug.BreakOn.StateEntry;
            settings.disableAll = m.Debug.DisableAllBreakpoints;
            settings.cycleDetect = m.Debug.RunTimeCheck.CycleDetection;
            settings.dataRange = m.Debug.RunTimeCheck.DataRangeChecks;
            settings.stateInc = m.Debug.RunTimeCheck.StateInconsistencies;
            settings.transitions = m.Debug.RunTimeCheck.TransitionConflicts;

            m.Debug.Animation.Enabled = 0;
            m.Debug.BreakOn.ChartEntry = 0;
            m.Debug.BreakOn.EventBroadcast = 0;
            m.Debug.BreakOn.StateEntry = 0;
            m.Debug.DisableAllBreakpoints = 1;
            m.Debug.RunTimeCheck.CycleDetection = 0;
            m.Debug.RunTimeCheck.DataRangeChecks = 0;
            m.Debug.RunTimeCheck.StateInconsistencies = 0;
            m.Debug.RunTimeCheck.TransitionConflicts = 0;
        end
    catch MEx %#ok<NASGU>
              % settings is empty
    end
    originalSettings = settings;
end

