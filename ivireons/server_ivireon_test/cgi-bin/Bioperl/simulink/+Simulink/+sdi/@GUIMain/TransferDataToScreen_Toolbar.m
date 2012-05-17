function TransferDataToScreen_Toolbar(this)

    % Copyright 2009-2010 The MathWorks, Inc.

    % Cache util class
    UT = Simulink.sdi.Util;

    % Convert dialog state to on/off strings
    IsSelect  = UT.BoolToOnOff(strcmp(this.CursorType, 'select'));
    IsZoomInX  = UT.BoolToOnOff(strcmp(this.CursorType, 'zoominx'));
    IsZoomInY  = UT.BoolToOnOff(strcmp(this.CursorType, 'zoominy'));
    IsZoomInXY  = UT.BoolToOnOff(strcmp(this.CursorType, 'zoominxy'));
    IsZoomOut = UT.BoolToOnOff(strcmp(this.CursorType, 'zoomout'));
    IsPan     = UT.BoolToOnOff(strcmp(this.CursorType, 'pan'));
    isDataCursor = UT.BoolToOnOff(strcmp(this.CursorType, 'datacursor'));
    IsRecord  = UT.BoolToOnOff(this.SDIEngine.isRecording());

    % Set state of cursor toolbar buttons
    set(this.ToolbarButtonZoomInX,       'State', IsZoomInX);
    set(this.ToolbarButtonZoomInY,       'State', IsZoomInY);
    set(this.ToolbarButtonZoomInXY,       'State', IsZoomInXY);
    set(this.ToolbarButtonZoomOut,      'State', IsZoomOut);
    set(this.ToolbarButtonPan,          'State', IsPan);
    set(this.ToolbarButtonDataCursor,   'State', isDataCursor);
    set(this.ToolbarButtonRecord,       'State', IsRecord);