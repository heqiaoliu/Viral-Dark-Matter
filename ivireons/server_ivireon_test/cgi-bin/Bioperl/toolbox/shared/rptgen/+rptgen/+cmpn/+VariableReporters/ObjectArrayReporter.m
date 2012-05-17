classdef ObjectArrayReporter < rptgen.cmpn.VariableReporters.ArrayReporter
% ObjectReporter generates a report for an array of structures, MCOS
% objects, or UDD objects.

% Copyright 2010 The MathWorks, Inc.

  
  methods
    
    function moReporter = ObjectArrayReporter(moOpts, joReport, varName, ...
      varValue)
      moReporter@rptgen.cmpn.VariableReporters.ArrayReporter(moOpts, ...
        joReport, varName, varValue);
    end
         
    
    function joVarReport = makeArraySliceReport(moReporter)
      if moReporter.canReportAsTable(moReporter.VarValue)
        joVarReport = moReporter.makeArrayTable();
      else
        joVarReport = makeArraySliceParaReport(moReporter);
      end
      
    end
    
    function joArrayReport = makeArrayTable(moReporter)
      import rptgen.cmpn.VariableReporters.*;
            
      sz = size(moReporter.VarValue);
      numRows = sz(1);
      numCols = sz(2);
      
      % Initialize cell to hold array description table
      caTable = cell(numRows, numCols);
      
      for r = 1:numRows
        for c = 1:numCols
          cellValue = moReporter.VarValue(r, c);
          suffix = sprintf('(%d,%d)', r, c);
          if isempty(moReporter.ReportTitle)
            cellReportTitleBase = class(cellValue);
          else
            cellReportTitleBase = moReporter.ReportTitle;
          end
          cellReportTitle = [cellReportTitleBase suffix];
          moOpts = moReporter.moOpts;
          moOpts.TitleMode = 'auto';
          moCellReporter = ReporterFactory.makeReporter(moOpts, ...
            moReporter.uddReport, cellReportTitle, cellValue);
          forwardLink = moReporter.makeLink(moCellReporter.ReportId, ...
            cellReportTitle);
          caTable{r, c} = forwardLink;
          moReporter.makeBackLink(moCellReporter, suffix);
          ReporterQueue.getTheQueue().add(moCellReporter);          
          
        end % for c = 1:numCols
      end % for r = 1:nunRows
      
      if ~isempty(caTable)
        joArrayReport = moReporter.makeValueTable(caTable);
      else
        joArrayReport = [];
      end
      
    end
    
    function joVarReport = makeParaReport(moReporter)
      joVarReport = moReporter.makeArraySliceParaReport();
    end
    
    
    function joSliceReport = makeArraySliceParaReport(moReporter)
      import rptgen.cmpn.VariableReporters.*;
      joSliceReport = moReporter.uddReport.createDocumentFragment(); 
      if isempty(moReporter.ReportTitle)
        titleBase = class(moReporter.VarValue);
      else
        joTitle = moReporter.makeSliceTitle();    
        joSliceReport.appendChild(joTitle);
        titleBase = moReporter.ReportTitle;
      end
      
      arraySize = size(moReporter.VarValue);      
      for r = 1:arraySize(1);
        title = sprintf('%s(%i,:)', titleBase, r);
        moOpts = moReporter.moOpts;
        moOpts.TitleMode = 'auto';
        moRowReporter = ReporterFactory.makeReporter(moOpts, ...
            moReporter.uddReport, title, moReporter.VarValue(r,:));
        ReporterQueue.getTheQueue().add(moRowReporter); 
      end
   
    end
    
    function joReportTitle = makeSliceTitle(moReporter)
      arraySize = size(moReporter.VarValue);
      title = sprintf('%s(%i,%i)', moReporter.ReportTitle, arraySize(1), arraySize(2));
      emphasis = moReporter.uddReport.createElement('emphasis');
      emphasis.setAttribute('role', 'bold');
      emphasis.setAttribute('xml:space', 'preserve');   
      emphasis.appendChild(moReporter.uddReport.createTextNode(title));
      joReportTitle = moReporter.uddReport.createElement('para', emphasis);
    end   

    
  end % of dynamic methods
  
end

