function transferDataToScreen_Table(this)

    % Copyright 2010 The MathWorks, Inc.

    rowList = javaObjectEDT('java.util.ArrayList');
    
    for i = 1:length(this.SimOutExplorer.Outputs)
        % Cache ith row
        IthRow = this.SimOutExplorer.Outputs(i);
        newRow = javaObjectEDT                                  ...
                          ('com.mathworks.toolbox.sdi.sdi.Row', ...
                          this.numCol);   
        
        % Append row to table data        
        newRow.setValueAt(IthRow.RootSource, 0);
        newRow.setValueAt(IthRow.TimeSource, 1);
        newRow.setValueAt(IthRow.DataSource, 2);
        newRow.setValueAt(IthRow.BlockSource, 3);
        newRow.setValueAt(IthRow.ModelSource, 4);
        newRow.setValueAt(IthRow.SignalLabel, 5);
        newRow.setValueAt(num2str(IthRow.SampleDims), 6);
        newRow.setValueAt(num2str(IthRow.PortIndex), 7);
        newRow.setValueAt(true, 8);
        rowList.add(newRow);
    end % for
    
    % set the rows
    this.ImportVarsTTModel.setOriginalRows(rowList);
    this.ImportVarsTT.repaint;
end