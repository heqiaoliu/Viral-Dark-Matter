classdef StringReporter < rptgen.cmpn.VariableReporters.VariableReporter
% StringReporter generates a report for a variable whose value is a
% string.

% Copyright 2010 The MathWorks, Inc.

  
  methods
    
    function moReporter = StringReporter(moOpts, uddReport, varName, ...
        varValue)
    % moReporter = StringReporter(moOpts, uddReport, varName, varValue)
    % creates a reporter for the string variable varName/Value.
      moReporter@rptgen.cmpn.VariableReporters.VariableReporter( ...
        moOpts, uddReport, varName, varValue);
    end
    
    function uddVarReport = makeAutoReport(moReporter)
    % uddVarReport = makeAutoReport(moReporter) generates a paragraph
    % containing the string.    
      uddVarReport = moReporter.makeParaReport();
    end    
    
    function uddVarReport = makeTabularReport(moReporter)
    % uddVarReport = makeTabularReport(moReporter) generates a table
    % that contains the string and the string's data type.
      import rptgen.cmpn.VariableReporters.*;
      uddVarReport = moReporter.uddVarReport;
      caTable = cell(2, 2);
      caTable{1, 1} = msg('StrTblHeadValue');
      caTable{1, 2} = moReporter.getTextValue;
      caTable{2, 1} = msg('StrTblHeadDataType');
      caTable{2, 2} = class(moReporter.VarValue);
      uddVarReport.appendChild(moReporter.makeValueTable(caTable));
    end
    
    
  end % of dynamic methods
  
end

