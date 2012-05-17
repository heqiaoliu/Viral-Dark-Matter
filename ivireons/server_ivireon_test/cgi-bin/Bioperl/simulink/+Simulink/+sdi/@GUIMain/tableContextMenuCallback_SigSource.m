function tableContextMenuCallback_SigSource(this, ~, ~)
    % Copyright 2010 The MathWorks, Inc.

    signalID = javaMethodEDT('getValueAt', this.rowObjClicked, 20);
    
    try
        sid = this.SDIEngine.showSourceBlockInModel(signalID);
    catch ME
        errordlg(ME.message, this.sd.mgError, 'modal');
        return;        
    end
    
    if isempty(sid)
        errordlg(this.sd.mgSIDError, this.sd.mgError, 'modal');
    end
end