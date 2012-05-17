classdef LogicalArrayReporter < rptgen.cmpn.VariableReporters.ArrayReporter
% LogicalArrayReporter generates a report for a variable whose value is an
% array of logical (true/false) values.

% Copyright 2010 The MathWorks, Inc.

  
  methods
    
    function moReporter = LogicalArrayReporter(moOpts, uddReport, ...
        varName, varValue)
      moReporter@rptgen.cmpn.VariableReporters.ArrayReporter(moOpts, ...
        uddReport, varName,  varValue);
    end
        
    
    function joVarReport = makeArraySliceReport(moReporter)
      import rptgen.cmpn.VariableReporters.*;
      if moReporter.canReportAsTable(moReporter.VarValue)
        sz = size(moReporter.VarValue);
        nRows = sz(1);
        nCols = sz(2);
        caTable = cell(nRows, nCols);
        for r = 1:nRows
          for c = 1:nCols
            if moReporter.VarValue(r,c)
              cellValue = msg('LogicalTrue');
            else
              cellValue = msg('LogicalFalse');
            end
            caTable{r, c} = cellValue;
          end
        end
        joVarReport = moReporter.makeValueTable(caTable);
      else
        joVarReport = makeArraySliceParaReport(moReporter);
      end
    end
    
    function uddBodyText = makeReportBodyText(moReporter)
      if length(size(moReporter.VarValue)) > 2
        uddBodyText = moReporter.makeArrayBodyText();
      else
        uddBodyText = moReporter.makeMatrixBodyText();
      end
    end
    
    function uddBodyText = makeMatrixBodyText(moReporter)
      import rptgen.cmpn.VariableReporters.*;
      bodyText = '[';
      sz = size(moReporter.VarValue);
      nRows = sz(1);
      nCols = sz(2);
      for r = 1:nRows
        for c = 1:nCols
          if moReporter.VarValue(r,c)
            bodyText = [bodyText msg('LogicalTrue')]; %#ok<AGROW>
          else
            bodyText = [bodyText msg('LogicalFalse')]; %#ok<AGROW>
          end
          if c < nCols
            bodyText = [bodyText ' '];  %#ok<AGROW>
          end
        end
        if r < nRows
          bodyText = [bodyText ';']; %#ok<AGROW>
        end
      end
      bodyText = [bodyText ']'];
      uddBodyText = moReporter.uddReport.createDocumentFragment();
      uddBodyText.appendChild(moReporter.uddReport.createTextNode(bodyText));

    end
    
    function uddBodyText = makeArrayBodyText(moReporter)
      uddBodyText = moReporter.uddReport.createDocumentFragment();
      % Render output as "AxBxCx"
      sizeString = sprintf('%ix', size(moReporter.VarValue));
      % Remove trailing x
      sizeString(end) = ' ';
      bodyText = sprintf('<%s%s>', sizeString, 'logical');
      uddBodyText.appendChild(moReporter.uddReport.createTextNode(bodyText));
    end
    
    function uddVarReport = makeParaReport(moReporter)
      uddVarReport = moReporter.makeArraySliceParaReport();
    end
    
    function joSliceReport = makeArraySliceParaReport(moReporter)
      import rptgen.cmpn.VariableReporters.*;
      joSliceReport = moReporter.uddReport.createDocumentFragment();
      if isempty(moReporter.ReportTitle)
          titleBase = 'logical';
      else
        joTitle = moReporter.makeSliceTitle();     
        joSliceReport.appendChild(joTitle);
        titleBase = moReporter.ReportTitle;
      end     
      arraySize = size(moReporter.VarValue);   
      nRows = arraySize(1);
      nCols = arraySize(2);
      for r = 1:nRows;
        title = sprintf('%s(%i,:)', titleBase, r);
        joTitle = moReporter.uddReport.createElement('title', title);
        rowText = '[';
        for c = 1:nCols
          if moReporter.VarValue(r, c)
            rowText = [rowText msg('LogicalTrue')]; %#ok<AGROW>
          else
            rowText = [rowText msg('LogicalFalse')]; %#ok<AGROW>
          end
          if c < nCols
            rowText = [rowText ' ']; %#ok<AGROW>
          else
            rowText = [rowText ']']; %#ok<AGROW>
          end
        end
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

