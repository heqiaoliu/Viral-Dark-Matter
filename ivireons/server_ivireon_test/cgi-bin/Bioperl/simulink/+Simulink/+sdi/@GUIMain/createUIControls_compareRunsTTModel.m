function createUIControls_compareRunsTTModel(this)

%   Copyright 2010 The MathWorks, Inc.

    sd = this.sd;
    this.colNamesCompRun = {sd.mgID, sd.mgTest,           ... 
                            sd.mgBlkSrc1, sd.mgBlkSrc2,   ...
                            sd.mgDataSrc1, sd.mgDataSrc2, ...
                            sd.mgSID1, sd.mgSID2,         ...
                            sd.mgAbsTol1, sd.mgRelTol1,   ...
                            sd.mgSync1, sd.mgInterp1,     ...
                            sd.mgChannel1, sd.mgAlignedBy,...
                            sd.MGInspectColNamePlot};   
                         
    numCol = length(this.colNamesCompRun);
    %     rowList = this.populateCompareRunsTable(numCol);
    rowList = javaObjectEDT('java.util.ArrayList');
    
    colNameArrayListCompRun = javaObjectEDT('java.util.ArrayList');
    
    for i = 1 : numCol
        strName = java.lang.String(this.colNamesCompRun{i});
        colNameArrayListCompRun.add(strName);
    end
                                    
    this.compareRunsTTModel = javaObjectEDT(...
                             'com.mathworks.toolbox.sdi.sdi.STreeTableModel', ...  
                             rowList, colNameArrayListCompRun, numCol, 2);
    
end
