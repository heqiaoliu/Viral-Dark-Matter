classdef NumericScalarReporter < rptgen.cmpn.VariableReporters.StringReporter
% NumericScalarReporter generates a report for a variable whose value is a
% numeric scalar.

% Copyright 2010 The MathWorks, Inc.

  
  methods
    
    function moReporter = NumericScalarReporter(moOpts, joReport, ...
      varName, varValue)
      moReporter@rptgen.cmpn.VariableReporters.StringReporter(moOpts, ...
        joReport, varName, varValue);
    end
    
  end % of dynamic methods
  
end

