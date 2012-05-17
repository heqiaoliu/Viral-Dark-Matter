function convertNagsToUDDObject(h, nags)
%  CONVERTNAGSTOUDDOBJECT
%
%  Convert a set of nags to udd objects of DAStudio.DiagMsg class.
%  A nag is a message structure created by the Simulink/Stateflow
%  nag controller (slsfnagctlr.m).
%
%  Copyright 1990-2008 The MathWorks, Inc.

  
  for i = 1:length(nags)
    msgObject = h.convertNagToUDDObject(nags(i));
    h.messages = [h.messages;msgObject];
  end
  

end
