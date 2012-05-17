function tableBodyContextMenuClick(this, h, MouseEvent) %#ok<INUSL>

    % Copyright 2010 The MathWorks, Inc.

    if MouseEvent.getButton() == MouseEvent.BUTTON3
        % Get table clicked
        TableSource = MouseEvent.getSource();
        
        % Get click X,Y relative to table top, left
        TableClickX = MouseEvent.getX();
        TableClickY = MouseEvent.getY();
        
        % Need to calculate what row is clicked
        RowClicked = TableSource.rowAtPoint(java.awt.Point(TableClickX,...
                                                           TableClickY));
        TableSource.setRowSelectionInterval(RowClicked, RowClicked);
        
        % Get table position relative to dialog bottom, left
        TablePos = get(this.ImportVarsTTContainer, 'Position');
        TableX   = TablePos(1);
        TableY   = TablePos(2);
        TableH   = TablePos(4);
        
        % account for scrolling
        plusScrollY = this.ImportVarsTTScrollPane.getVerticalScrollBar.getValue;
        plusScrollX = this.ImportVarsTTScrollPane.getHorizontalScrollBar.getValue;
        
        % Calculate click X,Y relative to dialog bottom, left
        DialogClickX = TableX + TableClickX - plusScrollX;
        DialogClickY = TableY + TableH - TableClickY - ...
                       TableSource.getRowHeight() + plusScrollY;
        
        % Position context menu
        set(this.ContextMenu, 'Position', [DialogClickX, DialogClickY]);
        
        % Show context menu
        set(this.ContextMenu, 'Visible', 'on');
    end % if
end