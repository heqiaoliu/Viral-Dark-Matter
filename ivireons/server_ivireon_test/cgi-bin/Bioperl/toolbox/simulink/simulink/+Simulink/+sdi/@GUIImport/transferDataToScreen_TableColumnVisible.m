function transferDataToScreen_TableColumnVisible(this)

    % Copyright 2010 The MathWorks, Inc.

    this.setColumnVisibility(0, this.RootSourceVisible);
    this.setColumnVisibility(1, this.TimeSourceVisible);
    this.setColumnVisibility(2, this.DataSourceVisible);
    this.setColumnVisibility(3, this.BlockSourceVisible);
    this.setColumnVisibility(4, this.ModelSourceVisible);
    this.setColumnVisibility(5, this.SignalLabelVisible);
    this.setColumnVisibility(6, this.SignalDimsVisible);
    this.setColumnVisibility(7, this.PortIndexVisible);
end