classdef LogicalScalarReporter < rptgen.cmpn.VariableReporters.StringReporter
% LogicalScalarReporter generates a report for a variable whose value is a
% logical scalar.

% Copyright 2010 The MathWorks, Inc.

  
  methods
    
    function moReporter = LogicalScalarReporter(moOpts, uddReport, ...
      varName, varValue)
      moReporter@rptgen.cmpn.VariableReporters.StringReporter(moOpts, ...
        uddReport, varName, varValue);
    end
    
    function joTextValue = getTextValue(moReporter)
      import rptgen.cmpn.VariableReporters.*;
      if moReporter.VarValue
        valueString = msg('LogicalTrue');
      else
        valueString = msg('LogicalFalse');
      end
      joTextValue = moReporter.uddReport.createTextNode(valueString);
    end
    
  end % of dynamic methods
  
end

