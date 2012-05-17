function show(this)

    % Copyright 2010 The MathWorks, Inc.

    % Build GUI and position controls
    this.build();

    % Update internal simulation output
    this.updateSimOut();

    % Transfer data to controls
    this.transferDataToScreen();

    % Set enable, visibility, and callbacks
    this.setEnable();
    this.setVisible();
    this.setCallbacks();

    % Set visible flag
    set(this.HDialog, 'visible', 'on');

    % Force processing of draw messages
    drawnow;
end