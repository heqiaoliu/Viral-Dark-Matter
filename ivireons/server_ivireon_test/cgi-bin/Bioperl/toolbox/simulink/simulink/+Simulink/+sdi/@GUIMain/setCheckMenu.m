function setCheckMenu(this, cursorType, state)
    % Copyright 2010 The MathWorks, Inc.
    UT = Simulink.sdi.Util;
    onOff  = UT.BoolToOnOff(strcmp(state,'on'));
    
    if (strcmp(state,'on'))
        set(this.plotToolsZoomInX,    'Checked','off');
        set(this.plotToolsZoomInY,    'Checked','off');
        set(this.plotToolsZoomInXY,    'Checked','off');
        set(this.plotToolsZoomOut,   'Checked','off');
        set(this.plotToolsPan,       'Checked','off');
        set(this.plotToolsDataCursor,'Checked','off');
    end
    
    switch cursorType
        case 'zoominx'
            set(this.plotToolsZoomInX,    'Checked',onOff);
        case 'zoominy'
            set(this.plotToolsZoomInY,    'Checked',onOff);
        case 'zoominxy'
            set(this.plotToolsZoomInXY,   'Checked',onOff);
        case 'zoomout'
            set(this.plotToolsZoomOut,   'Checked',onOff);
        case 'pan'
            set(this.plotToolsPan,       'Checked',onOff);
        case 'datacursor'
            set(this.plotToolsDataCursor,'Checked',onOff);
    end    
end