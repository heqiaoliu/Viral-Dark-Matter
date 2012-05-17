function build(this)

    % Create and position controls - nothing else
    %
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
    this.createControls();

    % Center dialog on screen
    UG.CenterDialogOnScreen(this.HDialog,         ...
                            GC.IGDefaultDialogHE, ...
                            GC.IGDefaultDialogVE);

    % Position controls
    this.positionControls();
end