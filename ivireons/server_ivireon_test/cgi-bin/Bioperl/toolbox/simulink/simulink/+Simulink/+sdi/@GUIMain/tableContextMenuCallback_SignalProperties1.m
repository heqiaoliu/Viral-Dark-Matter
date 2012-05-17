function tableContextMenuCallback_SignalProperties1(this, ~, ~)

%   Copyright 2010 The MathWorks, Inc.

    signalID = javaMethodEDT('getValueAt', this.compareRunsTTModel,...
                             this.rowObjClickedCompRuns, 0);
    data = this.SDIEngine.getSignal(int32(signalID));
    SDIPropDialog = Simulink.sdi.GUISignalProperties(data);