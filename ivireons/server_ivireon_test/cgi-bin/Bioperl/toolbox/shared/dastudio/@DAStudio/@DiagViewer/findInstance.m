function h = findInstance(name)
%  DiagViewer.findInstance
%
%  DiagViewer.findInstance('name') returns the handle of the Diagnostic
%  Viewer instance named 'name'.
%  
%  Copyright 2008 The MathWorks, Inc.

  rt = DAStudio.Root;
   
  h = [];
  dvInstance = rt.find('-isa','DAStudio.DiagViewer');
  for i = 1:length(dvInstance)
    if strcmp(dvInstance(i).Name, name)
      h = dvInstance(i);
      break;
    end
  end


end