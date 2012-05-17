function new(this, varargin)
    % Copyright 2010 The MathWorks, Inc.
    
    % varargin is available for testing.
    % You can pass Simulink.sdi.SaveOptions instances to clear the data.
    % See the switch case statements below for more details. From the
    % source code, this function never gets called with varargin. Note that
    % the dialog will not be called when calling with varargin.
    
    % find run count
    runCount = this.SDIEngine.getRunCount();
    
    % don't do anything if run count is zero
    if (runCount == 0)                
        return;
    end
    
    % if it's not dirty you don't need to ask so many questions
    if (this.dirty)
                      
        if ~isempty(varargin)
            choice = varargin{1};
        else
            choice = questdlg(this.sd.mgClearRunsWarn,...
                          this.sd.ClearAll,       ...
                          this.sd.Yes,this.sd.No, ...
                          this.sd.cancel, this.sd.cancel);        
        end
        % Handle response
        switch choice
            case {this.sd.Yes, Simulink.sdi.SaveOptions.clearSave}
                flag = this.saveAs();
                if (flag ~= 0)
                    this.SDIEngine.clearRuns();
                    this.clearGUI();
                    this.fileName = [];
                    this.pathName = [];
                    this.dirty = false;
                end
            case {this.sd.No, Simulink.sdi.SaveOptions.clearWithOutSave}
                this.SDIEngine.clearRuns();
                this.clearGUI();
                this.fileName = [];
                this.pathName = [];
                this.dirty = false;
            case {this.sd.cancel, Simulink.sdi.SaveOptions.doNothing}
        end
    else
        this.SDIEngine.clearRuns();
        this.clearGUI();
        this.fileName = [];
        this.pathName = [];
        this.dirty = false;
    end
end