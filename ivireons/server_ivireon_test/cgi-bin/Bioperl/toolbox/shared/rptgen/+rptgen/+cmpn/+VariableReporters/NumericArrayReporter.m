classdef NumericArrayReporter < rptgen.cmpn.VariableReporters.ArrayReporter
% NumericArrayReporter generates a report for a variable whose value is a
% numeric array.
%
% Note: this class currently defers inline text reporting to
% rptgen.toString, which does not do a good job. We should enhance this
% class to generate inline text itself. This would eliminate the need for
% a separate NumericVector class.
%

% Copyright 2010 The MathWorks, Inc.

  
  methods
    
    function moReporter = NumericArrayReporter(moOpts, uddReport, ...
        varName, varValue)
      moReporter@rptgen.cmpn.VariableReporters.ArrayReporter(moOpts, ...
        uddReport, varName,  varValue);
    end
        
    
    function joVarReport = makeArraySliceReport(moReporter)
      if moReporter.canReportAsTable(moReporter.VarValue)
        joVarReport = moReporter.makeValueTable(moReporter.VarValue);
      else
        joVarReport = makeArraySliceParaReport(moReporter);
      end
    end
    
    function joVarReport = makeParaReport(moReporter)
      joVarReport = moReporter.makeArraySliceParaReport();
    end
    
    function joSliceReport = makeArraySliceParaReport(moReporter)
      joSliceReport = moReporter.uddReport.createDocumentFragment();
    
      joTitle = moReporter.makeSliceTitle();
      
      joSliceReport.appendChild(joTitle);
      
      arraySize = size(moReporter.VarValue);      
      for r = 1:arraySize(1);
        title = sprintf('%s(%i,:)', moReporter.ReportTitle, r);
        joTitle = moReporter.uddReport.createElement('title', title);
        rowText = rptgen.toString(moReporter.VarValue(r,:));
        joPara = moReporter.uddReport.createElement('para', rowText);
        joFormalPara = moReporter.uddReport.createElement('formalpara');
        joFormalPara.appendChild(joTitle);
        joFormalPara.appendChild(joPara);
        joSliceReport.appendChild(joFormalPara);
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

