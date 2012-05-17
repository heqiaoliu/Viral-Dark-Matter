function tableContextMenuCallback_SignalProperties(this, ~, ~)

%   Copyright 2010 The MathWorks, Inc.

    signalID = javaMethodEDT('getValueAt', this.rowObjClicked, 20);
    data = this.SDIEngine.getSignal(int32(signalID));
    SDIPropDialog = Simulink.sdi.GUISignalProperties(data);
