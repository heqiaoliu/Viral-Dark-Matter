function convertNagsToUDDObject(h,msgs)
%  CONVERTNAGSTOUDDOBJECT
%  This function will convert a bunch of nags to udd
%  objects
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.4 $ 
  
  for i = 1:length(msgs)
    msg = h.convertNagToUDDObject(msgs(i));
    h.messages = [h.messages;msg];
  end
  
  h.addDiagnosticMsgsToJava;

end
 

%   $Revision: 1.1.6.4 $  $Date: 2007/08/20 16:39:21 $
