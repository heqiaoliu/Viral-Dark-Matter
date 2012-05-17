function tableContextMenuCallback_VarEditor(this, ~, ~)

%   Copyright 2010 The MathWorks, Inc.

    signalID = javaMethodEDT('getValueAt', this.rowObjClicked, 20);
    data = this.SDIEngine.getSignal(int32(signalID));
    assignin('base','dataObj',data.DataValues);
    evalin('base','openvar(''dataObj'')');