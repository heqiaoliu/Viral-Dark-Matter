classdef NumericVectorReporter < rptgen.cmpn.VariableReporters.StringReporter
% NumericVector generates a report for a variable whose value is a
% numeric vector.

% Copyright 2010 The MathWorks, Inc.

  
  methods
    
    function moReporter = NumericVectorReporter(moOpts, joReport, ...
        varName, varValue)
      moReporter@rptgen.cmpn.VariableReporters.StringReporter(moOpts, ...
        joReport, varName, varValue);
    end
    
  end % of dynamic methods
  
end

