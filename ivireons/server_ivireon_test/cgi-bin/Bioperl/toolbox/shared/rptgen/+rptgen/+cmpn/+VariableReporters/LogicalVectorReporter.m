classdef LogicalVectorReporter < rptgen.cmpn.VariableReporters.StringReporter
% LogicalVectorReporter generates a report for a variable whose value is a
% 1D array of logical values.

% Copyright 2010 The MathWorks, Inc.


  
  methods
    
    function moReporter = LogicalVectorReporter(moOpts, uddReport, ...
        varName, varValue)
      moReporter@rptgen.cmpn.VariableReporters.StringReporter(moOpts, ...
        uddReport, varName, varValue);
    end
    
    function joTextValue = getTextValue(moReporter)
      import rptgen.cmpn.VariableReporters.*;
      valueString = '[';
      numElems = length(moReporter.VarValue);
      for i = 1:numElems
        if moReporter.VarValue
          valueString = [valueString msg('LogicalTrue')]; %#ok<AGROW>
        else
         valueString = [valueString msg('LogicalFalse')]; %#ok<AGROW>
        end
        if i < numElems
          valueString = [valueString ' ']; %#ok<AGROW>
        else
          valueString = [valueString ']']; %#ok<AGROW>
        end
      end
      joTextValue = moReporter.uddReport.createTextNode(valueString);
    end
    
  end % of dynamic methods
  
end

