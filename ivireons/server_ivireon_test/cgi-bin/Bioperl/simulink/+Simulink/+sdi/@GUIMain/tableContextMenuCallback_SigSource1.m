function tableContextMenuCallback_SigSource1(this, ~, ~)
    % Copyright 2010 The MathWorks, Inc.

    signalID = javaMethodEDT('getValueAt', this.compareRunsTTModel,...
                             this.rowObjClickedCompRuns, 0);

    try 
        sid = this.SDIEngine.showSourceBlockInModel(signalID);
        
    catch ME
        errordlg(ME.message, this.sd.mgError, 'modal');
        return;        
    end

    % error dialog if sid is empty or model is not open
    if isempty(sid)
        errordlg(this.sd.mgSIDError, this.sd.mgError, 'modal');
    end
    
