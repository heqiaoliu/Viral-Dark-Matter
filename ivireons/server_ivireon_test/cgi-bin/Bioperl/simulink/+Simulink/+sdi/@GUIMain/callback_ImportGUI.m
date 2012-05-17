function callback_ImportGUI(this, ~, ~)

    % Copyright 2010 The MathWorks, Inc.

    % Resolve import GUI - re-use if we already have one
    if isempty(this.ImportGUI)
        this.ImportGUI = Simulink.sdi.GUIImport(this.SDIEngine);
    end

    % Show import GUI
    this.ImportGUI.show();
end