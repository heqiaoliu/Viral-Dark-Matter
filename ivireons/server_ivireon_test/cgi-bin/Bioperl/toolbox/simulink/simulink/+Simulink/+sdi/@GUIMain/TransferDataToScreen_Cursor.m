function TransferDataToScreen_Cursor(this)

    % Copyright 2009-2010 The MathWorks, Inc.

    % Cache util class
    UT = Simulink.sdi.Util;

    % Convert dialog state to on/off strings
    IsZoomInX  = strcmp(this.CursorType, 'zoominx');
    IsZoomInY  = strcmp(this.CursorType, 'zoominy');
    IsZoomInXY  = strcmp(this.CursorType, 'zoominxy');
    IsZoomOut = strcmp(this.CursorType, 'zoomout');
    IsZoom    = UT.BoolToOnOff(IsZoomInX || IsZoomOut || IsZoomInY || IsZoomInXY);
    IsPan     = UT.BoolToOnOff(strcmp(this.CursorType, 'pan'));
    isDataCursor = strcmp(this.CursorType, 'datacursor');

    % Default to zoom in
    ZoomInOut = 'in';
    if IsZoomOut
        ZoomInOut = 'out';
    end
    
    % Update zoom
    ZoomObj = zoom(this.HDialog);
    
    % make sure enable off because it won't allow context menu in on state
    set(ZoomObj, 'Enable', 'off');
    
    % empty context menu
    hCMZ = uicontextmenu('parent', this.HDialog);
    
    % set empty context menu
    set(ZoomObj, 'UIContextMenu', hCMZ);
    
    if IsZoomInX
        zoomDir = 'horizontal';        
    elseif IsZoomInY
        zoomDir = 'vertical';
    else
        zoomDir = 'both';            
    end
    
    set(ZoomObj, 'Motion', zoomDir, 'Enable', IsZoom, 'Direction', ZoomInOut);
    
    % Update pan
    pan(this.HDialog, IsPan);
    
    % Update datacursor
    if isDataCursor
        datacursormode(this.HDialog,'on');
    else 
        datacursormode(this.HDialog,'off');
    end       
    
end