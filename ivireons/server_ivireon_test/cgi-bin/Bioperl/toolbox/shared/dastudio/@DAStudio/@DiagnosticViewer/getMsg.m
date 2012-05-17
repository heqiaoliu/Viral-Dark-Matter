function msg = getMsg(h,index)
%  GETMSG
%  This function will get a message from a list
%  of messages in the Diagnostic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.3 $ 

  
%Check that the index is within proper range

%   $Revision: 1.1.6.3 $  $Date: 2009/11/19 16:45:36 $
if (index <= 0 & length(h.Messages) > 0)
   error('index for DiagnosticMessageViewer.getMsg out of bounds') ;
end;

%Return correct message
msg = h.Messages(index);