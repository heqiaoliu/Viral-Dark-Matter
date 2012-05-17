classdef ObjectVectorReporter < ...
    rptgen.cmpn.VariableReporters.VariableReporter 
% ObjectVectorReporter generates a report for a variable whose value is a
% vector of structure-like objects, e.g., MATLAB struct, MCOS, and UDD
% objects.

% Copyright 2010 The MathWorks, Inc.
  
  methods
    
    function moReporter = ObjectVectorReporter(moOpts, uddReport, ...
        varName, varValue)
      moReporter@rptgen.cmpn.VariableReporters.VariableReporter(moOpts, ...
        uddReport, varName, varValue);
    end
    
    function uddVarReport = makeReportBodyText(moReporter)
      if strcmp(moReporter.moOpts.DisplayTable, 'text')
        uddVarReport = moReporter.makeInlineReportBodyText();
      else
        uddVarReport = moReporter.makeParaReportBodyText();
      end
    end
    
    function uddVarReport = makeInlineReportBodyText(moReporter)
      import rptgen.cmpn.VariableReporters.*;
      uddVarReport = moReporter.uddReport.createDocumentFragment();      
      uddVarReport.appendChild(moReporter.getLeftBracket());      
      numElems = length(moReporter.VarValue);
      for iElem = 1:numElems
        elemValue = moReporter.getVectorElement(iElem);
        elemString = rptgen.toString(elemValue);
        if iElem ~= numElems
          elemString = [elemString ' ']';
        end
        uddVarReport.appendChild(moReporter.uddReport.createTextNode(elemString));        
      end
      uddVarReport.appendChild(moReporter.getRightBracket());
    end
    
    function uddVarReport = makeParaReportBodyText(moReporter)
      import rptgen.cmpn.VariableReporters.*;
      
      uddVarReport = moReporter.uddReport.createDocumentFragment();
      
      uddVarReport.appendChild(moReporter.getLeftBracket());
            
      numElems = length(moReporter.VarValue);
      for iElem = 1:numElems
        elemValue = moReporter.getVectorElement(iElem);
        elemReportTitleSuffix = sprintf('(%d)', iElem); 
        if isempty(moReporter.ReportTitle)
          elemReportTitleBase = class(moReporter.VarValue);
        else
          elemReportTitleBase = moReporter.ReportTitle;
        end
        elemReportTitle = [elemReportTitleBase elemReportTitleSuffix];        
        linkResolver = ReportLinkResolver.getTheResolver();
        forwardLink = linkResolver.getLink(elemValue);
        if isempty(forwardLink)
          moOpts = moReporter.moOpts;
          moOpts.TitleMode = 'auto';
          moElemReporter = ReporterFactory.makeReporter(moOpts, ...
            moReporter.uddReport, elemReportTitle, elemValue);
          if isa(moElemReporter, ...
              'rptgen.cmpn.VariableReporters.HierarchicalObjectReporter') && ...
              moReporter.ReportLevel < moReporter.moOpts.DepthLimit
            forwardLink = moReporter.makeLink(moElemReporter.ReportId, ...
              elemReportTitle);
            forwardLink = moReporter.uddReport.createElement('phrase', forwardLink);
            uddVarReport.appendChild(forwardLink);
            moReporter.makeBackLink(moElemReporter, elemReportTitleSuffix);
            moElemReporter.ReportLevel = moElemReporter.ReportLevel + 1;
            ReporterQueue.getTheQueue().add(moElemReporter);
          else
            moElemReporter.moOpts.TitleMode = 'none';
            uddVarReport.appendChild(moElemReporter.makeTextReport());
          end
        else
          uddVarReport.appendChild(forwardLink);
        end
        if iElem < numElems
          uddVarReport.appendChild(moReporter.uddReport.createTextNode(', '));
        end        
        
      end % for iCell - 1:numCells
      
      uddVarReport.appendChild(moReporter.getRightBracket());
      
      
    end % makeTextReport
    
    
    function uddVarReport = makeAutoReport(moReporter)
      uddVarReport = moReporter.makeParaReport();
    end
    
    function uddVarReport = makeTabularReport(moReporter)
      import rptgen.cmpn.VariableReporters.*;
      uddVarReport = moReporter.uddVarReport;
      caTable = cell(2, 2);
      caTable{1, 1} = msg('StrTblHeadValue');
      caTable{1, 2} = moReporter.makeReportBodyText();
      caTable{2, 1} = msg('StrTblHeadDataType');
      caTable{2, 2} = class(moReporter.VarValue);
      uddVarReport.appendChild(moReporter.makeValueTable(caTable));
    end % makeTabularReport
    
    function element = getVectorElement(moReporter, index)
      element = moReporter.VarValue(index);
    end
    
    function joBracket = getLeftBracket(moReporter)
      joBracket = moReporter.uddReport.createTextNode('[');
    end
    
    function joBracket = getRightBracket(moReporter)
      joBracket = moReporter.uddReport.createTextNode(']');
    end
    
  end % of dynamic methods
  
end

