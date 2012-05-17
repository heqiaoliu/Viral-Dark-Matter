function helperSave(this, pathname, filename, varargin)
    % Copyright 2010 The MathWorks, Inc.
    
    % Form full name of file
    fullFileName = fullfile(pathname, filename);
    
    % Call engine save
    figurePointer = get(this.HDialog, 'Pointer');
    set(this.HDialog, 'Pointer', 'watch');
    drawnow;
    try
        this.SDIEngine.save(fullFileName);
        this.fileName = filename;
        this.pathName = pathname;
        this.dirty = false;
    catch ME
        set(this.HDialog, 'Pointer', figurePointer);
        
        % No error dialog if an extra argument is passed
        if isempty(varargin)
           errordlg(ME.message, this.sd.mgError, 'modal');
        end
        
        this.fileName = [];
        this.pathName = [];
        this.dirty = true;
    end
    set(this.HDialog, 'Pointer', figurePointer);
    drawnow;
end