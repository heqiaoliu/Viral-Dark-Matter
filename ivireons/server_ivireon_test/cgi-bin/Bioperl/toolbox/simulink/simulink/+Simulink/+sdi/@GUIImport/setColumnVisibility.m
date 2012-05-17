function setColumnVisibility(this, ColumnIndex, ColumnVisible)

    % Column visibility is handled through separate class
    %
    % Copyright 2010 The MathWorks, Inc.

    TCC = javaObjectEDT('com.jidesoft.grid.TableColumnChooser');

    % The table is not robust to hiding and already hidden column.
    % The same holds for showing already visible columns.  We
    % must add this robustness in.
    ActualVisible = TCC.isVisibleColumn(this.ImportVarsTT, ColumnIndex);

    if ColumnVisible && ~ActualVisible
        javaMethodEDT('showColumn', TCC, this.ImportVarsTT, ColumnIndex, -1);
    elseif ~ColumnVisible && ActualVisible
        javaMethodEDT('hideColumn', TCC, this.ImportVarsTT, ColumnIndex);
    end
end