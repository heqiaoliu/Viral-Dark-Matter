classdef CellArrayReporter < ...
    rptgen.cmpn.VariableReporters.ArrayReporter & ...
    rptgen.cmpn.VariableReporters.HierarchicalObjectReporter
% CellArrayReporter generates a report for a variable whose value is a
% cell array. The reporter generates a tabular report if the array's
% 2D slices meet the size limit specified by the associated DDG 
% dialog. Otherwise, it generates each row of each 2D slice as a
% paragraph.

% Copyright 2010 The MathWorks, Inc.

  
  methods
    
    function moReporter = CellArrayReporter(moOpts, uddReport, varName, ...
      varValue)
    % moReporter = CellArrayReporter(moOpts, uddReport, varName, varValue)
    % makes a reporter for the cell array, varName/Value.
      moReporter@rptgen.cmpn.VariableReporters.ArrayReporter(moOpts, ...
        uddReport, varName, varValue);
    end
      
    function joVarReport = makeArraySliceReport(moReporter)
    % joVarReport = makeArraySliceReport(moReporter) generates a tabular
    % report for the 2D array slice owned by this report if the array
    % slice meets the size limit specified by the reporter's associated
    % DDG dialog. Otherwise, this method generates a paragraph listing
    % the elements of each row of the array.
      if moReporter.canReportAsTable(moReporter.VarValue)
        joVarReport = moReporter.makeArrayTable();
      else
        joVarReport = makeArraySliceParaReport(moReporter);
      end
      
    end
    
    function joCellEntry = makeCellEntry(moReporter, r, c)
      import rptgen.cmpn.VariableReporters.*;
      saveTitleMode = moReporter.moOpts.TitleMode;
      cellValue = moReporter.VarValue{r, c};
      if isempty(cellValue)
        joCellEntry = moReporter.uddReport.createTextNode('');
      else
        cellReportTitleSuffix = sprintf('(%d,%d)', r, c);
        if isempty(moReporter.ReportTitle)
          cellReportTitleRoot = class(moReporter.VarValue);
        else
          cellReportTitleRoot = moReporter.ReportTitle;
        end
        cellReportTitle = [cellReportTitleRoot cellReportTitleSuffix];        
        moReporter.moOpts.TitleMode = 'auto';
        moCellReporter = ReporterFactory.makeReporter(moReporter.moOpts, ...
          moReporter.uddReport, cellReportTitle, cellValue);
        if isa(moCellReporter, ...
              'rptgen.cmpn.VariableReporters.HierarchicalObjectReporter') && ...
            moReporter.ReportLevel < moReporter.moOpts.DepthLimit
          forwardLink = moReporter.makeLink(moCellReporter.ReportId, ...
            cellReportTitle);
          joCellEntry = forwardLink;
          moReporter.makeBackLink(moCellReporter, cellReportTitleSuffix);
          moCellReporter.ReportLevel = moCellReporter.ReportLevel + 1;
          ReporterQueue.getTheQueue().add(moCellReporter);
        else
          moCellReporter.moOpts.TitleMode = 'none';
          joCellEntry = moCellReporter.makeTextReport();
        end
      end
      moReporter.moOpts.TitleMode = saveTitleMode;
    end
    
    function joArrayReport = makeArrayTable(moReporter)
    % joArrayReport = makeArrayTable(moReporter) generates a table 
    % listing the values of the 2D array slice owned by this reporter.
    % If a value is itself a hierarchical object, e.g., another cell 
    % array or an MCOS object, this method creates a reporter for that
    % object and inserts a link to the object's report in the corresponding
    % cell of the report table.
            
      sz = size(moReporter.VarValue);
      numRows = sz(1);
      numCols = sz(2);
      
      % Initialize cell to hold array description table
      caTable = cell(numRows, numCols);
      
      for r = 1:numRows
        for c = 1:numCols
          caTable{r, c} = moReporter.makeCellEntry(r, c);
        end % for c = 1:numCols
      end % for r = 1:nunRows
      
      if ~isempty(caTable)
        joArrayReport = moReporter.makeValueTable(caTable);
      else
        joArrayReport = [];
      end
      
    end
    
    
    function joVarReport = makeParaReport(moReporter)
    % joVarReport = makeParaReport(moReporter) reports the owned array
    % as a sequence of paragraphs, each of which reports on a row
    % of the cell array. Any hierarchical elements of the array are
    % replaced by a link to a report that describes the hierarchical
    % element.
      joVarReport = moReporter.makeArraySliceParaReport();
    end
    
    
    function uddSliceReport = makeArraySliceParaReport(moReporter)
    % joSliceReport = makeArraySliceParaReport(moReporter) reports the owned array
    % slice as a sequence of paragraphs, each of which reports on a row
    % of the cell array. Any hierarchical elements of the array are
    % replaced by a link to a report that describes the hierarchical
    % element.
      import rptgen.cmpn.VariableReporters.*;
      uddSliceReport = moReporter.uddReport.createDocumentFragment();    
       
      if isempty(moReporter.ReportTitle)
        rowTitleBase = 'cell';
      else
        joTitle = moReporter.makeSliceTitle(); 
        if ~isempty(joTitle)
          uddSliceReport.appendChild(joTitle);
        end
        rowTitleBase = moReporter.ReportTitle;
      end
      moReporter.moOpts.TitleMode = 'auto';  
      arraySize = size(moReporter.VarValue);      
      for r = 1:arraySize(1);
        title = sprintf('%s(%i,:)', rowTitleBase, r);
        moOpts = moReporter.moOpts;
        moOpts.TitleMode = 'auto';
        moRowReporter = CellVectorReporter(moOpts, moReporter.uddReport, ...
          title, moReporter.VarValue(r,:));
        uddRowReport = moRowReporter.makeParaReport();
        uddSliceReport.appendChild(uddRowReport);
      end   
    end
    
    function joReportTitle = makeSliceTitle(moReporter)
    % joReportTitle = makeSliceTitle(moReporter) generates a title for
    % a paragraph-type report.
      joTitleText = moReporter.makeTitleText();
      joReportTitle = moReporter.uddReport.createElement('para', joTitleText);
    end   

    
  end % of dynamic methods
  
end

