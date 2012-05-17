function dv = find_dv
% find_dv
%
% Finds and returns the instance of the main Simulink diagnostic viewer, 
% i.e., the viewer used by slsfnagctlr.
%
%  Copyright 2002-2008 The MathWorks, Inc.

  rt = DAStudio.Root;

  if feature('ME_DV')
    dv = DAStudio.DiagViewer.findInstance('DAS');
  else
    dv = rt.find('-isa','DAStudio.DiagnosticViewer');
  end
  
end
