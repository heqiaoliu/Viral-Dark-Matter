function tableMouseClickedCallback_CompareSignals(this, ~, eventData)

    % Copyright 2009-2010 The MathWorks, Inc.
        
            
    % Get the row and col.
    point = javaMethodEDT('getPoint',  eventData);
    % col   = javaMethodEDT('columnAtPoint',  this.compareSignalsTT.TT, point);
    src   = javaMethodEDT('getSource', eventData);
    row   = javaMethodEDT('rowAtPoint', src, point);
    
    this.rowObjClicked = javaMethodEDT('getRowAt', this.compareSignalsTT.TT, row);
    
    if eventData.getButton() == eventData.BUTTON3 ||...
       (ismac && eventData.getButton() == eventData.BUTTON1 && eventData.isControlDown)
        % Get click X,Y relative to table top, left
        tableClickX = eventData.getX();
        tableClickY = eventData.getY();
        
        % Get table position relative to dialog bottom, left
        tablePos = get(this.compareSignalsTT.container, 'Position');
        tableX   = tablePos(1);
        tableY   = tablePos(2);
        tableH   = tablePos(4);
        
        % account for scrolling
        plusScrollY = this.compareSignalsTT.ScrollPane.getVerticalScrollBar.getValue;
        plusScrollX = this.compareSignalsTT.ScrollPane.getHorizontalScrollBar.getValue;
        
        % Calculate click X,Y relative to dialog bottom, left
        dialogClickX = tableX + tableClickX - plusScrollX;
        dialogClickY = tableY + tableH - tableClickY + plusScrollY;
        
        % Position context menu
        set(this.tableContextMenu, 'Position', [dialogClickX, dialogClickY]);
        set(this.tableContextMenu, 'vis', 'on');
        selectedRows = this.compareSignalsTT.TT.getSelectedRows();
        
        index = find(selectedRows == row, 1);
        
        if isempty(index)
            this.compareSignalsTT.TT.setSelectedRow(this.rowObjClicked);
        end
        
        if ~(this.rowObjClicked.hasChildren)
            % Position context menu
            set(this.tableContextMenuSigSource, 'Enable', 'on');
            set(this.tableContextMenuViewData, 'Enable', 'on');
            set(this.tableContextMenuProperties, 'Enable', 'on');
            return;
        else
            set(this.tableContextMenuSigSource, 'Enable', 'off');
            set(this.tableContextMenuViewData, 'Enable', 'off');
            set(this.tableContextMenuProperties, 'Enable', 'off');
            return;            
        end        
    end