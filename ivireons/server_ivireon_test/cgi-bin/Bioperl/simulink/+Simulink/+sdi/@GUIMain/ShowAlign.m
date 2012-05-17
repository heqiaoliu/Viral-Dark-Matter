function ShowAlign(this, LHSDataRunID, RHSDataRunID)

    % Copyright 2009-2010 The MathWorks, Inc.

    % Create GUI
    ARG = Simulink.sdi.AlignRunsGUI(this.SDIEngine, LHSDataRunID, LHSDataRunID);

    % Show GUI
    ARG.Show;
end