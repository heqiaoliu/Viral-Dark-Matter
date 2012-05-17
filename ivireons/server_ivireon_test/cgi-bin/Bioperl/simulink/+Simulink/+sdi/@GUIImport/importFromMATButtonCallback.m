function importFromMATButtonCallback(this, h, e) %#ok<INUSD>

    % Copyright 2010 The MathWorks, Inc.

    % Cache string dictionary class
    SD = Simulink.sdi.StringDict;
    
    % Open load dialog
    DialogFilter = {SD.MATFilter, SD.MATDesc; ...
                    SD.TXTFilter, SD.TXTDesc};
    [LoadFileName, LoadPathName] = uigetfile(DialogFilter, SD.MATLoadTitle);
    
    % Make sure user didn't cancel
    if ~isequal(LoadFileName, 0)
        % Construct full path name
        this.MATFileName = fullfile(LoadPathName, LoadFileName);
        
        set(this.ImportFromMATEdit, 'String', this.MATFileName);
    end;
end