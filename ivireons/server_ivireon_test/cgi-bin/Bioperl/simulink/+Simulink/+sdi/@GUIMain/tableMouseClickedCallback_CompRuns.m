function tableMouseClickedCallback_CompRuns(this, ~, eventData)
    
    % Copyright 2009-2010 The MathWorks, Inc.
        
    % Get the row and col.
    point = javaMethodEDT('getPoint',  eventData);
    src   = javaMethodEDT('getSource', eventData);
    this.rowObjClickedCompRuns   = javaMethodEDT('rowAtPoint', src, point);
    
    if eventData.getButton() == eventData.BUTTON3 ||...
       (ismac && eventData.getButton() == eventData.BUTTON1 && eventData.isControlDown)
         % Get click X,Y relative to table top, left
        tableClickX = eventData.getX();
        tableClickY = eventData.getY();
                
        % Get table position relative to dialog bottom, left
        tablePos = get(this.compareRunsTT.container, 'Position');
        tableX   = tablePos(1);
        tableY   = tablePos(2);
        tableH   = tablePos(4);
        
        % account for scrolling
        plusScrollY = this.compareRunsTT.ScrollPane.getVerticalScrollBar.getValue;
        plusScrollX = this.compareRunsTT.ScrollPane.getHorizontalScrollBar.getValue;
        
        % Calculate click X,Y relative to dialog bottom, left
        dialogClickX = tableX + tableClickX - plusScrollX;
        dialogClickY = tableY + tableH - tableClickY + plusScrollY;
        
        align = javaMethodEDT('getValueAt', this.compareRunsTTModel,...
                              this.rowObjClickedCompRuns, 1);
        if ~strcmpi(align, 'unaligned')
            set(this.tableContextMenuSigSourceCompRuns2, 'Enable', 'on');
            set(this.tableContextMenuViewDataCompRuns2, 'Enable', 'on');
            set(this.tableContextMenuPropertiesCompRuns2, 'Enable', 'on');
        else
            set(this.tableContextMenuSigSourceCompRuns2, 'Enable', 'off');
            set(this.tableContextMenuViewDataCompRuns2, 'Enable', 'off');
            set(this.tableContextMenuPropertiesCompRuns2, 'Enable', 'off');
        end
        set(this.tableContextMenuCompRuns, 'Position',...
            [dialogClickX, dialogClickY]);
        set(this.tableContextMenuCompRuns, 'vis', 'on');
    end    
end
