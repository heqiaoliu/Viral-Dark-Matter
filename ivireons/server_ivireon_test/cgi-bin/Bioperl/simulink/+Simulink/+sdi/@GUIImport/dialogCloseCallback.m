function dialogCloseCallback(this, ~, ~)

    % Dialog close callback
    %
    % Copyright 2010 The MathWorks, Inc.

    if this.Dirty
        % Cache string dictionary class
        SD = Simulink.sdi.StringDict;
        
        % Ask to close
        YesNo = questdlg([SD.Exit ' ' SD.IGTitle '?'], ...
                         [SD.Exit '?'],                ...
                          SD.Yes, SD.No, SD.Yes);
        switch YesNo
            case SD.Yes
                delete(this.HDialog);
                this.NewOrExistRun = 'new';
                this.BaseWSOrMAT = 'basews';
            case SD.No,  return;
        end
        
        % If not dirty, just close it
    else
        delete(this.HDialog);
        this.NewOrExistRun = 'new';
        this.BaseWSOrMAT = 'basews';
    end % if
end