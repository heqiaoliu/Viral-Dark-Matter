function flag = saveAs(this, varargin)

    % Copyright 2010 The MathWorks, Inc.
    
    % get signal and run count
    sigCount = this.SDIEngine.getSignalCount();
    runCount = this.SDIEngine.getRunCount();
    flag = 0;
    
    % if condition for testing only. This condition won't launch a dialog 
    if ~isempty(varargin)
        
        % No error dialog if there is no data to save
        if (sigCount == 0 || runCount == 0)               
            return;
        end
        
        [pathstr, filename] = fileparts(varargin{1});
        this.pathName = pathstr;
        this.fileName = filename;
        this.helperSave(this.pathName, this.fileName, 'force');
        flag = this.fileName;
    else
        % error dialog if there is no data to save
        if (sigCount == 0 || runCount == 0)  
            msgbox(this.sd.noData, 'error', 'modal');
            return;
        end

        % Cache string dictionary class
        SD = Simulink.sdi.StringDict;

        % Display dialog
        [filename, pathname] = uiputfile({SD.MATFilter, SD.MATDesc}, ...
                                         SD.MATSaveTitle, this.defaultName);
        flag = filename;

        % If no cancel
        if ~isequal(filename, 0) && ~isequal(pathname, 0)
            this.helperSave(pathname, filename);
        end
    end
end