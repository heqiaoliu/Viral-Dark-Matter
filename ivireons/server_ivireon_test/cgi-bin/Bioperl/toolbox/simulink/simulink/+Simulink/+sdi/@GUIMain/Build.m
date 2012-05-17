function Build(this)

    % Copyright 2009-2010 The MathWorks, Inc.

    % If we have a valid dialog then nothing to do
    if ishandle(this.HDialog)
        return;
    end

    % Cache GUI utilities class
    UG = Simulink.sdi.GUIUtil;

    % Cache geometric constants class
    GC = Simulink.sdi.GeoConst;

    % Create controls
    this.createUIControls();

    % Center dialog on screen
    UG.CenterDialogOnScreen(this.HDialog,        ...
                            2*GC.MDefaultDialogHE, ...
                            2*GC.MDefaultDialogVE);

    % Layout controls
    this.PositionControls();

    % Transfer data to controls
    this.TransferDataToScreen();

    % Set enable and visibility
    this.SetEnable();
    this.SetVisible();

    % Enable callbacks
    this.SetCallbacks();
end