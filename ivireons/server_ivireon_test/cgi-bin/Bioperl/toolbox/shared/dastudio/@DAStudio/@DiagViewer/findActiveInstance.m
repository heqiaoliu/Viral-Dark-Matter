function h = findActiveInstance()
%  DiagViewer.findActiveInstance
%
%  Static method for finding the DV instance whose window currently
%  has the system's input focus. This method is used by menu and 
%  button callbacks to determine the DV instance to which they apply.
%  
%  Copyright 2008 The MathWorks, Inc.

  rt = DAStudio.Root;
   
  h = [];
  explorer = rt.find('-isa','DAStudio.Explorer');
  dv = rt.find('-isa','DAStudio.DiagViewer');
  for i = 1:length(dv)
    for j = 1:length(explorer)
      if dv(i).Explorer == explorer(j)
        h = dv(i);
        break;
      end
    end
  end


end