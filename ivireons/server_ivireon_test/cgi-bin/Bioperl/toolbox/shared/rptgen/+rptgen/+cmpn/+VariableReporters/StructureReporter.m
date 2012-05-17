classdef StructureReporter < rptgen.cmpn.VariableReporters.StructuredObjectReporter
% StructureReporter generates a report for a variable whose value is a
% MATLAB struct object.

% Copyright 2010 The MathWorks, Inc.

  
  methods
    
    function moReporter = StructureReporter(moOpts, uddReport, ...
      varName, varValue)
      moReporter@rptgen.cmpn.VariableReporters.StructuredObjectReporter(moOpts, ...
        uddReport, varName, varValue);
    end
    
    
    function propNames = getObjectProperties(moReporter)
      propNames = fieldnames(moReporter.VarValue);     
    end
    
    function propHead = getPropHead(moReporter) %#ok<MANU>
      import rptgen.cmpn.VariableReporters.*;
      propHead = msg('StructTblFieldColHd');
    end
  
  end % of dynamic methods
  
end

