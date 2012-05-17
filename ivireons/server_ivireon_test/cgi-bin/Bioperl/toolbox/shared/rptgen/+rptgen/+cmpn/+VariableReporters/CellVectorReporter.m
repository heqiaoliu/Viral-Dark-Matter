classdef CellVectorReporter < rptgen.cmpn.VariableReporters.ObjectVectorReporter
% CellVectorReporter generates a report for a variable whose value is a
% 1D cell array.

% Copyright 2010 The MathWorks, Inc.
  
  
  methods
    
    function moReporter = CellVectorReporter(moOpts, uddReport, ...
        varName, varValue)
      moReporter@rptgen.cmpn.VariableReporters.ObjectVectorReporter(moOpts, ...
        uddReport, varName, varValue);
    end
    
    function element = getVectorElement(moReporter, index)
      element = moReporter.VarValue{index};
    end
    
    function joBracket = getLeftBracket(moReporter)
      joBracket = moReporter.uddReport.createTextNode('{');
    end
    
    function joBracket = getRightBracket(moReporter)
      joBracket = moReporter.uddReport.createTextNode('}');
    end
    
  end % of dynamic methods
  
end

