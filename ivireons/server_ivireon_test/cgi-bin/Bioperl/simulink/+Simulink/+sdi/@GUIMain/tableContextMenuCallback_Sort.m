function tableContextMenuCallback_Sort(this, ~, ~, sort)

    % Copyright 2010 The MathWorks, Inc.
    
    set(this.tableContextMenuSortByRun, 'Checked', 'off');
    set(this.tableContextMenuSortByBlock, 'Checked', 'off');
    set(this.tableContextMenuSortByData, 'Checked', 'off');
    set(this.tableContextMenuSortByModel, 'Checked', 'off');
    set(this.tableContextMenuSortBySignalName, 'Checked', 'off');
    set(this.contextMenuSortByRun, 'Checked', 'off');
    set(this.contextMenuSortByBlock, 'Checked', 'off');
    set(this.contextMenuSortByData, 'Checked', 'off');
    set(this.contextMenuSortByModel, 'Checked', 'off');
    set(this.contextMenuSortBySignalName, 'Checked', 'off');
    set(this.contextMenuSortByRunCompSig, 'Checked', 'off');
    set(this.contextMenuSortByBlockCompSig, 'Checked', 'off');
    set(this.contextMenuSortByDataCompSig, 'Checked', 'off');
    set(this.contextMenuSortByModelCompSig, 'Checked', 'off');
    set(this.contextMenuSortBySignalNameCompSig, 'Checked', 'off');
    
    
    switch sort
        case 'GRUNNAME'            
            this.sortCriterion = 'GRUNNAME';   
            set(this.tableContextMenuSortByRun, 'Checked', 'on');
            set(this.contextMenuSortByRunCompSig, 'Checked', 'on');
            set(this.contextMenuSortByRun, 'Checked', 'on');
        case 'GBLOCKPATH'
            this.sortCriterion = 'GBLOCKPATH';
            set(this.tableContextMenuSortByBlock, 'Checked', 'on');
            set(this.contextMenuSortByBlockCompSig, 'Checked', 'on');
            set(this.contextMenuSortByBlock, 'Checked', 'on');
        case 'GDATASOURCE'
            this.sortCriterion = 'GDATASOURCE';
            set(this.tableContextMenuSortByData, 'Checked', 'on');
            set(this.contextMenuSortByDataCompSig, 'Checked', 'on'); 
            set(this.contextMenuSortByData, 'Checked', 'on');
        case 'GMODEL'
            this.sortCriterion = 'GMODEL';
            set(this.tableContextMenuSortByModel, 'Checked', 'on');
            set(this.contextMenuSortByModelCompSig, 'Checked', 'on');
            set(this.contextMenuSortByModel, 'Checked', 'on');
        case 'GSIGNALNAME'
            this.sortCriterion = 'GSIGNALNAME';
            set(this.tableContextMenuSortBySignalName, 'Checked', 'on');
            set(this.contextMenuSortBySignalNameCompSig, 'Checked', 'on');
            set(this.contextMenuSortBySignalName, 'Checked', 'on');
        otherwise
            return;
    end % switch

    rowList = this.populateTableColumns(this.sortCriterion,...
                                        this.colNames,     ...
                                        'ASC');
    this.tableSortandRender(rowList);
end
    



    
    
    
    
    