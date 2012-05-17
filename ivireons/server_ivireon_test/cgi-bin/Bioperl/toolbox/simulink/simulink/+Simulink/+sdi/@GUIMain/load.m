function load(this)

    % Copyright 2010 The MathWorks, Inc.

    % Cache string dictionary class
    SD = Simulink.sdi.StringDict;

    % Display dialog
    [filename, pathname] = uigetfile({SD.MATFilter, SD.MATDesc}, ...
                                     SD.MATLoadTitle);

    % If no cancel
    if ~isequal(filename, 0) && ~isequal(pathname, 0)

        % Form full name of file
        fullFileName = fullfile(pathname, filename);
        runCount = this.SDIEngine.getRunCount();
        
        if (runCount > 0)
            options.Default = this.sd.Cancel;
            options.Interpreter = 'tex';
            choice1 = questdlg(this.sd.mgAppendOrClear, ' ', this.sd.mgAppend,...
                               this.sd.mgClear,this.sd.Cancel, options);

            switch choice1
                case this.sd.mgAppend               
                case this.sd.mgClear  
                    this.SDIEngine.clearRuns();
                    this.clearGUI();                    
                case this.sd.Cancel
                    return;
                otherwise
                    return;
            end        
        end

        % Call engine load
        figurePointer = get(this.HDialog, 'Pointer');        
        set(this.HDialog, 'Pointer', 'watch');
        isValidMATFile = this.SDIEngine.load(fullFileName);        
        set(this.HDialog, 'Pointer', figurePointer);
        
        if ~isValidMATFile
            choice = questdlg(this.sd.mgMATError,     ...
                              this.sd.mgError,        ...
                              this.sd.Yes,this.sd.No, ...
                              this.sd.Yes);
            switch choice
                case this.sd.Yes
                    % launch Import GUI
                    this.callback_ImportGUI([], []);
                    
                    % Select the given file
                    this.ImportGUI.helperSelectMATFile(fullFileName);                    
            end
        else
            this.fileName = filename;
            this.pathName = pathname;
            % assign dirty flag
            if runCount == 0 || (runCount > 0 && strcmp(choice1, this.sd.mgClear))
                this.dirty = false;
            end
        end
    end
end
