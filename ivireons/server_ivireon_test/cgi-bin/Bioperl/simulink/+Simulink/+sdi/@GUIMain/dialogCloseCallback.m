function dialogCloseCallback(this,~,~)
    
    % Copyright 2010 The MathWorks, Inc.
    if ~strcmpi(this.guiForceClose, 'force')
        if (this.dirty)
            this.guiForceClose = [];
            runCount = this.SDIEngine.getRunCount();
            sigCount = this.SDIEngine.getSignalCount();
            if (sigCount > 0 && runCount > 0)      
                choice = questdlg(this.sd.mgCloseSDIWarn, ...
                                  this.sd.mgQuit,         ...
                                  this.sd.Yes,this.sd.No, ...
                                  this.sd.Cancel,         ...
                                  this.sd.Cancel);

                switch choice
                    case this.sd.Yes
                        flag = this.saveAs();                
                        if (flag == 0)                    
                            return;
                        end                    
                    case this.sd.No                
                    case this.sd.Cancel
                        return;
                end
            end
        end
    end
    
    this.SDIEngine.stop;
    this.TabType = Simulink.sdi.GUITabType.InspectSignals;
    this.state_SelectedSignalsCompSig = [int32(-1) int32(-1)];   
    this.state_SelectedSignalCompRun = -1;
    this.fileName = [];
    this.pathName = [];
    delete(this.HDialog); 
    this.SDIEngine.clearRuns();
	
	% remove highlighting
	Simulink.ID.hilite('');
    
    % close Import GUI if open
    if ~isempty(this.ImportGUI) && ishandle(this.ImportGUI.HDialog)
        this.ImportGUI.close();
    end       
    
    % remove appdata
    if isappdata(0, 'SDIGUI')
        rmappdata(0, 'SDIGUI');
    end
end