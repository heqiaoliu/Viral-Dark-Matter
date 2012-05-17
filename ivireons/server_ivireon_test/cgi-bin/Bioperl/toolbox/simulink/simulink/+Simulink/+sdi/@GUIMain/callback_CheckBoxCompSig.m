function callback_CheckBoxCompSig(this, source, ~)

    % Copyright 2010 The MathWorks, Inc.
    
    % get the signal ID
    id = source.getSelected();
    
    % Get the row and col.
    row = source.getRow();
    col = source.getColumn();

    % find the column location
    colCount = this.compareSignalsTT.TT.getColumnCount;
    colName = cell(1,colCount);

    for i = 1:colCount
        colName{i} = char(this.compareSignalsTT.TT.getColumnName(i-1));
    end

    this.compareSigLeftIndex = strmatch(this.sd.mgLeft,colName);
    this.compareSigRightIndex = strmatch(this.sd.mgRight,colName);

    % update state variables 
    if (~isempty(this.compareSigLeftIndex) &&...
            ~isempty(this.compareSigRightIndex))
        helperUpdateStateVariables(this, row, this.compareSigLeftIndex,...
                                   1, id, col, this.leftInd - 1);
        helperUpdateStateVariables(this, row, this.compareSigRightIndex,...
                                   2, id, col, this.rightInd - 1);
        this.transferStateToScreen_plotUpdateCompareSignals();
    end
end

% helper function to update state variables
function helperUpdateStateVariables(this, row, colIndex, index, signalID,...
                                    col, leftRightIndex)
    onTableChkBoxValueLeft = javaMethodEDT             ...
                             ('getValueAt',            ...
                              this.compareSignalsTT.TT,...
                              row ,                    ...
                              colIndex-1);
    
    % Do something only if check box is marked
    if(onTableChkBoxValueLeft)
        % update state variable
        this.state_SelectedSignalsCompSig(index) = signalID;
        
        if(this.screen_SelectedSignalsCompSig(index) > -1)
            helperRemoveCheckMarks(this, colIndex, leftRightIndex);
        end        
        
        this.screen_SelectedSignalsCompSig(index) = row;
        
        javaMethodEDT('setValueAt', this.compareSignalsTT.TT, true,  ...
                       this.screen_SelectedSignalsCompSig(index),    ...
                       colIndex-1);
        this.compareSignalsTT.TT.repaint();
    else
        if(col == colIndex-1)
            this.state_SelectedSignalsCompSig(index) = int32(-1);
        end
    end
end

% helper function to remove check marks 
% Only one check box per column can be selected in Compare Signals Tab
function helperRemoveCheckMarks(this, index, leftRightIndex)
    
    rowCount = this.compareSignalsTT.TT.getRowCount;
    
    for row = 1:rowCount
        rowObj = javaMethodEDT('getRowAt', this.compareSignalsTT.TT, row-1);
        
        % continue if row is not a leaf
        if (rowObj.hasChildren)
            % number of children
            % i.e., Multidimensional signal
            count = rowObj.getChildrenCount;
            % loop over all the children and remove checkmarks
            for j = 1:count
                currRow = rowObj.getChildAt(j-1);
                javaMethodEDT('setValueAt', currRow, false,  leftRightIndex);
            end   
        end

        % set false for everything else
        javaMethodEDT('setValueAt', this.compareSignalsTT.TT, false, ...
                       row-1, index-1);
    end
    % repaint the table
    this.compareSignalsTT.TT.repaint();
end