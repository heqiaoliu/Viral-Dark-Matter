function save(this, varargin)

    % Copyright 2010 The MathWorks, Inc.
    % varargin = fullfileName
    % Used for testing purposes. If you pass in full file name of MAT-file,
    % no dialogs will pop up.
    
    % get signal and run count
    sigCount = this.SDIEngine.getSignalCount();
    runCount = this.SDIEngine.getRunCount();
    
    % for testing only. This won't launch a dialog 
    if ~isempty(varargin)
        % No error dialog if there is no data to save
        if (sigCount == 0 || runCount == 0)            
            return;
        end
        
        fullFileName = varargin{1};
        [pathstr, filename] = fileparts(fullFileName);
        this.pathName = pathstr;
        this.fileName = filename;    
        this.helperSave(this.pathName, this.fileName, 'force');
        % early return. No need to go any further
        return;
    end
    
    % error dialog if there is no data to save
    if (sigCount == 0 || runCount == 0)
        msgbox(this.sd.noData, 'error', 'modal');
        return;
    end
    
    % check if you have filename and path name    
    if (isempty(this.pathName) || isempty(this.fileName))
        this.saveAs();        
    else        
        this.helperSave(this.pathName, this.fileName);
    end        
end