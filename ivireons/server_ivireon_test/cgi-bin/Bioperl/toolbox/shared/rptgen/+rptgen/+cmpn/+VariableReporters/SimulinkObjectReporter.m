classdef SimulinkObjectReporter < rptgen.cmpn.VariableReporters.UDDObjectReporter
% SimulinkObjectReporter generates a report for a variable whose value is a
% Simulink handle.

% Copyright 2010 The MathWorks, Inc.


  
  methods
    
    function moReporter = SimulinkObjectReporter(moOpts, joReport, ...
      varName, slObjHandle)
      import rptgen.cmpn.VariableReporters.*;
      moReporter@rptgen.cmpn.VariableReporters.UDDObjectReporter(moOpts, ...
        joReport, varName, get_param(slObjHandle, 'Object'));
    end
      
  end % of dynamic methods
  
end

