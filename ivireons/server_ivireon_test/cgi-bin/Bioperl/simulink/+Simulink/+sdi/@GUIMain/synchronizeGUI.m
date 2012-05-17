function  synchronizeGUI(this)

    % Copyright 2010 The MathWorks, Inc.
    % this function is meant to be used in testing and not in source code.
    % One can use this function to synchronize an engine with GUI.

    rowList = this.populateTableColumns(this.sortCriterion, ...
                                        this.colNames,      ...
                                        'ASC');  
    this.tableSortandRender(rowList);      
    this.transferStateToScreen_CompareRuns();  
    this.SetEnable();
    this.dirty = true;
end

