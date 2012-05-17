function setSelectedMsgIndex(h,index)
%SETSELECTEDMSGINDEX
%Check that the index is within proper range
%  Copyright 1990-2004 The MathWorks, Inc.
  
%   $Revision: 1.1.6.3 $  $Date: 2009/11/19 16:45:37 $
if (index <= 0 & length(h.Messages) > 0)
   error('index for DiagnosticMessageViewer.getMsg out of bounds') ;
end;  
%Set selected row
h.rowSelected = index;
