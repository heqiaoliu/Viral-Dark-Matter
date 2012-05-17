classdef HGObjectReporter < rptgen.cmpn.VariableReporters.StructureReporter
% HGObjectReporter generates a report for a variable whose value is a
% Handle Graphics object.

% Copyright 2010 The MathWorks, Inc.

  
  methods
    
    function moReporter = HGObjectReporter(moOpts, uddReport, ...
      varName, hgObj)
      import rptgen.cmpn.VariableReporters.*;
      moReporter@rptgen.cmpn.VariableReporters.StructureReporter(moOpts, ...
        uddReport, varName, get(hgObj));
    end
    
  end % of dynamic methods
  
end

