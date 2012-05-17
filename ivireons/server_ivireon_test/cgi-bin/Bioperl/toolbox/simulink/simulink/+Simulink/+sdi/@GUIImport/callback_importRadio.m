function callback_importRadio(this, RadioHandle, e)%#ok

    % "Import from" section
    %
    % Copyright 2010 The MathWorks, Inc.

    if RadioHandle == this.ImportFromBaseRadio
        this.BaseWSOrMAT = 'basews';
        
    elseif RadioHandle == this.ImportFromMATRadio
        this.BaseWSOrMAT = 'mat';
    end
    
    % "Import to" section
    if RadioHandle == this.ImportToNewRadio
        this.NewOrExistRun = 'new';
        
    elseif RadioHandle == this.ImportToExistRadio
        this.NewOrExistRun = 'exist';
    end

    % Update enable
    this.setEnable();

    % Update field values
    if (RadioHandle == this.ImportFromBaseRadio || ...
       RadioHandle == this.ImportFromMATRadio)
        this.callback_RefreshButton([], [], 'forced');
        this.transferDataToScreen();
    else
        this.transferDataToScreen_ImportFromImportTo();
    end    

    % Set enable, visibility, and callbacks
    this.setEnable();
    this.setVisible();
    this.setCallbacks();
end