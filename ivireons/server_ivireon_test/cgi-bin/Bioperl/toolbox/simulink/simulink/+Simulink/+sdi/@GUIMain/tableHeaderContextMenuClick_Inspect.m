function tableHeaderContextMenuClick_Inspect(this, h, MouseEvent, treetable) %#ok<INUSL>
    %   Copyright 2010 The MathWorks, Inc.

    if MouseEvent.getButton() == MouseEvent.BUTTON3 ||...
       (ismac && MouseEvent.getButton() == MouseEvent.BUTTON1 && MouseEvent.isControlDown)
        % Get click X,Y relative to table top, left
        TableClickX = MouseEvent.getX();
        TableClickY = MouseEvent.getY();
        
        % Get table position relative to dialog bottom, left
        TablePos = get(treetable.container, 'Position');
        TableX   = TablePos(1);
        TableY   = TablePos(2);
        TableH   = TablePos(4);
        % account for scrolling
        plusScrollX = this.InspectTT.ScrollPane.getHorizontalScrollBar.getValue;
        
        % Calculate click X,Y relative to dialog bottom, left
        DialogClickX = TableX + TableClickX - plusScrollX;
        DialogClickY = TableY + TableH - TableClickY;
        
        % Position context menu
        set(this.tableColumnSelectContextMenu, 'Position', [DialogClickX, DialogClickY]);
        
        % Show context menu
        set(this.tableColumnSelectContextMenu, 'Visible', 'on');
    end % if
end