function tableContextMenuCallback_SignalProperties2(this, ~, ~)

%   Copyright 2010 The MathWorks, Inc.

    signalID = javaMethodEDT('getValueAt', this.compareRunsTTModel,...
                              this.rowObjClickedCompRuns, 0);
    
    rhsSignalID = this.SDIEngine.AlignRuns.getAlignedID(signalID);

    if ~isempty(rhsSignalID)
        data = this.SDIEngine.getSignal(int32(rhsSignalID));
        SDIPropDialog = Simulink.sdi.GUISignalProperties(data);
    end