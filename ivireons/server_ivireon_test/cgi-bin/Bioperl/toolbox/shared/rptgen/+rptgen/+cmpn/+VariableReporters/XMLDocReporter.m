classdef XMLDocReporter < rptgen.cmpn.VariableReporters.StringReporter
% XMLDocReporter generates a report for a variable whose value is an
% XML DOM object. Note: this class assumes that the DOM object is a valid
% DocBook element that is valid in a para element.

% Copyright 2010 The MathWorks, Inc.

  
  methods
    
    function moReporter = XMLDocReporter(moOpts, joReport, ...
      varName, varValue)
      moReporter@rptgen.cmpn.VariableReporters.StringReporter(moOpts, ...
        joReport, varName, varValue);
    end
    
    function joTextValue = getTextValue(moReporter)
      joTextValue = moReporter.VarValue;
    end
    
  end % of dynamic methods
  
end

