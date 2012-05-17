function  dehilitModelAncestors(h)
%  DEHILITMODELANCESTORS
%
%  Removes highlights from the ancestors of the model
%  associated with the Diagnostic Viewer.
%
%  Copyright 1990-2008 The MathWorks, Inc.
 
  sysH = h.modelH;
  if ishandle(sysH)
    set_param(sysH, 'HiliteAncestors', 'off');
  end;
  
end
 
