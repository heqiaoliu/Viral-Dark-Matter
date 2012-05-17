function callback_CompareRuns(this, ~, ~)

%   Copyright 2010 The MathWorks, Inc.
    
    % Cache string dictionary class
    sd = Simulink.sdi.StringDict;
    
    figurePointer = get(this.HDialog, 'Pointer');
    set(this.HDialog, 'Pointer', 'watch');
    drawnow;    
    try
        % Clear the axes
        this.helperClearCompareRunsPlot()
		
		% get the selected run
        runIndex = get(this.lhsRunCombo, 'Value');
		runNames = get(this.lhsRunCombo, 'String');
		runName = runNames{runIndex};
		
        this.selectedCompRunRow = [];

        if (~strcmp(runName, this.sd.mgEmpty))
            lhsRunID = this.runIDByComboIndexMap.getDataByKey(runIndex);
            runIndex = get(this.rhsRunCombo, 'Value');
            rhsRunID = this.runIDByComboIndexMap.getDataByKey(runIndex);

            if (lhsRunID == rhsRunID)
                errordlg(sd.mgCompareError, sd.MGCompareRuns, 'modal');
                rowList = javaObjectEDT('java.util.ArrayList');
                this.compareRunsTTModel.setOriginalRows(rowList);
                this.compareRunsTT.TT.repaint();
                cla(this.AxesCompareRunsData, 'reset');
                title(this.AxesCompareRunsData, this.sd.mgSignals);
                cla(this.AxesCompareRunsDiff, 'reset');
                title(this.AxesCompareRunsDiff, this.sd.mgDifference);
            else
                alignBy = Simulink.sdi.AlignType...
                         (this.alignByPopUp.getSelectedIndex + 1);
                firstThenBy = Simulink.sdi.AlignType...
                             (this.firstThenByPopUp.getSelectedIndex);
                secondThenBy = Simulink.sdi.AlignType...
                              (this.secondThenByPopUp.getSelectedIndex);

                algorithms = alignBy;

                if (firstThenBy ~= Simulink.sdi.AlignType.None)
                    algorithms = [algorithms firstThenBy];
                end

                if (secondThenBy ~= Simulink.sdi.AlignType.None)
                    algorithms = [algorithms secondThenBy];
                end

                % Resolve and error check run IDs
                this.validateRunIDs(lhsRunID, rhsRunID);
                this.SDIEngine.diffRuns(lhsRunID, rhsRunID, algorithms);
                this.lhsRunID = lhsRunID;
                this.rhsRunID = rhsRunID;
                this.transferDataToScreen_CompareRunsTable();
            end
        end
    catch %#ok
        
    end
    
    set(this.HDialog, 'Pointer', figurePointer);
end
